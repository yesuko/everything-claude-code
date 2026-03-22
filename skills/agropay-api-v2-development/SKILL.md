---
name: agropay-api-v2-development
description: Specialized skill for Agropay API V2 development. Covers complex allocation flows, multi-stage approvals (EAI/EAA/PAI/PAA), PC profile splits, and mobile payment synchronization.
---

# Agropay API V2 Development Patterns

This skill defines the unique architectural patterns used in the Agropay ecosystem. It handles the complex multi-party fund distribution system from Wallets to Purchasing Clerks (PC).

## 1. The Allocation Hierarchy (EFA to PIF)

Agropay uses a strict 4-stage hierarchy for fund distribution:

| Step | Type | Role | Action |
| :--- | :--- | :--- | :--- |
| **1 (EAI)** | `EFA` | Initiator | Fund input (Manual or Webhook from Orchard Wallet) |
| **2 (EAA)** | `EFA` | Approver | Validates EFA and assigns `purchase_season_id` if missing |
| **3 (PAI)** | `PIF` | Allocator | Distributes approved EFA funds to specific **Purchasing Clerks (PC)** |
| **4 (PAA)** | `PIF` | Approver | Final validation of PC allocation |

### **Validation Invariant**
`Sum(PAI Allocations)` for a specific `purchase_season_id` **MUST NOT EXCEED** `Sum(Approved EAI Inputs)` for that same season.

---

## 2. PC Profile & Fund Splits
When funds reach the PC (Purchasing Clerk), they are split based on a predefined ratio in the **PC Profile**:
- **EVL (E-Value)**: Digital currency/credits.
- **CSH (Cash)**: Physical cash allocation.

**Standard**: The split ratios are product-specific (e.g., Cocoa might have different splits than Cashew). Always lookup the ratio in `PCProfileService` before final ledger entry.

---

## 3. Mobile Payment Sync Flow
Agropay synchronizes with external mobile payment gateways (Orchard, etc.).
- **Operation**: `SYNC_PAY` or `PRC` (Process).
- **Idempotency**: Use `exttrid` as the primary key for all incoming webhooks to prevent double-funding.
- **Async Pattern**: Webhook inserts into `IncomingPaymentLogs` -> Oban worker processes the log -> Creates EAI (EFA) record.

---

## 4. Coding Standards (Agropay-Specific)

### **A. Multi-Tenant Resource Guarding**
Agropay is heavily multi-tenant (Districts -> Societies -> PCs).
- **The Rule**: Always filter `RED` and `RAL` queries by `district_id` or `society_id` derived from the `AuthPlug` token.
- **Never**: Accept `district_id` as a raw param from a non-admin user.

### **B. Batch Evaluation & Accumulation**
Agropay often processes multiple deductions or allocations in a single request. 
- **The Problem**: Querying the database inside an `Enum.map` or `Enum.reduce` (N+1 problem).
- **The Pattern**: 
    1. Extract all IDs from the collection.
    2. Perform a single batch query (e.g., `get_total_repaid_amounts_batch(ids)`).
    3. Load results into a Map for O(1) lookup during the reduction phase.
- **Impact**: Reduces database load by ~50% in complex payout scenarios.

### **C. Transactional Integrity**
Because allocations involve checking balances across multiple tables (EAI vs PAI), all allocation logic must reside in a **`Repo.transaction`**.

```elixir
# Service Pattern for Allocation
def allocate_funds(attrs) do
  Repo.transaction(fn ->
    with {:ok, balance} <- get_available_efa_balance(attrs.season_id),
         :ok <- validate_limit(balance, attrs.amount),
         {:ok, record} <- PAI_Repo.insert(attrs) do
      record
    else
      {:error, reason} -> Repo.rollback(reason)
    end
  end)
end
```

---

## 5. Operations Reference (Agropay Extensions)
In addition to standard `CRT/RED/UPD/DEL`, Agropay uses:
- `APV` (Approve): Transition a record from Step 1 to Step 2 or Step 3 to 4.
- `RJC` (Reject): Mark a record as rejected (requires reason).
- `FND` (Fund): High-level operation for incoming wallet payments.
- `SPL` (Split): Triggers the PC Profile ratio calculation.
