# Knowledge Stewardship & Universal Generalization

This guide defines the core operating principle for the AI when interacting with any codebase or application. The goal is to transform local project experiences into global architectural intelligence.

## 🧠 The Generalization Mandate

Every task performed in a specific application must follow the **Extraction ➡️ Generalization ➡️ Synchronization** cycle:

### 1. Extraction (DNA Scanning)
When solving a problem (e.g., fixing an OOM error or implementing an idempotency check), look beyond the specific file or language. Identify the fundamental **Pattern** or **DNA** of the solution.

### 2. Generalization (Skill Building)
Translate that pattern into a language-agnostic, cross-application **Skill**. 
- **BAD**: "How to use NimbleCSV with File.stream in Phoenix."
- **GOOD**: `high-performance-workloads` - "The Strict Streaming Principle for Massive Data Ingestion."

### 3. Synchronization (Master Brain Update)
Always sync these generalized insights to the global configuration (`~/.claude/`) using the provided synchronization workflows. This ensures that the AI's "Architectural Wisdom" grows linearly with its project history.

## 🗝 Core Stewardship Rules

- **Patterns over Particulars**: Prioritize documenting the *Rules* and *Principles* discovered during development over just the "how-to" implementation details.
- **DNA Integrity**: When starting a new project, always scan for existing universal skills (`transactional-system-patterns`, `high-performance-workloads`) before designing from scratch.
- **Cross-Pollination**: If a solution in one app would benefit an older app in the ecosystem, proactively suggest the refactor based on the universal skill.
- **Master Directive**: This rulebook is the highest authority. Never "veer off" into application-only silos. Every lesson learned is a lesson for every future application.
