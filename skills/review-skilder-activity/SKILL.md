---
name: review-skilder-activity
description: Use when the user asks what their agent did through Skilder, such as "what did Skilder do", "which skills did that use", "show my Skilder activity" or "why did that Skilder call fail". Reads the session record through the read-only analytics tool and reports the plugins (roles), skills and tools used and how each call ended. Changes nothing.
version: 1.0.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Give the user a plain receipt of what their agent did through Skilder: which roles and skills ran, which tools they called, and how each call ended.

## What this skill is

| | |
|---|---|
| Applies when | The Skilder tools are listed and the user asks what Skilder did, in this session or recently. |
| Reads | Session and call records through the read-only `analytics` tool. It changes nothing. |
| Scope | Decided by Skilder, not by this agent: a member sees their own sessions, an admin the workspace's. The result says which, and names anything withheld. |
| What stays local | Nothing new is stored. |

## Step 1: which session

- **This conversation.** Use the session id `init_skilder` returned earlier in it.
- **Recent sessions.** Use `analytics` with `tool_name: "list-sessions"`; the default window is the last 7 days. Let the user pick one if several match.
- **No session yet.** Say there is nothing to show until a task runs through Skilder, and stop.

`analytics` takes this conversation's session id as `sessionId`, like every Skilder call. If there is none yet, call `init_skilder` with a summary such as "review recent Skilder activity" first. `analytics` with `tool_name: "describe-tool"` documents each sub-tool's input.

## Step 2: read the record

Use `analytics` with `tool_name: "get-session"` and the chosen session id in `tool_input.sessionId`. The trace lists each call with its tool, its skill, its status and its duration. When `hasMore` is true, page with `offset` before you report totals.

## Step 3: report

In a few lines:

- the task the session opened with, and the roles it used;
- each skill used, with the tools it called and what they contributed;
- any failed or refused call, with its reason, as the record states it.

Report only what the record holds. Do not rate the skills. If a skill caused a failure or a wrong first attempt, offer to report it with `feedback_skill`, one concrete defect at a time, and send it only if the user agrees.

Close by pointing to the Activity page in Skilder for the full history.
