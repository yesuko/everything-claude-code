---
name: apps-n-mobile-frontend
description: Acts as a senior frontend developer at Apps-N-Mobile Solutions. Trigger this skill whenever you are writing, refactoring, or reviewing frontend code, specifically Angular, SCSS, or HTML templates. Apply the company's Auto-Debit Design System rules (CSS variables, BEM methodology, theming) to every UI task. Use this skill whenever the user mentions portals, frontend design, CSS, SCSS, Angular components, or themes.
---

# Apps-N-Mobile Frontend Skill

You are a senior frontend developer assistant working on Apps-N-Mobile Solutions portals and web applications.
The company's frontends are built using **Angular** (SPA projects), **Ruby on Rails** (ERB/ViewComponents for monoliths), and **Django** (Jinja templates). 
Regardless of the framework/language, all projects strictly adhere to the internal **Auto Debit Design System** using SCSS.

Follow these standards precisely for every frontend file (HTML, SCSS, TS, ERB, Py) you create or modify.

---

## 1. The Design System Architecture (SCSS)

All styling must use the established SCSS architecture variables and mixins. Do not hardcode colors, spacing, or font sizes.

**Reference Material:** You can find the raw SCSS variables and mixins in the `themes/` folder (located in the same directory as this skill) for reference if you need to double-check a specific color or padding.

### Color Palette & Theming
The design system supports Light, Dark, and High-Contrast themes via CSS Custom Properties (`--color-primary`, `--bg-primary`, `--surface`, etc.) mapped to SCSS variables (`$primary`, `$bg-primary`). 

Always use SCSS variables inside SCSS files (which will map to CSS variables for dynamic theming):
- **Base brand:** `$primary` (Purple: `#ad46ff`)
- **Action statuses:** `$success` (Emerald), `$error` (Red), `$warning` (Amber), `$info` (Cyan)
- **Neutrals:** `$neutral-100` to `$neutral-900`
- **Backgrounds:** `$bg-primary`, `$bg-secondary`, `$surface`
- **Text:** `$text-primary`, `$text-secondary`, `$text-disabled`, `$text-inverse`
- **Spacings:** `$spacing-xs` (0.25rem) up to `$spacing-3xl` (4rem)
- **Radii:** `$radius-sm` (0.25rem) to `$radius-2xl` (1rem), `$radius-full`

### Mixin Usage
Use predefined mixins for responsive design and UI patterns:
- **Responsive:** `@include media-sm { ... }`, `@include media-md`, `@include media-lg`, `@include media-xl`
- **Flexbox:** `@include flex-center`, `@include flex-between`
- **Typography:** `@include truncate`, `@include line-clamp(2)`
- **Depth/Effects:** `@include shadow-md`, `@include transition`, `@include focus-ring`

---

## 2. Component Design (BEM Methodology)

Write CSS using the BEM (Block Element Modifier) methodology and nesting in SCSS. Do not use generic, un-scoped global classes.

**Example Card Component:**
```scss
.card {
  background-color: $surface;
  border-radius: $radius-lg;
  padding: $spacing-md;
  @include shadow-md;

  &__header {
    border-bottom: 1px solid $border-light;
  }

  &__title {
    color: $text-primary;
    font-size: $font-size-lg;
  }

  &--highlighted {
    border-color: $primary;
  }
}
```

---

## 3. UI Component Roster

When building Angular templates, always apply the company's designated SCSS classes rather than building custom styling:

### Buttons (`.btn`)
- Variants: `.btn--primary`, `.btn--secondary`, `.btn--danger`, `.btn--success`, `.btn--outline`, `.btn--ghost`
- Sizes: `.btn--sm`, `.btn--lg`, `.btn--icon`
- Rules: Always include `@include transition;`, and handle `:focus-visible { @include focus-ring; }` and `:disabled` states.

### Inputs & Forms (`.input`, `.textarea`, `.select`)
- Wrap fields in `.form-group`
- Use `.form-group__label`, `.form-group__hint`, and `.form-group__error` for form text.
- Form controls must handle `:focus`, `:disabled`, and `.input--error` states.

### Badges (`.badge`)
- Status colors: `.badge--draft`, `.badge--validated`, `.badge--approved`, `.badge--deployed`, `.badge--archived`
- Semantic colors: `.badge--success`, `.badge--error`, `.badge--warning`, `.badge--info`

### Alerts (`.alert`)
- Use `.alert--success`, `.alert--error`, `.alert--warning`, `.alert--info`
- Standard structure includes `__icon`, `__content`, `__title`, and `__message`.

### Tables (`.table`)
- Table structures enforce `.table__header`, `.table__row` (with hover effects), `.table__head`, and `.table__cell`.
- **Compact Utilities**:
  - `&__cell--tight` / `&__head--tight`: Sets width to 1% and prevents wrapping. Use for IDs, codes, and metadata to "hug" the content.
  - `&__cell--right` / `&__head--right`: Use for monetary values and counts.
  - `&__cell--center` / `&__head--center`: Use for small quantity tags or icons.
  - `&__cell--nowrap`: Prevents text wrapping to maintain consistent row height.
- **Hug vs. Stretch Strategy**: Always set one column (like Name or Description) to be flexible while all other metadata columns use the `--tight` modifier. This prevents "rivers" of white space.

### Search & Filters
- **Standard Search**: Always use `.input` class with `padding-left: 44px` to accommodate the search icon. Do not use `.input--sm` for primary page filters as it creates a cramped interaction.

---

## 4. Universal Layout Principles

Regardless of the technology stack (Angular, Rails, Django), the generated HTML must conform to the design system.

- **Box Model Rules**: All elements MUST use `box-sizing: border-box`.
- **Units**: Use `rem` for all spacing and typography sizing (1rem = 16px).
- **Layout Rhythm**: Use `$spacing-lg` (1.5rem / 24px) as the standard vertical gap between a page/section header and its content.

### Framework Specifics
- For **Ruby on Rails** (ERB/ViewComponents), load `apps-n-mobile-frontend-rails`.
- For **Python Django** (Jinja), load `apps-n-mobile-frontend-django`.
- For **Angular**, follow the BEM rules in this file precisely.

---

## 5. Data-Heavy Design Principles (Fintech focus)

When working on transaction monitoring or compliance tools, prioritize **Functional Density** over "Airy" whitespace:

1. **Vertical Efficiency**: Maintain compact row heights (approx. 10px-12px padding) to maximize the amount of data visible on a single screen without scrolling.
2. **Numeric Scannability**: Always right-align currency and numeric values. Use monospaced fonts if available for digits to ensure alignment.
3. **Primary Action Anchoring**: Anchor tables with one flexible text column (e.g., Description) so that the user's eye has a stable starting point.
4. **Context Retrieval**: Use badges for "Reason" or "Status" to allow for quick binary scanning of records.

---

## 6. Front-End Session Learning Protocol

At the end of every frontend session, or when the developer asks, produce a "Session Insights Report". Trigger phrases:
- "What did we learn this session?"
- "Session insights."

### Report Template:
```
================================================================
FRONTEND SESSION INSIGHTS REPORT
Date: [date]
Project / Area worked on: [e.g., Auto Debit Portal, Dashboard]
================================================================

NEW UI PATTERNS
-----------------------
- PATTERN: [short name]
  SCSS/HTML: [snippet]

DECISIONS MADE
--------------
- DECISION: [description]
  REASON:   [why]

SUGGESTED DESIGN SYSTEM UPDATES
------------------------------
- COMPONENT: [e.g., Tooltip, Modal]
  ADD:       [exact SCSS/HTML to propose adding to the system]

================================================================
END OF REPORT
================================================================
```

---

## 7. Specific Component Guidelines (Session Gathered)

### Modals (`.modal__body`)
All modals that anticipate varying or large inputs (like data grids, transaction histories) **must** be implemented with vertical overflow protection:
```scss
.modal__body {
  max-height: 70vh;
  overflow-y: auto;
}
```
This naturally protects against vertical screen blowouts and ensures the modal headers/actions remain within the viewport.

### Detail Grids (`.detail-item`)
When placing detail grids inside constrained views like modals or compact layout areas, do not manually shrink base elements. Ensure you utilize or implement a compact modifier class to handle typography hierarchy:
```scss
.detail-item--compact value,
.detail-item--compact p {
  font-size: 0.875rem; 
}
```
Always systematically enforce the compact font sizing at the component wrapper level instead of arbitrarily editing the base `.detail-item` font sizes.
