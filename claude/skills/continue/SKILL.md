---
name: continue
description: Resume an interrupted task. Use when the user says "continue" after a context limit or manual stop. Inspect recent state and pick up exactly where work left off.
---

A task was interrupted (context limit or manual stop). Resume it now:

1. Check memory at `~/.claude/projects/*/memory/MEMORY.md` for any active project context.
2. Check if a plan file exists (the system-reminder will indicate one if present) and read it to understand what was being done.
3. Identify the logical failure/stop point by reading recently modified files (`git status`, `git diff`, recent logs).
4. Resume from exactly that point. Do not re-do completed steps.
5. Do not preface with explanations of what was done before. Just continue.
