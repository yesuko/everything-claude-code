---
name: apps-n-mobile-frontend-django
description: Specialized skill for Python/Django frontend development at Apps-N-Mobile. Focuses on Jinja templates, context management, and BEM styling integration.
---

# Apps-N-Mobile Frontend: Django

Follow these standards for all Django-based portal projects. This skill must be used alongside `apps-n-mobile-frontend` (for CSS/Design System).

## 1. Template Architecture

The company uses Django's native template system with a focus on deep inheritance and modularity.

### A. Template Inheritance
- Base structure: `base.html` (Head/Assets) -> `layout.html` (Navbar/Sidebar/Shell) -> `page.html`.
- Use `{% extends %}` and `{% block %}` for every page.
- Place reusable snippets in `templates/includes/`.

### B. Template Logic
- Minimize logic inside templates. Calculations and complex filtering should happen in the **View** or **Template Tags**.
- **Golden Rule**: Every HTML element MUST include the strict Auto-Debit BEM classes.
- Example:
```html
<a href="{% url 'gateway_delete' id %}" class="btn btn--danger btn--sm">Delete</a>
```

## 2. Context & Data Rendering

- Use Django's `humanize` library for numeric and date formatting.
- Always right-align numeric amounts in tables using the `.table__cell--right` class.

## 3. Forms (Django-crispy-forms)

- If using crispy-forms, ensure the template pack is configured to output BEM-compliant wrappers.
- Manual forms must wrap inputs in `.form-group` and use `.input` for text/select fields.
- Use `{{ form.field.errors }}` inside a `.form-group__error` span.
