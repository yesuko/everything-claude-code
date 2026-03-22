---
name: apps-n-mobile-core
description: Core values, pillars, and workflows for Apps-N-Mobile Solutions. This skill defines the company's "Soul" and architectural standards across all languages.
---

# Apps-N-Mobile Core Values & Workflows

This skill contains the universal standards for all Apps-N-Mobile projects. It must be used in conjunction with language-specific skills (Elixir, Ruby API, or USSD).

## 1. Core Coding Rules (The Five Pillars)

### A. Simple & Clean
- Functions MUST NOT exceed 20-30 lines. Decompose into private helpers.
- Each function does exactly one thing.
- Use linear "happy path" logic. Minimize nested conditionals.
- Use intention-revealing names.

### B. Optimized State & Database
- Use `true`/`false` for boolean fields. Never `0`/`1`.
- Accumulate results in memory, write to DB once at the end.
- Use `Repo.insert_all` (or equivalent) for bulk operations.

### C. DRY
- All constants in a centralized module (e.g., `Constant`). No magic strings.
- Shared logic in `utils/` or `helpers/` modules.

### D. Robustness
- Log every step: `Logger.info("[ServiceName] action — result")`
- Wrap external calls in `try/rescue` or pattern-match with `case`.
- Record row-level errors to the DB error log table.

### E. Architectural Consistency
- **Services** → Business logic
- **Repos/Models** → Database access
- **Workers** → Background jobs
- **Validators** → Input validation
- **Clients** → External API calls

### F. Database Logic (Soft-Delete & Uniqueness)
- Use **Partial Indexes** for unique constraints on soft-deleted tables.
- Pattern: `create unique_index(:table, [:field], where: "del_status = false")`
- This ensures that deleted records don't block the creation of new records with the same identifier (e.g., Email, Gateway Code).
- Always include `del_status: false` (or equivalent) in queries unless auditing.

---

## 2. Refactoring Workflow

When refactoring or building a new service, follow these steps in order:
1. **Analyze** — Identify fat functions. Decide if routes are REST or RPC.
2. **Contextualize** — Build a context map for IDs and parameters.
3. **Setup State** — Use in-memory agents/stats if batch processing.
4. **Decompose** — Break logic into small private helper functions.
5. **Standardize** — Replace magic strings with constants. Use standardized response envelopes.
6. **Secure** — Ensure authentication and authorization checks are early and explicit.
7. **Log & Finalize** — Verbose logging at fail points. Consolidate DB writes.

---

## 3. Documentation Governance
- **Location**: Keep architectural specs in the project root (e.g., `API_DEVELOPER_GUIDE.md`) to ensure they are visible and versioned alongside the code.
- **Documentation as Code**: Treat documentation as a living part of the codebase. A feature is not "Done" until the corresponding documentation (permissions, operations, field changes) is updated.
- **Self-Documenting Schemas**: Every spec must cross-link related resources in its footer.
- **Governance**: Use a central Documentation Hub for cross-project standards, but keep implementation-specific details in the repository.

---

## 4. Session Learning & Insights Protocol

At the end of every session, or when requested, produce a "Session Insights Report".

### Report Template:
```
================================================================
SESSION INSIGHTS REPORT
Date: [date]
Project / Area worked on: [e.g., Payment Service, Auth Module]
================================================================

NEW PATTERNS DISCOVERED
-----------------------
- PATTERN: [name] | WHAT: [desc] | WHEN: [usage]

DECISIONS MADE
--------------
- DECISION: [desc] | REASON: [why] | IMPACT: [which file to update]

SUGGESTED INSTRUCTION UPDATES
------------------------------
- FILE: [path] | SECTION: [section] | ADD: [text]

================================================================
END OF REPORT
================================================================
```
