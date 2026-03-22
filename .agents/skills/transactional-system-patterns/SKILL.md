---
name: transactional-system-patterns
description: Universal architectural patterns for systems handling value exchange (payments, orders, ledger movements) to ensure absolute data integrity and idempotent state transitions.
version: 1.0.0
---

# Transactional System Patterns

This skill defines the universal rules for building reliable systems that handle financial value, state-sensitive orders, or high-stakes data transitions. These patterns ensure that "Double Spending," "Phantom Records," and "Stuck States" are architecturally impossible.

## 🗝 Core Architecture Patterns

### 1. The Audit Trail Lifecycle (Mandatory decoupling)
Never overwrite a single record for a complex transaction. Instead, use a three-tier traceability structure:
- **Intent (Log/Request)**: The raw, immutable payload received from the actor. This preserves the original "ask."
- **Attempt (Execution Tracking)**: A bridge record representing the *act* of performing the transaction (e.g., calling an external gateway). Each retry should be a separate "Attempt" record linked to the same "Intent."
- **Reconciliation (Callback/Status)**: Finalized records of the outcome. This decoupling allows for non-destructive state reconstruction at any time.

### 2. Strict Deterministic Idempotency
Every destructive action must be tied to a client-provided `idempotency_key` or a derived `processing_id`.
- **Key Strategy**: Derive keys from uniquely identifying fields (e.g., `user_id + original_reference + current_batch_id`).
- **Storage**: Check for the existence of this key in the database (or Redis) *before* any service logic execution. Return the *previous result* instead of re-processing if the key is found.

### 3. Service-Centric Decoupling
Business logic must be entirely isolated in **pure Services**.
- **Controllers** should only: Verify permissions, parse parameters via **Validators**, and pass clean data to the Service.
- **Workers** should only: Retrieve data from the queue and call the same Service function used by the Controller.
- **Benefit**: Ensures the same rules apply regardless of whether an action is manual (Dashboard) or automated (Background Job).

### 4. Error-Resilient Callbacks & Reconciliation
Always design for "Non-Reliable" external system signals.
- **Idempotent Handlers**: Reconciliation logic (callbacks) must be safe to run multiple times for the same transaction without duplicate side-effects (e.g., multiple ledger deductions).
- **Archive First**: Before processing a new callback, archive any existing "pending" status logs to preserve the historical trail.

### 5. Value/Fee Logic Standardization
Any system involving money must use standardized discriminators for calculations to prevent ad-hoc logic bugs:
- **P**: Percentage (Calculation).
- **F**: Flat (Fixed).
- **H**: Hybrid (Both).
- **G**: Gateway (Passed through).
- Always use **Decimal** types, never floats, for financial math.

## ✅ Operational Readiness
- **Soft Deletes**: Use `active_status` and `del_status` for all transactional entities to ensure the audit trail is never truly erased.
- **Optimistic Locking**: Use database-level locks (`FOR UPDATE SKIP LOCKED`) for workers to ensure multiple worker nodes never process the same "Attempt" simultaneously.
