---
name: apps-n-mobile-elixir
description: Specialized skill for Elixir development at Apps-N-Mobile. Covers project architecture, Plug.Router, Ecto, Oban, and global auditing patterns.
---

# Apps-N-Mobile Elixir Standard

Follow this standard for all Elixir API projects.

## 1. Project Architecture (The Layer Cake)

```
lib/<app_name>/
├── application.ex         # OTP Application supervisor
├── repo.ex                # Ecto Repo
├── controller.ex          # Base controller macro (handle_request/4)
├── router.ex              # Global Plug.Router (Entry point)
├── routers/               # Sub-routers for logical grouping
├── auth/                  # Authentication (Token, Plug, Redis)
├── cache/                 # ETS/GenServer caches
├── clients/               # External API clients
├── plugs/                 # Custom Plug middleware (e.g. RequestLogger)
├── repos/                 # Repository modules (DB access ONLY)
├── schemas/               # Ecto schemas
├── services/              # Business logic (The Heart)
├── utils/                 # Helpers (Constant, JsonResponse)
├── validators/            # Input validation (Changesets)
└── workers/               # Oban workers
```

---

## 2. Global Auditing & Request Flow

Every hit to the server must be logged.

### A. RequestLogger (The Entry Point)
Use `GatewaySwitcher.Plugs.RequestLogger` (or project equivalent) at the start of the `router.ex`. It logs the request and body, getting a `log_id` and storing it in `conn.assigns[:request_log_id]`.

### B. Controller & Halted Checks
Protected routes MUST check if authentication has stopped the request. 

**Standard Alias:** Always alias internal auth plugs with a prefix to avoid conflict with the top-level `Plug` module:
`alias GatewaySwitcher.Auth.Plug, as: AuthPlug`

```elixir
post "/manage" do
  conn = AuthPlug.call(conn, [])
  if conn.halted do
    conn
  else
    handle_request(conn, UserValidator, :update, &UserService.update/1)
  end
end
```

### C. JsonResponse (The Exit Point)
All responses must use `JsonResponse.send/3`. This utility automatically picks up the `request_log_id` and updates the database log with the final response JSON.

---

## 3. Base Controller Pattern

The `handle_request/4` macro manages the happy path:

```elixir
defmodule MyApp.Controller do
  defmacro __using__(_opts) do
    quote do
      defp handle_request(conn, validator, action, service_fun) do
        params = conn.params
        try do
          changeset = validator.call(params, action)
          if changeset.valid? do
            {status, result} = service_fun.(changeset.changes)
            JsonResponse.send(conn, status, result)
          else
            data = Constant.error_response(Constant.error(:validation_error))
            JsonResponse.send(conn, :bad_request, data)
          end
        rescue
          e -> 
            Logger.error("Internal Error: #{Exception.message(e)}")
            JsonResponse.send(conn, :internal_server_error, ...)
        end
      end
    end
  end
end
```

---

## 4. Repository Standards (Ecto)

- **Nil Guards**: Repo functions must handle `nil` inputs safely to prevent `Ecto.ArgumentError` in unauthenticated sessions.
- **Example**: `def get_by_user(nil), do: nil`
- **Soft Delete**: Always filter by `del_status == false` in repositories unless specifically performing an audit.

---

## 5. Technology Stack Standards

- **Server**: Bandit / Plug.Router
- **Database**: Ecto (Postgres)
- **Background Jobs**: Oban
- **Caches**: ETS-backed GenServers
- **HTTP Clients**: Finch (pattern-matched responses)
- **Auth**: JWT (Joken) + Redis session tracking

---

## 6. Advanced Routing & Security Patterns

### A. Infrastructure vs. Data Separation
- **The Rule**: Never store static base URLs or adapter implementation details (like `adapter_type`) in the database.
- **Implementation**: 
    - Store `base_url` and normalized adapter tags in `config/*.exs` under the `:adapters` key.
    - Use the database strictly for **Routing Logic** (deciding which gateway is assigned to which entity).
    - Determine the adapter type dynamically from the `gateway_code` (e.g., `ORC_GH` -> `ORCHARD`) to lookup the base URL in config.

### B. Recursive Multi-Tenant RBAC
- **Strict Isolation**: Secure all `RED` and `UPD` operations with an ownership check.
- **The Check**: Verify that `caller.entity_code == resource.entity_code`.
- **RBAC Scopes**:
    - `ADM`: Global access/read/write.
    - `MGR`: Read/Write strictly for their own Entity; blocked from structural/global configs (Gateways, Billing, Onboarding).
    - `USR`: Read/Write strictly for their own profile.

**Controller RBAC template** — always get `user_code` from `Auth.Plug`, never from params. Block entire role tiers before routing, then gate individual ops:

```elixir
def handle(conn) do
  user_code = Plug.current_user_id(conn)

  # Tier block: USR cannot access this controller at all
  if Authorizer.has_role?(user_code, "USR") do
    forbidden(conn, "Regular users cannot perform this operation.")
  else
    case Map.get(conn.params, "operation") do
      "CRT" ->
        case Authorizer.authorize_admin(user_code, fn -> :ok end) do
          :ok                    -> handle_request(conn, Validator, :create, &Service.create/1)
          {:error, :forbidden, msg} -> forbidden(conn, msg)
        end
      "RED" ->
        entity_code = Map.get(conn.params, "entity_code")
        case Authorizer.authorize_entity_view(user_code, entity_code, fn -> :ok end) do
          :ok                    -> handle_request(conn, Validator, :read, &Service.read/1)
          {:error, :forbidden, msg} -> forbidden(conn, msg)
        end
      # ...
    end
  end
end

defp forbidden(conn, message) do
  JsonResponse.send(conn, :forbidden,
    Constant.error_response(%{code: "FORBIDDEN", message: message}))
end
```

**Role visibility rule for resource listing (RAL):**

| Caller | Result |
|--------|--------|
| ADM | All records across all entities |
| MGR | Only records belonging to their own entity |
| USR | FORBIDDEN |

### C. Business Invariant Enforcement
- **Constraint Layer**: Logic that ensures data integrity across multiple rows must live in the `Service` layer inside a `Repo.transaction`.
- **Example**: "One Active Gateway Per Country" — Before activating a gateway for an entity, query the database for any existing active gateways for the same country code. Rollback if a conflict is found.

### D. Sanitized Response Payloads
- **Sanitized Response Payloads**: Shared service functions (like `sanitize_entity/1`) must filter out infrastructure flags (e.g., `active_status`) and sensitive credentials (e.g., `token_json`) before returning data to non-admin users.

### E. Context Inference & Parameter Injection
When building multi-tenant APIs, reduce the parameter burden on non-admin users by inferring context from their authentication token.

- **The Logic**: Create a `ControllerHelper.extract_requested_entity(conn)` that checks for an explicit `entity_code` (for Admins) and falls back to the user's profile `entity_code` (for Managers/Users).
- **Injection**: Inject the inferred value back into `conn.params` before calling `handle_request`. This ensures that Validators and Services receive a complete, consistent map regardless of whether the user provided the code explicitly.

**Example Implementation:**
```elixir
def handle(conn) do
  user_code = AuthPlug.current_user_id(conn)
  requested_entity = ControllerHelper.extract_requested_entity(conn)

  # Inject for inference and downstream authorization
  new_params = ControllerHelper.inject_entity_filter(conn.params, requested_entity, user_code)
  handle_request(%{conn | params: new_params}, Validator, :list, &Service.list/1)
end
```

---

## 7. Quality & Testing Standards

### A. Security & Boundary Testing
- Every controller operation must have a test case verifying the "Negative Path" (e.g., a Manager from Entity A trying to read a User from Entity B).
- Verify that restricted operations (like `ASG` or `ENB/DSB` on global resources) return `403 Forbidden` for non-Admins.

### B. Logical Constraint Testing
- Use dedicated constraint test files (e.g., `test/routing_constraint_test.exs`) to verify that the application correctly handles business rule violations (like trying to enable two gateways for the same country simultaneously).

### C. Seeder-Driven E2E Verification
For major feature releases or logic changes (like the two-tier fee model), manual ad-hoc testing is insufficient.
- **Protocol**: Maintain a comprehensive `priv/repo/seeds.exs` that resets the system to a known "Clean Slate".
- **Sequence**: Develop a standardized E2E Bash/Curl sequence that performs a multi-step user flow (Login -> Setup -> Fund -> Transact -> Verify Balance).
- **Verification**: Ensure the final verification step checks the "Mathematical Tally" (e.g., Merchant Balance == Start + In - Out - Fees).

---

## 8. RBAC Authorizer Module

`Auth.Authorizer` is the central module for all access decisions. Use `§ 6B` for the controller template. This section documents the **module interface** and **role visibility rules by resource**.

### Standard Authorizer Interface

```elixir
defmodule MyApp.Auth.Authorizer do
  def is_admin?(user_code),   do: has_role?(user_code, "ADM")
  def is_manager?(user_code), do: has_role?(user_code, "MGR")
  def has_role?(user_code, role_code)  # queries UserRoleRepo; returns false for nil

  # Gates — each accepts a zero-arity fn. Returns :ok or {:error, :forbidden, msg}
  def authorize_admin(user_code, func)
  def authorize_entity_view(user_code, entity_code, func)    # ADM + MGR (own entity)
  def authorize_entity_manage(user_code, entity_code, func)  # ADM + MGR (own entity)
  def authorize_user_view(user_code, target_code, entity_code, func)    # ADM + MGR + self
  def authorize_user_manage(user_code, target_code, entity_code, func)  # ADM + MGR + self
end
```

### Role Visibility by Resource Type

| Resource | ADM | MGR | USR |
|----------|-----|-----|-----|
| All roles (`RAL`) | ✅ All | ✅ MGR + USR only | ❌ FORBIDDEN |
| Single role (`RED`) | ✅ Any | ✅ MGR/USR — ADM → NOT_FOUND | ❌ FORBIDDEN |
| All users (`RAL`) | ✅ All | ✅ Own entity only | ❌ FORBIDDEN |
| Fee configs (`RED`) | ✅ All | ✅ Own entity only | ❌ FORBIDDEN |
| Fee configs (`CRT/UPD/DEL`) | ✅ | ❌ FORBIDDEN | ❌ FORBIDDEN |
| Gateway costs (`CST/RGC/UGC/DGC`) | ✅ | ❌ FORBIDDEN | ❌ FORBIDDEN |

---

## 9. Caller-Code Propagation Pattern

When a service needs to know *who* is calling in order to filter results by role, inject `caller_code` into params **before** calling `handle_request`. This keeps Auth concerns in the controller layer.

```elixir
# In the Controller:
def handle(conn) do
  user_code = Plug.current_user_id(conn)
  params = Map.put(conn.params, "caller_code", user_code)
  handle_request(%{conn | params: params}, Validator, :read, &Service.read_all/1)
end

# In the Service — scope the result based on caller role:
def read_all(attrs) do
  caller_code = Map.get(attrs, :caller_code)

  attrs =
    if caller_code && Authorizer.is_manager?(caller_code) do
      Map.put(attrs, :allowed_role_codes, ["MGR", "USR"])
    else
      attrs
    end

  filters = FilterBuilder.build_filters(attrs)
  # ...
end
```

> **⚠️ Critical:** You must also add `caller_code` to the validator's `@fields` list and `types/0` map, or the unknown-field check will reject the request before it reaches the service:
>
> ```elixir
> @fields [..., :caller_code]
>
> defp types do
>   %{..., caller_code: :string}
> end
> ```

---

## 10. Operation Code Convention

All validators accept an `operation` field using a **3-letter uppercase code**. Always validate with `validate_inclusion(:operation, ["XYZ"])`.

| Code | Meaning |
|------|---------|
| `CRT` | Create |
| `UPD` | Update (soft, in-place) |
| `DEL` | Soft delete |
| `RED` | Read single record |
| `RAL` | Read all / list |
| `ENB` | Enable (reactivate) |
| `DSB` | Disable |
| `ONB` | Onboard (composite create) |
| `LGN` | Login |
| `UPP` | Update password |
| `FGP` | Forgot password |
| `RSP` | Reset password |
| `REF` | Refresh token |
| `CST` | Create gateway cost fee |
| `RGC` | Read gateway cost fee |
| `UGC` | Update gateway cost fee |
| `DGC` | Delete gateway cost fee |

---

## 11. Soft Delete Standard

**Never hard-delete business records.** Always use a two-flag soft delete:

- `active_status: false` — record is inactive
- `del_status: true` — record is logically deleted
- All repo queries **must** filter `active_status == true AND del_status == false`

```elixir
# Correct soft delete pattern in any Repo:
def soft_delete(record) do
  record
  |> Schema.changeset(%{active_status: false, del_status: true})
  |> Repo.update()
end
```

### ⚠️ Ecto.Query Import Conflict Pitfall

If a Repo module uses `import Ecto.Query`, that macro imports `update/2` as a **query builder**. Calling your own `def update/2` from inside `soft_delete/1` will dispatch to `Ecto.Query.update/2` instead — causing a compile error:

```elixir
# BAD — triggers Ecto.Query.update/2 macro at compile time
def soft_delete(record), do: update(record, %{active_status: false, del_status: true})

# GOOD — call the changeset pipeline directly with Repo.update/1
def soft_delete(record) do
  record
  |> Schema.changeset(%{active_status: false, del_status: true})
  |> Repo.update()
end
```

---

## 12. Static Configuration Files (No DB Table)

For resources that are small, stable, and managed at deployment time (not runtime), use **module-level `@attribute` lists** instead of a database table. This avoids DB queries on every routing calculation.

**Use cases:** payment gateway definitions, country codes, currency lists, adapter types.

```elixir
defmodule MyApp.Utils.Gateways do
  @moduledoc """
  Static definition of supported gateways.
  Replaces the `gateways` database table.
  To add a new gateway: edit this file and redeploy.
  """

  @gateways [
    %{code: "ORC_GH", name: "Orchard Ghana",  country_code: "GH", adapter_type: :ORCHARD},
    %{code: "MTN_GH", name: "MTN MoMo Ghana", country_code: "GH", adapter_type: :MTN}
  ]

  def all,               do: @gateways
  def get_by_code(code), do: Enum.find(@gateways, &(&1.code == code))
  def for_country(cc),   do: Enum.filter(@gateways, &(&1.country_code == cc))
  def valid?(code),      do: not is_nil(get_by_code(code))

  def get_details(code) do
    case get_by_code(code) do
      nil  -> {:error, :not_found}
      meta ->
        config = Application.get_env(:app_name, :adapters, %{}) |> Map.get(meta.adapter_type, %{})
        {:ok, Map.merge(meta, config)}
    end
  end
end
```

**Rule:** Use this pattern only when:
- The list has fewer than ~50 items
- Items change only on deployments, not at runtime by end users
- No admin UI is needed to manage them at runtime

---

## 13. Two-Tier Fee Model (Entity Fees vs. Gateway Costs)

> **Applies to:** Payment gateway and fintech projects that charge merchants and pay upstream networks.

Projects in this domain use a **two-tier fee architecture**:

```
Merchant Fee (EntityFeeConfig)   = What YOU CHARGE the entity/merchant
Gateway Cost (GatewayFeeConfig)  = What YOU PAY the payment gateway
```

### Fee Spread Calculation (Exclusive Model)

```
Input:        Net Amount      (what the recipient receives)
Merchant Fee: calculated on Net Amount
Gateway Cost: calculated on Net Amount
Gross Amount: Net Amount + Merchant Fee   (what the merchant is debited)
Net Profit:   Merchant Fee - Gateway Cost (platform margin)
```

### Fee Type Discriminator

| Type | Formula | Scrubbing Rule |
|------|---------|----------------|
| `P` (Percentage) | `amount × pct` | `flat_fee` zeroed before save |
| `F` (Flat/Fixed) | `flat` only | `percentage_fee` zeroed before save |
| `H` (Hybrid) | `flat + (amount × pct)` | Both values retained |

**Scrubbing** happens at the service layer before persistence, ensuring no stale irrelevant values are stored.

### Entity Fee Lookup Priority

```
1. entity_code + gateway_code + currency   (most specific)
2. entity_code + currency only             (entity default)
3. MERCHANT_FEE_GLOBAL SystemSetting       (platform fallback)
4. Decimal.new(0)                          (last resort — no config)
```

### Fee Operation Set & Permissions

| Op | Scope | Who |
|----|-------|-----|
| `CRT` | Create entity fee | ADM only |
| `UPD` | Soft update entity fee (in-place) | ADM only |
| `DEL` | Soft delete entity fee | ADM only |
| `RED` | Read entity fee config | ADM + entity MGR |
| `CST` | Create gateway cost fee | ADM only |
| `UGC` | Soft update gateway cost | ADM only |
| `DGC` | Soft delete gateway cost | ADM only |
| `RGC` | Read gateway cost config | ADM only |

### CRT vs UPD Behaviour (Strict State Machine)

- **`CRT` (Create)** — Only allowed if **no active record** exists. Returns `ALREADY_EXISTS` if a conflict is found. Used for first-time onboarding.
- **`UPD` (Soft Update / Archive + Replace)** — Only allowed if an **active record exists**. It archives the old record (`del_status: true`) and inserts a brand-new record. This ensures a perfect audit trail for all changes.
