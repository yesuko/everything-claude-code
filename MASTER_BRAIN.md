# 🧠 The Master Brain (ECC + Apps-N-Mobile)

This repository is the **Source of Truth** for all AI specialized knowledge and workflows. It combines the **Everything Claude Code (ECC)** performance framework with the proprietary **Apps-N-Mobile Solutions** engineering standards.

## 🏛️ Pillars of Knowledge

### 1. The ECC Core (The Engine)
- **Agents**: `planner`, `architect`, `tdd-guide`, `code-reviewer`, `security-reviewer`.
- **Commands**: `/plan`, `/tdd`, `/code-review`, `/skill-create`, `/learn`.
- **Global Skills**: `api-design`, `tdd-workflow`, `security-review`, `strategic-compact`.

### 2. Apps-N-Mobile Standards (The Soul)
- **`apps-n-mobile-core`**: The 5 pillars (Simple, Clean, Optimized, DRY, Robust).
- **`apps-n-mobile-elixir`**: Project Layer Cake, Controller patterns, global auditing.
- **`apps-n-mobile-ussd`**: Specific patterns for high-concurrency USSD gateways.
- **`apps-n-mobile-documentation`**: Governance and documentation standards.

### 3. Project Specializations (The Instincts)
- **`gateway-switcher-development`**: Deep knowledge of the Switcher's fee engine, idempotency, and routing logic.

---

## 🛠️ Usage Patterns

### **A. Global Adoption (Recommended)**
Run `scripts/sync-to-global.sh` to install all agents and skills into `~/.claude/`. This allows you to use these patterns in **any** repository on this machine without local setup.

### **B. Project-Local Adoption**
Copy this entire `trainer_1` directory into your project as a folder or submodule. Update your `CLAUDE.md` to point to the `skills/` directory here.

### **C. Continuous Learning**
When you discover a new pattern during a session:
1. Run `/learn` or create a new skill with `/skill-create`.
2. Move the refined skill into `trainer_1/skills/`.
3. Re-run your sync script to update your global brain.

---

## ⚡ Quick Commands
- **New Feature?** `/plan "I want to add X"`
- **Bug?** `/tdd "Reproduce bug Y"`
- **Deploy?** `/verify`
