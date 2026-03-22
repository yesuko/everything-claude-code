---
name: high-performance-workloads
description: Architectural patterns and best practices for building unbreakable, high-concurrency systems that process massive datasets with absolute integrity.
version: 1.0.0
---

# High-Performance Workloads

This skill defines the architectural "DNA" for systems that must process massive datasets (millions of records) while maintaining operational stability and data integrity. These principles apply to batch processing, data synchronization, and high-volume financial transactions.

## 📂 Core Principles

### 1. Strict Streaming (OOM Prevention)
**Never load the full dataset into memory.** This is the #1 defense against "Out of Memory" (OOM) crashes.
- **File I/O**: Use `File.stream!/3` with tuned `read_ahead` buffers.
- **CSV/Excel**: Use streaming parsers (like `NimbleCSV.parse_stream/2`) and row-by-row Excel extraction.
- **HTTP**: Use chunked responses for downloads and streaming multipart bodies for uploads.

### 2. Tiered Hierarchical Processing
Break massive "monolithic" jobs into a hierarchy of smaller, manageable tasks.
- **Pattern**: `Producer (File Ingestion)` ➡️ `Batcher (Chunking)` ➡️ `Executor (Single Task)`.
- **Benfits**: Allows for granular retries, parallel execution across multiple nodes, and prevents a single bad record from failing a million-row batch.

### 3. Database Concurrency Hygiene
Standard ORM operations often fail at scale due to connection exhaustion or row-level locking.
- **Writes**: Use `insert_all` or `copy` to write thousands of rows in a single database trip.
- **Reads**: Use `FOR UPDATE SKIP LOCKED` for worker-driven queues. This allows multiple workers to "grab" pending work without stepping on each other's toes or causing deadlocks.
- **Connections**: Always use a connection bouncer (e.g., PgBouncer) in `transaction` mode for high-concurrency background workers.

### 4. At-Least-Once Integrity
Design for system failure at any micro-step.
- **Idempotency**: Every record must have a unique `processing_id` generated at the moment of ingestion.
- **Resume Capability**: If a worker node crashes mid-batch, the next worker should be able to resume by identifying unprocessed records in the database.

### 5. Backpressure & Throttling
A high-performance system must act as a regulator for its dependencies.
- **Throttling**: Use queue-level concurrency limits (e.g., Oban queue limits) to match the "Breaking Point" of external APIs or internal databases.
- **Monitoring**: Use Telemetry and real-time dashboards to monitor "Queue Pressure" and "Success Latency" rather than just looking at error logs.

## 🔄 Best Practices for Elixir/Phoenix
- **Streams over Lists**: Default to `Enum.reduce` on a `Stream` rather than building a massive list in memory.
- **Task.async_stream**: Use for parallelizing task execution with built-in backpressure (via `:max_concurrency`).
- **Agents for Transient Stats**: Use `Agent` to track counters (Success/Failure) during long-running streams to avoid constant DB writes for progress bars.
