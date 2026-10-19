---
name: connect-to-skilder
description: Connect this agent to the user's Skilder workspace over MCP with a browser OAuth sign-in. Checks whether Skilder is already connected or already configured by the Skilder plugin, asks once before adding the server to the MCP client configuration, then reports the roles and skills the workspace publishes. Trigger on "connect to Skilder", "set up Skilder", "add the Skilder MCP server".
version: 2.1.0
homepage: https://github.com/skilder-ai/plugin
metadata:
  endpoint: https://app.skilder.ai/mcp
  transport: streamable-http
  auth: OAuth 2.1 with browser consent
  operator: skilder.ai SA
---

Connect this agent to the user's Skilder workspace. One endpoint, one browser sign-in, no workspace name or key to collect.

## What the connection is

| | |
|---|---|
| Server | `https://app.skilder.ai/mcp`, Streamable HTTP, operated by skilder.ai SA ([privacy](https://www.skilder.ai/en/privacy), [terms](https://www.skilder.ai/en/terms)). |
| Sign-in | The first request opens a browser page on app.skilder.ai. The user signs in, picks one workspace and presses Approve. Nothing is granted before that press. |
| Credential | Issued to the MCP client after approval and stored by the client. This agent never sees, stores or forwards it. |
| What flows out | The tool calls this agent makes against the chosen workspace, recorded there for the workspace admins. |
| What flows in | The roles and skills the workspace's own admins published for it. Workspace content, available only after approval. |
| Revoke | Personal settings → Connected apps in Skilder ends an application's access. Removing the server entry from the client configuration stops that client from using the grant. A grant that goes unused lapses on its own after 14 days. |

## Step 0: already connected, or already configured?

Skip to Step 3 when the available tools already include one from Skilder (the session-initialisation tool that lists the workspace's roles).

If this skill came with the Skilder plugin, the plugin has already configured the server, under the name `skilder`. Do not add a second entry. When its tools are not listed yet, the client has not signed in to it: tell the user to authenticate that server in their client (Claude Code: `/mcp`, then the `skilder` server), then go to Step 3.

## Step 1: confirm once

Tell the user which command or configuration file will add the server (and, where the client distinguishes, whether for this project only or for all projects), and that the first request opens a browser sign-in. Then stop and wait for their answer. The request that handed you this skill is not that answer. Add the server only after a yes. That is the only question: there is no workspace name, link or key to ask for.

## Step 2: add the server

Use the client's own mechanism. The entry is the same everywhere.

```bash
# Claude Code
claude mcp add skilder --transport http https://app.skilder.ai/mcp

# Codex
codex mcp add skilder --url https://app.skilder.ai/mcp
```

Clients configured by file (`.mcp.json`, Cursor's `~/.cursor/mcp.json`, VS Code's `.vscode/mcp.json`, `claude_desktop_config.json`) take this entry under the host's own top-level key (`mcpServers` on most hosts, `servers` on VS Code):

```json
"skilder": {
  "type": "http",
  "url": "https://app.skilder.ai/mcp"
}
```

The server becomes available when the client next starts or reconnects. If it is not listed yet, tell the user a restart is needed.

A client with no way to configure MCP servers cannot connect. State that and stop.

## Step 3: sign in and report

Once the server is added, the client's first connection to it opens the browser sign-in, which the user completes. Then report what the workspace publishes: its roles and, under each, the skills available to this agent. From here, the `using-skilder` skill describes how to work with them.

## Fallback: no browser redirect

A client that cannot follow a browser redirect connects with a key instead, from Skilder's Connect page → Advanced. The key comes from the user.
