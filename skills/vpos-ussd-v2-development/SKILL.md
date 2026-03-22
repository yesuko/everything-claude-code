---
name: vpos-ussd-v2-development
description: Specialized skill for VPOS USSD V2 (Ruby/Sinatra) development. Covers USSD state machine logic, session management, MSISDN tracking, and nested menu flows.
---

# VPOS USSD V2 Development Patterns

This skill defines the architectural standards for the VPOS USSD gateway. It handles the mapping between cellular network requests and backend financial services.

## 1. USSD Lifecycle (Msg Type Logic)

USSD requests follow a strict state pattern:

| Msg Type | Name | Purpose |
| :--- | :--- | :--- |
| **0** | Start / Dial | Initial entry. Triggers Entity/Module verification. |
| **1** | Continue / Response | User selection from a nested menu. |
| **2** | Release | Session termination. |

**Standard**: All entries must pass through `Dial::Manager` to determine the flow path (Speed Dial vs. First Dial).

---

## 2. Menu Orchestration
The USSD interface uses a string-based nested menu system.
- **Menu Manager**: `Menu::Manager` handles the state transition based on the user's `ussd_body` input.
- **State Persistence**: Sessions are keyed by `msisdn` and `session_id`.
- **Latency**: USSD sessions have a strict timeout (usually 20-30s). All backend calls must be highly optimized and handle timeouts gracefully.

---

## 3. Core Services
The application follows a modular service pattern:
- **`NetworkService`**: Identifies the carrier (MTN, Telecel, etc.) based on the MSISDN prefix.
- **`EntityService`**: Fetches merchant/entity permissions.
- **`SpeedDialService`**: Handles deep-linked USSD codes (e.g., `*713*1*amount#`).
- **`ModuleService`**: Validates the specific micro-app being triggered (Payouts, Collections, etc.).

---

## 4. Coding Standards (Ruby/Sinatra)

### **A. Global Logger (LOGGER)**
Always use the centralized `LOGGER` for diagnostic traces.
```ruby
LOGGER.info("[Dial::Manager] MSISDN: #{@mobile_number} — Type: #{@message_type}")
```

### **B. Indifferent Access**
Incoming JSON parameters must be parsed with `with_indifferent_access` to allow flexible symbol/string key usage.

### **C. Error Resilience**
USSD must NEVER crash. If a backend service fails, show a friendly `USS_FAIL` message instead of a raw 500 error.
```ruby
rescue StandardError => e
  # Show generic USSD error to user
end
```

---

## 5. Security & Validation
- **MSISDN Masking**: Mask phone numbers in logs if they are not necessary for immediate debugging.
- **Permission Guarding**: Verify `ModuleService` before showing any sensitive menu options (like "Withdraw Funds").
