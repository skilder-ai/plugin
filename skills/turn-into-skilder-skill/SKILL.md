---
name: turn-into-skilder-skill
description: Draft reusable Skilder skills from work the user has in front of them (this conversation, a pasted SOP, a transcript, a document or a link) and, once the user approves the scope, create them in the Skilder workspace as drafts. Trigger on "turn this into a skill", "save this as a Skilder skill", "make this repeatable for my team".
version: 1.0.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Turn a piece of work the user just did, or a document that describes it, into skills the whole workspace can run.

## What this skill is

| | |
|---|---|
| Applies when | The Skilder tools are listed, the user asks to turn something into a skill, and the user is a workspace admin (the `manage` tool is in the tool list). |
| Source | Only what the user points at: this conversation, text they pasted, a file or link they named. Nothing else is read. |
| What flows out | The skill text this agent drafts and the user approves, to the chosen workspace. |
| What flows in | The workspace's existing roles, skills and tools, to avoid duplicates. |
| Review | The scope is approved in the conversation before anything is created. Publishing stays a human step in Skilder. |

## Step 1: be connected

If no Skilder tool is listed, follow the `connect-to-skilder` skill first. Then call `init_skilder` with a summary such as "turn this procedure into reusable workspace skills", and keep the session id for every other call.

If `manage` is not listed, say that creating skills needs a workspace admin, then offer to draft the skill text here so the user can hand it to their admin.

## Step 2: find the source

Use what the user named. If they named nothing, use this conversation, and say so. If there is nothing to work from, ask for it and wait. If a file or link cannot be opened, say so instead of drafting from what it probably contains.

Leave out of the draft anything that looks like a credential, a personal detail about someone, or customer data. Name what you left out.

## Step 3: choose the shape, then propose it

One source may hold several skills. Pick the shape where each skill has a clear moment of use:

- one self-contained skill;
- several narrower skills, when the source covers work done at different moments or by different people;
- one short skill with reference files beside it, when the procedure is short but the checklists, templates or examples it leans on are long.

Before creating anything, show the proposal and wait for the user's go. For each skill: its name; a description of at most 150 characters saying what it does and when it applies; its reference files, one line each; the tools it would use, split into the ones the workspace already has and the ones to add; and the role it belongs to. If you split the source, say in one sentence why.

If the workspace already holds a skill covering part of this, say so and offer a new version of it rather than a near-duplicate. Where the source is ambiguous, ask rather than guess.

## Step 4: create

Once the user approves, create what was agreed with `manage`: each skill, its reference files as skill content, and its attachment to the role. `manage`'s `describe-tool` operation documents each call. Skills land as drafts.

## Step 5: report

List what was created and which role each skill went to, then point the user at the workspace library to review and publish.
