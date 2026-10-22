---
description: Start a task with Skilder. Summarises the task, asks the workspace which role fits, learns it, then works with that role's skills.
argument-hint: <what you need done>
---

The user wants this done with Skilder: $ARGUMENTS

If that is empty, ask the user what they need done, and stop. For someone new to Skilder, mention that `/skilder:start` shows the workspace first.

Otherwise:

1. Write one sentence, in your own words, naming the kind of work this is. Keep the vocabulary of the field (the tools, artefacts and terms involved). Do not paste the user's text.
2. Call the Skilder `init_skilder` tool with that sentence as `task_summary`. Keep the session id it returns: every other Skilder call takes it as `sessionId`.
3. Tell the user, in one line, which role Skilder suggested. If it returned several candidates, ask which one. If it returned the catalog, pick the role whose description covers the task, or ask.
4. Learn the role with `learn`, then the skill the task needs, and continue the task as the `using-skilder` skill describes.

If no Skilder tool is listed, say so and point to the `connect-to-skilder` skill instead of guessing.
