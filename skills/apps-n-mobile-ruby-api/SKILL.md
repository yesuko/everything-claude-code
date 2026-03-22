---
name: apps-n-mobile-ruby-api
description: Specialized skill for Ruby/Sinatra API development at Apps-N-Mobile. Covers architecture using Sinatra, ActiveRecord, Sidekiq, and Dry-Validation.
---

# Apps-N-Mobile Ruby API Standard

Follow this standard for Ruby projects using Sinatra and ActiveRecord.

## 1. Directory Structure

```
├── config.ru                # Rack entry point
├── config/
│   ├── boot.rb              # Loader
│   └── application.rb       # Main Sinatra class
├── app/
│   ├── controllers/         # Params -> Validate -> Service -> Response
│   ├── services/            # Core business logic
│   ├── validators/          # Dry::Validation contracts
│   ├── models/              # ActiveRecord Models
│   ├── workers/             # Sidekiq background jobs
│   └── errors/              # Custom Error definitions
└── middlewares/             # Rack Middlewares (CORS, Logger, Errors)
```

## 2. BaseController Pattern

The controller subclass defines `#process` to bridge params and services:

```ruby
class BalanceController < BaseController
  def process
    params = parse_request_and_validate(BalanceValidator).merge(@query_param)
    result = BalanceService.call(params)
    respond_with_json(result[:status], result.except(:status))
  end
end
```

## 3. Validation & Services

- **Validators**: Use `Dry::Validation` contracts.
- **Services**: Inherit from `BaseService`. They take a hash and return a structured hash. `BaseService` handles DB error logging and helper responses.

## 4. Technology Stack Standards

- **Server**: Puma / Sinatra
- **Database**: ActiveRecord (Postgres)
- **Background Jobs**: Sidekiq
- **Validation**: Dry-Validation
- **HTTP Clients**: Faraday (wrapped in specific service clients)
