---
name: apps-n-mobile-documentation
description: Centralized documentation standards for Apps-N-Mobile. Covers API documentation, project structure, database schemas, and the "Documentation as Code" philosophy.
---

# Apps-N-Mobile Documentation Standard

Follow this standard to ensure all Apps-N-Mobile projects remain discoverable, consistent, and maintainable.

## 1. The Core Philosophy: "Documentation as Code"
Documentation is a first-class citizen in the codebase.
- **Never Outdated**: A feature is not "Done" until its documentation is updated.
- **Root-Centric**: Major architectural and API specs must reside in the project root (`/*.md`).
- **Versioned**: Documentation changes must be part of the same PR/commit as the code changes.

## 2. Standardized Documentation Files
Every project must include these files in the root directory:

| File | Purpose |
| :--- | :--- |
| `API_DEVELOPER_GUIDE.md` | Complete reference for all API endpoints, requests, and responses. |
| `SYSTEM_ARCHITECTURE.md` | High-level overview of the system design, data flow, and scaling advice. |
| `schema_diagram.md` | Database schema documentation, including relationships and soft-delete rules. |
| `REMITTANCE_ROADMAP.md` | (Optional) Future development goals and feature progress. |

## 3. API Documentation Checklist
When documenting an API endpoint in `API_DEVELOPER_GUIDE.md`, you MUST include:
- **Endpoint URL**: The path (e.g., `/manage/entity`).
- **Operation Code**: The 3-letter code (e.g., `CRT`, `RAL`).
- **Permissions**: Who can access this (e.g., `ADM Only`).
- **Request Schema**: A JSON example and a table describing each field (Type, Required/Optional).
- **Response Schema**: Successful and failed response examples.
- **Invariants**: Any business rules or logic constraints (e.g., "One Active Gateway Per Country").

## 4. Markdown Formatting Standards
Use a consistent visual style for readability:
- **Headers**: Use `##` for sections and `###` for sub-sections.
- **Tables**: Documentation for fields or role permissions MUST use tables.
- **Code Blocks**: Always specify the language (e.g., ` ```json `, ` ```bash `, ` ```elixir `).
- **Badges**: Use emojis for highlighting (e.g. ⭐ **Most Important**, ⚠️ **Warning**).

## 5. Change Management & Session Reports
At the end of a feature or session, update documentation using the **Session Insights Report** pattern:
- **NEW PATTERNS**: Document any new service patterns or architectural shifts.
- **DECISIONS**: Log why a certain technical choice was made (e.g., "Using module-level constants for static country lists").
- **SUGGESTED UPDATES**: Note any files that need more detail.

## 6. Centralized Governance
While projects have local documentation, global standards are maintained in the `apps-n-mobile-core` skill. If you find a pattern that should be company-wide, suggest an update to the core skill.
