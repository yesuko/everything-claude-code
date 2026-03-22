---
name: apps-n-mobile-ussd
description: Specialized skill for Ruby/Sinatra USSD development at Apps-N-Mobile. Covers session-based, menu-driven architectures using Redis and Page renderers.
---

# Apps-N-Mobile USSD Standard

USSD applications are session-based and significantly different from standard APIs.

## 1. Directory Structure

```
├── main.rb                  # Sinatra entry point (POST '/')
├── controllers/
│   ├── dial/                # Entry point logic (msg_type 0 vs 1)
│   ├── menu/                # Business module managers
│   ├── page/                # Individual screen renderers
│   ├── session/             # Session response builders (1=cont, 2=end)
│   └── service/             # External API services
├── models/
│   ├── cache.rb             # Redis-backed session state
│   └── model.rb             # ActiveRecord models
├── helpers/                 # Validation & Pagination
└── utils/
    ├── constants.rb          # MENU_FUNCTIONS, *_PAGES maps
    └── api.rb                # Faraday HTTP client
```

## 2. Request Pipeline

Interaction flow:
`POST '/' → Dial::Manager → Menu::Manager → Page::<Module>::<Screen> → Session::Manager`

- **Dial Manager**: Checks `msg_type`. '0' initializes the session via `EntityService`.
- **Menu Manager**: Uses `MENU_FUNCTIONS` constant to route based on the session's current function name.
- **Pages**: Inherit from `Menu::Base`. Define `display_message` and call `render_page`.

## 3. Session Management (Redis Cache)

Uses $redis to store state between HTTP calls based on `session_id` and `msisdn`.
```ruby
def store_data(new_data)
  fetch_data
  Cache.store(@params.merge(cache: @data.merge(new_data).to_json))
end
```

## 4. Key Constants

- **MENU_FUNCTIONS**: Maps module keys to main Menu classes.
- **PAGES Maps**: Specific to each module (e.g. `GEN_MAIN_PAGES`). Maps input '1', '2' etc. to Page classes.
- **Navigation**: `BACK = '00'`, `NEXT = '01'`, `PREV = '02'`.
