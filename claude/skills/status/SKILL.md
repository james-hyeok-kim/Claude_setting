---
name: status
description: Provide a concise progress report on the current task. Use when the user types "status" to get a quick summary of what's done, what's in progress, and what's next.
---

Provide a concise progress report in this structure:

- **Progress**: Overall completion estimate as a percentage (%).
- **Completed**: Sub-tasks or commands successfully finished.
- **Current / Interrupted**: The exact step being worked on or where it stopped.
- **Pending**: Remaining steps to complete the objective.
- **Next Action**: The immediate next command or step to run.

Keep output scannable. No code blocks unless essential. No repetition of prior output.
