---
name: gateway-switcher-development
description: Elixir/Phoenix patterns for the Gateway Switcher project, focusing on transaction routing, fee management, and background jobs.
version: 1.0.0
source: local-git-analysis
analyzed_commits: 100
---

# Gateway Switcher Development Patterns

Conventions and best practices extracted from your recent work on the Gateway Switcher platform.

## 📂 Core Architecture

The application is structured as an Elixir/Phoenix umbrella-style or modular application:

- **Services (`lib/gateway_switcher/services/`)**: The business logic layer. All core operations (Transaction, Routing, Callback, Fee) reside here.
- **Schemas (`lib/gateway_switcher/schemas/`)**: Ecto models defining the database structure (Transaction, EntityConfig, EntityFeeConfig).
- **Workers (`lib/gateway_switcher/workers/`)**: Background job processing using Oban or similar (e.g., `PaymentWorker`).
- **Validators (`lib/gateway_switcher/validators/`)**: Input schema validation used by Controllers before invoking Services.

## ✍️ Coding Conventions

### 1. Idempotency First
Strict Redis-backed idempotency key handling is mandatory for all transaction initiations to prevent duplicate processing.

### 2. Fee Configuration
Use `fee_type` discriminators consistently:
- **P**: Percentage
- **F**: Flat
- **H**: Hybrid (Both)

### 3. Service-Centric Logic
Controllers should remain thin. Services handle:
- Database transformations
- External API calls (Gateways)
- Error handling logic

## 🔄 Common Workflows

### Adding a New Gateway
1. Update `EntityConfig` schema if new parameters are needed.
2. Implement specific provider logic in `TransactionService` or a separate `GatewayService`.
3. Add mandatory seed data in `priv/repo/seeds.exs` for the gateway.

### Documentation Lifecycle
Always synchronize `API_DEVELOPER_GUIDE.md` when:
- Updating status codes
- Modifying response envelopes
- Adding new filtering or sorting query parameters

## ✅ Testing Requirements

- **E2E Integration**: Critical flows (e.g., successful payment, failed callback) must be verified in `test/management_e2e_test.exs`.
- **System Settings**: Ensure all new configuration keys respect the case-insensitive uniqueness constraints established for system settings.
- **Coverage**: Aim for 80%+ coverage on all core services.
