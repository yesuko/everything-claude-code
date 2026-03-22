---
name: apps-n-mobile-frontend-rails
description: Specialized skill for Ruby on Rails frontend development at Apps-N-Mobile. Focuses on ERB, ViewComponents, and BEM styling integration.
---

# Apps-N-Mobile Frontend: Ruby on Rails

Follow these standards for all Rails-based frontend projects. This skill must be used alongside `apps-n-mobile-frontend` (for CSS/Design System).

## 1. High-Level Architecture

The company uses a "ViewComponent" first approach to keep ERB files clean and reusable.

### A. ViewComponents
- Wrap complex or reused UI patterns (Cards, Modals, Tables) in `ViewComponent::Base` classes.
- Place them in `app/components/`.
- **Naming**: `Components::TableComponent`, `Components::StatusBadgeComponent`.

### B. ERB Best Practices
- Keep logic in Helpers or ViewComponents.
- Use standard Rails block helpers (e.g., `content_tag`, `link_to`, `form_with`) but **always** inject Auto-Debit BEM class names.
- Example:
```erb
<%= link_to "Delete", gateway_path(id), method: :delete, class: "btn btn--danger btn--sm" %>
```

## 2. Forms (SimpleForm / FormWith)

- Wrap fields in `.form-group`.
- Use the `.input` class for text fields.
- Labels must use `.form-group__label`.
- Error messages must use `.form-group__error`.

## 3. Layouts & Partials

- Use `content_for` to inject page-specific breadcrumbs or actions into the main layout.
- Organize partials in `app/views/shared/` only for truly global elements (Navbar, Footer). Everything else should be a ViewComponent.
