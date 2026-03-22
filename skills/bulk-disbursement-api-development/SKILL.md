---
name: bulk-disbursement-api-development
description: Specialized skill for Bulk Disbursement API development. Covers high-concurrency Oban queue tuning, PgBouncer compatibility, massive file ingestion (CSV/Excel), and Finch-based HTTP pooling for Orchard API.
---

# Bulk Disbursement API Development Patterns

This skill defines the architectural standards for high-throughput financial disbursement systems. It focuses on the "Inhale/Exhale" pattern for massive file ingestion and external API execution.

## 1. High-Performance Ingestion (The "Inhale")
When handling files with 30k to 1M+ records:
- **Streaming**: Use `File.stream!` or `NimbleCSV.map_enumerable` to process rows one-by-one. NEVER load the entire file into memory.
- **Batch Insertion**: Use `Repo.insert_all` in chunks of 500-1,000 for the metadata layer.
- **Validations**: Perform light format validation during ingestion; deferred deep validation to individual workers.

---

## 2. Oban & PostgreSQL Tuning (The "Exhale")
To prevent database starvation while processing 300k+ jobs:
- **The Golden Rule**: `(Total Oban Workers + Ecto Pool Size) <= Database max_connections`.
- **Queue Proportions**:
  - `payments`: 50% of the pool (High I/O).
  - `ingestion`: 10% of the pool (High CPU/Memory).
  - `notifications/sms`: 10-20% of the pool.
- **Pessimistic Locking**: Use `FOR UPDATE SKIP LOCKED` when enqueuing or batching jobs to ensure multiple nodes don't collide.

---

## 3. Production Environment & PgBouncer
All database configurations must be PgBouncer-compliant safely:
- **Prepared Statements**: MUST be disabled (`prepare: :unnamed`) if PgBouncer is in `transaction` mode.
- **Sizing Rule**: Set the app `pool_size` to **3x - 4x** the PgBouncer `default_pool_size` to prevent idle connection hunger.

---

## 4. External API Reliability (Orchard/Finch)
- **Connection Pooling**: Use the `Finch` library with persistent connection pools to minimize SSL handshake overhead for mass payouts.
- **Callback Latency**: The `/callback` responder must return an HTTP 200/202 in **< 10ms**. The actual processing of the callback must be deferred to an Oban job (`CallbackProcessor`).
- **Idempotency**: Use the `exttrid` or `reference` inside a `FOR UPDATE` lock to prevent duplicate processing of retried callbacks.

---

## 5. Coding Standards (Performance-First)

### **A. Optimized Loops**
Prefer `Enum.reduce` or recursion for large data sets to maintain tail-call optimization and minimize garbage collection.

### **B. Logging Context**
Every log entry for a disbursement task must include the `processing_id` and `batch_id`.
```elixir
Logger.info("[PaymentWorker] processing_id: #{pid} — status: #{status}")
```

### **C. Error Recovery**
Individual payment errors must be recorded in an `ErrorLogs` table without crashing the parent `PaymentProcessor`. Use `try/rescue` inside the worker loop carefully.
