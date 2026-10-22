---
name: capture-work-in-skilder
description: Use when the user wants to make something repeatable for their team in Skilder, such as "turn this into a skill", "save this workflow to Skilder", "make this a role for my team" or "build an App from this". Works from this conversation, a pasted SOP, a transcript, a document or a link. Decides whether the work belongs in skills, a role, an App, or a new version of what the workspace already holds. Suggests tools, or a connector to add, when the work needs one. Creates nothing before the user approves a short summary of what it will build (workspace admin).
version: 1.0.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Turn what the user provided into the right building blocks in their Skilder workspace: a skill, several skills, a role (what the outward copy calls a plugin), an App, or a new version of something that already exists. The shape is a judgement call made with the user, not a fixed format.

## What this skill is

| | |
|---|---|
| Applies when | The Skilder tools are listed, the user wants work made repeatable in Skilder, and the user is a workspace admin (the `manage` tool is in the tool list). |
| Source | Only what the user points at: this conversation, text they pasted, a file or link they named. Nothing else is read. |
| What flows out | What the user approves in the build summary, to the chosen workspace. |
| What flows in | The workspace's roles, skills, Apps and tools, to reuse them and avoid duplicates. |
| Review | A short build summary is approved in the conversation before anything is created. Skills and roles land as drafts; publishing them stays a human step in Skilder. |

## Step 1: be connected

If no Skilder tool is listed, follow the `connect-to-skilder` skill first. Then call `init_skilder` with a summary such as "turn this procedure into reusable workspace capabilities", and keep the session id for every other call.

If `manage` is not listed, say that building in the workspace needs a workspace admin, and offer to write the build summary and the skill text here for the user to hand to their admin.

## Step 2: read the source

Use what the user named. If they named nothing, use this conversation, and say so. If there is nothing to work from, ask for it and wait. If a file or link cannot be opened, say so instead of working from what it probably contains.

Leave out anything that looks like a credential, a personal detail about someone, or customer data. Name what you left out.

## Step 3: see what the workspace already has

Before deciding anything, look at what exists: the roles and skills `init_skilder` listed, the Apps (`manage`'s `list-apps`) and the tools the workspace serves (`manage`'s `list-available-tools`). Reuse beats duplication: when an existing skill or role covers part of the work, plan a new version of it or an attachment to it.

## Step 4: decide the shape

Pick what serves the work, and be ready to say why in one sentence:

- **Skill.** A procedure someone repeats: steps, checks, a template. Long material it leans on (checklists, examples, tables) goes beside it as reference files.
- **Several skills.** The source covers work done at different moments or by different people, each with its own moment of use.
- **Role.** The work is a job or a team's practice that groups several skills. Create one only when no existing role fits.
- **App.** The user needs to see or act on data in a card: a dashboard, a review screen, a form. Only when a skill would open it and the workspace serves the tools it reads.
- **Tools.** When a step reads or changes a system (a CRM, a ticket tracker, a drive), attach the workspace tool that does it to the skill.
- **Connector.** When no workspace tool reaches that system, suggest the MCP server that would, and what it would let the skill do. Do not install it as part of this build: offer it as a next step (see Step 7).

## Step 5: the build summary

Before creating anything, show a short summary and wait for the user's go. Keep it to what fits on a screen:

```text
In your Skilder workspace I will build:
- Role "<name>" (new | existing): <one line>
- Skill "<name>" (new | new version of "<name>"): <description, at most 150 characters>
  - references: <file>, <file>
  - tools: <tool> (read), <tool> (write)
- App "<name>": <what it shows>, calling <tools>
Suggested next: connect <system> to give "<skill>" <what it would do>.
Left out: <credentials, personal data, anything skipped>
```

Where the source is ambiguous, ask in the same message rather than filling the gap with a guess. Change the plan as the user asks, and show the summary again if it changed in substance.

## Step 6: build

Once the user approves, create what the summary lists, with `manage`. For each kind of item, `learn` the matching guide first, so each call follows the workspace's contract rather than a guess: `Skilder Platform Assistant: Roles`, `Skilder Platform Assistant: Skills`, `Skilder Platform Assistant: Skill Content` and `Skilder Platform Assistant: Apps`. `manage`'s `describe-tool` operation documents each call.

Order: skills and their reference files, then their tools, then the role and its skills, then the App, its tools and its attachment to a skill. If one step fails, report it and continue with the others that do not depend on it.

## Step 7: report and next steps

List what was created, in which role, and what is left as a draft to publish in Skilder. If a connector was suggested, offer to add it: a workspace admin adds MCP servers in Skilder, where any credential is entered in Skilder itself and never in this conversation. With the user's go, `manage` can install one by following `Skilder Platform Assistant: MCP Servers`, preferring a server's own OAuth sign-in so no secret passes through the agent.
