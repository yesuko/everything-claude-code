---
name: agropay-ussd-development
description: Specialized skill for Agropay USSD (Ruby/Sinatra) development. Focuses on the agricultural fund distribution menus, farmer identification, and mobile sync payloads.
---

# Agropay USSD Development Patterns

This skill defines the architectural standards for the Agropay USSD gateway. It is geared towards Farmer/Purchasing Clerk interactions in the field.

## 1. USSD Menu Interaction (Agropay Flow)
Agropay USSD menus are designed for high-latency environments.
- **Identification**: MSISDN is used to lookup the `Purchasing Clerk` or `District Officer`.
- **Primary Flows**: 
  - **Allocation Inquiry**: Checking EFA/PIF balances from the USSD terminal.
  - **Deduction Processing**: Repaying inputs through the USSD interface.
  - **Farmer Verification**: Using national IDs/farmer codes via USSD.

---

## 2. Integration Payloads (Gateway Sync)
The Agropay USSD gateway is an intermediary between the Telco (MTN/NSA) and the Agropay API V2.
- **Standard**: Always reference `QUICK_REFERENCE_PAYLOADS.md` for the incoming JSON structure.
- **Payload Mirroring**: Incoming USSD parameters must be translated into the REST format required by the Agropay API.

---

## 3. Core Services (Ruby/Sinatra)
Similar to VPOS, this uses a `Dial::Manager` state machine:
- **`msg_type: 0`**: Initial dial. Triggers PC/Farmer lookup.
- **`msg_type: 1`**: Continue menu response.
- **Helper Pattern**: Use the `helpers/init` pattern to inject logic into the Sinatra controller context.

---

## 4. Coding Standards (Agropay USSD Specific)

### **A. External API Resilience**
All calls from USSD to the Agropay API must have a short **15-second timeout**. If the API is slow, the USSD session will timeout—always provide a generic 'TRY_LATER' message.

### **B. Global Logger (LOGGER)**
Standardized session logging is required to audit field transactions.
```ruby
LOGGER.info("[Agropay USSD] MSISDN: #{params[:msisdn]} — Action: #{params[:ussd_body]}")
```

### **C. Payload Documentation**
A USSD change is not "Done" until the `USSD_INTEGRATION_SAMPLE_PAYLOADS.md` is updated to show exactly what the Telco will send to the gateway.
