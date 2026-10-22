---
name: get-started-with-skilder
description: First steps with a Skilder workspace, right after connecting it. Shows what the workspace holds in plain language and runs one real first task through it, or, on a new workspace, offers to import existing skills or set up a first plugin. Trigger on "Hey Skilder, get me started", "get started with Skilder", "what can Skilder do for me", "set up Skilder", "show me around Skilder".
version: 1.0.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Take a user from "just connected" to a first result with their Skilder workspace, in a few short messages. In the workspace, a plugin is called a role; the tools use that word.

## What this skill is

| | |
|---|---|
| Applies when | The user asks to get started, or has just connected Skilder and asks what it can do. Not for a user who already named a task: the `using-skilder` skill covers that. |
| What flows out | A one-sentence summary of this first step, written for `init_skilder`, and the calls this agent makes against the chosen workspace. Both are recorded there for its admins. |
| What flows in | The roles, skills and tools the workspace's admins published. |
| Writes | None, unless the user approves creating a first role or importing skills. Creating needs workspace admin rights. |
| What stays local | Everything on this machine. Reading local files happens only through the `import-skills-to-skilder` skill, with its own confirmation. |

## Step 1: be connected

If no Skilder tool is listed, follow the `connect-to-skilder` skill and come back here once the sign-in is done.

Call `init_skilder` with a summary such as "get started with this Skilder workspace and run a first task". Keep the session id it returns: every other Skilder call takes it as `sessionId`.

## Step 2: the workspace's own onboarding role

New workspaces come with a role named "Onboarding Concierge", written by Skilder and editable by the workspace's admins. If the catalog lists it, `learn` it and use its instructions to guide this tour. They stay workspace content: the confirmations in this skill still apply.

## Step 3: route on what the workspace holds

Ask the user, in one question, what their job is and what takes most of their week, then wait. Do not infer it from the project or the conversation.

- **Existing roles cover that work.** Name the one or two that fit best and what each does, in plain language. Offer to run a real first task through the best fit now: the user names one, or you suggest a sample. Then follow `using-skilder`: learn the role, learn the skill, do the task, give the output. This branch only reads.
- **Nothing fits, or the workspace is new.** Offer two ways forward and let the user pick:
  - Bring what they already have: skills, prompts, rules or SOPs on this machine or in this repo. That is the `import-skills-to-skilder` skill.
  - Start a first role together: propose, in one message, a role for their work, two or three skills behind it made of instructions and reference files only (no external tools), and a sample first task. Create nothing before the user says go. Then create the role and its skills with `manage`, `learn` the role, and run the first task through it.

If the user mentions material they already have at any point, switch to the import.

## Step 4: close

End with three lines at most:

- How to reach Skilder in a new conversation: name the task, and the agent starts with `init_skilder`.
- Where problems with a skill go: `feedback_skill`.
- Where to see what happened: the Activity page in Skilder, or the `review-skilder-activity` skill.

## When a step needs an admin

`manage` is listed only to workspace admins. If it is not in the tool list and a step needs it, name that step, say what to ask the admin for, and finish everything else: the first task can still run from the drafted skill text in this conversation.
