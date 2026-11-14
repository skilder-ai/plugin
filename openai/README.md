# Skilder for ChatGPT and Codex

[Skilder](https://skilder.ai) brings your team's skills to ChatGPT, the same ones your other agents use.

Your team writes its skills, tools and MCP Apps once in a Skilder workspace and groups them into plugins. ChatGPT, Codex and any other MCP client the team uses read those same plugins. When a skill changes in the workspace, every agent gets the new version on its next task, with nothing to reinstall.

The workspace stays in charge. Admins decide who gets which plugin, guardrails check tool calls before they run, and every call is recorded in Activity, whichever agent made it.

## Get started

1. Install Skilder from the plugin directory.
2. On the first Skilder call, a browser sign-in opens on app.skilder.ai. Sign in, pick one workspace and press Approve. Nothing is granted before that press.
3. Ask "Hey Skilder, get me started". Skilder describes what the workspace holds and runs a first task with you.

A Skilder account is required. Documentation: [docs.skilder.ai](https://docs.skilder.ai).

## How a task runs

1. ChatGPT calls `init_skilder` with a one-sentence summary of the task. Skilder answers with the workspace's plugins and a session id, and names the one that fits where the workspace has suggestion on.
2. ChatGPT learns the plugin, then the skill the task needs.
3. ChatGPT runs the skill's tools, opens its MCP Apps in the conversation, and carries the session id on each call. Skilder applies the workspace's permissions and guardrails and records each call.

## What this package contains, in full

| | |
|---|---|
| Server | One remote MCP server, `https://app.skilder.ai/mcp`, Streamable HTTP, operated by skilder.ai SA ([privacy](https://www.skilder.ai/en/privacy), [terms](https://www.skilder.ai/en/terms)). |
| Credentials | None in the package. OAuth 2.1 in the browser; the token is issued to the client and stored by it. |
| Skills | Seven text files under `skills/`: using-skilder, get-started-with-skilder, connect-to-skilder, capture-work-in-skilder, import-skills-to-skilder, list-or-build-skilder-apps, review-skilder-activity. |
| Code | None. No executable, no local server, no package install. |
| What flows out | The one-sentence task summary and the tool calls made against the chosen workspace, recorded there for its admins under a session. |
| What flows in | The plugins, skills, tool schemas, files and MCP Apps the workspace's own builders published. |
| Revoke | Personal settings → Connected apps in Skilder. |

Support: [github.com/skilder-ai/plugin/issues](https://github.com/skilder-ai/plugin/issues) · Security: [SECURITY.md](SECURITY.md)

## License

MIT
