---
name: import-skills-to-skilder
description: Use when the user has Agent Skills (SKILL.md folders) on this machine or in this repo and wants them in their Skilder workspace, such as "import my skills to Skilder", "move my local skills into Skilder", "share these skills with my team" or "centralize our agent skills". Scans the usual skill folders, asks once which to import, and creates them as drafts with their files (workspace admin). Not for drafting new capabilities from a conversation or document (capture-work-in-skilder).
version: 2.1.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Move the user's existing local Agent Skills into their Skilder workspace. Skills use the open Agent Skills format on both sides, so content imports as-is: frontmatter and body stay what they are.

## What this import is

| | |
|---|---|
| Applies when | The Skilder tools are listed and the user is a workspace admin (the `manage` tool is in the tool list). |
| What flows out | The `SKILL.md` files and companion files the user approves, verbatim, to the chosen Skilder workspace, where they become draft skills. |
| What flows in | The workspace's existing skill names, to detect duplicates. |
| What stays local | The original files, untouched. Files that look like secrets are skipped and never sent. |
| Review | Imported skills land as drafts in the workspace library. Publishing them is a human step in Skilder. |

## Step 1: be connected

The Skilder MCP server has to be listed with its tools. If it is not, the `connect-to-skilder` skill covers that step (one endpoint, browser sign-in, no keys).

Then call `init_skilder` with a one-sentence summary such as "import this machine's local agent skills into the workspace", and keep the session id it returns: every other Skilder call takes it as `sessionId`.

Importing uses the `manage` tool, which Skilder lists to workspace admins. The first user of a workspace is its admin, so a user on their own workspace qualifies. If `manage` is not in the tool list, say that the import needs a workspace admin and stop.

## Step 2: discover local skills

Scan these locations, nearest first. Each directory containing a `SKILL.md` is one skill:

- `./.claude/skills/` and `./.agents/skills/` (project)
- `~/.claude/skills/` and `~/.agents/skills/` (user)
- `./skills/` in the current repo, including one level of category subdirectories

For each skill found, read the `SKILL.md`: YAML frontmatter gives `name` and `description`, the body is the instructions. Note any extra files next to it (a `references/` folder, scripts, other documents).

## Step 3: confirm the list once

Show the user a single inventory: skill name, one-line description, file count, and source path. Ask once which to import (default: all). Also list the workspace's existing skills with `manage` (its `describe-tool` operation documents the exact call) and flag any name that already exists; for those, ask whether to skip or import under a suffixed name. That is the one confirmation round. The import then runs over the approved list and reports at the end.

## Step 4: import

For each approved skill, in this order:

1. Create the skill with `manage`, passing `name` and `description` from the frontmatter and the `SKILL.md` body, verbatim, as the instructions. Keep the skill id the call returns.
2. Attach each companion file to that skill id with `manage`'s skill-content operation:
   - Markdown and text documents become references, named after the file, with the file content verbatim.
   - `.py`, `.sh`, `.js` and `.ts` files become scripts, typed PYTHON, BASH, JAVASCRIPT or TYPESCRIPT, with the file content as the code.
   - Binary files (images, PDFs) are skipped and recorded by name; they are added later through the web app.

Import content verbatim. Do not rewrite, summarize or "improve" the user's instructions.

## Constraints

- **Secrets stay out.** Before importing any file, check it for API keys, tokens, passwords or `.env`-style content. Skip such files, name them in the report, and do not echo their contents.
- **Do not guess.** If a `SKILL.md` has no name in its frontmatter, use its directory name. If a file's role is ambiguous, import it as a reference.
- **One failure does not stop the run.** If a create call errors, record it and continue with the remaining skills.

## Step 5: report

End with a single summary: skills imported (with names), files attached per skill, anything skipped (binaries, secrets, duplicates, errors). Then point the user at their library in Skilder to review the imports, compose them into roles, and publish. From there, every agent connected to the workspace can discover and run them.
