# USSD Application Configuration

## 🧠 Master Brain Integration
This project template is powered by the **ECC + Apps-N-Mobile Master Brain**.
- **Unified Skills Path**: `/opt/yesuko/train_skill/trainer_1/skills/`
- **Global Path**: `~/.claude/`

## 🛠️ USSD Standards (Sinatra)
- **Primary Language**: Ruby (Sinatra DSL)
- **Design Pattern**: State Machine (Dial/Menu Manager)
- **State Keys**: `msisdn` (User ID), `msg_type` (State), `ussd_body` (Input), `session_id`.
- **Latency**: All backend calls must handle timeouts (< 10s recommended).

## 📚 Essential Skills
1. **`vpos-ussd-v2-development`**: Shared Ruby USSD state machine standards (`msg_type` 0/1/2).
2. **`apps-n-mobile-ruby-api`**: Standard company standards for Ruby microservices.
3. **`apps-n-mobile-core`**: High-level engineering values (Clean, Simple, DRY).

## 🚀 Workflows
- **New Menu Option**: Use `/plan` to map out the `Menu::Manager` state transitions.
- **Diagnostics**: Always use the centralized `LOGGER` for session traces.
- **Error Handling**: Use `USS_FAIL` to report failures gracefully back to the Telco.
