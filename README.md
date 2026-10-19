# Skilder plugin

[![Live on skills.sh](https://img.shields.io/badge/skills.sh-skilder--ai%2Fplugin-0e7490)](https://skills.sh/skilder-ai/plugin)

The entry point to a [Skilder](https://skilder.ai) workspace, for any AI agent that installs plugins. Skilder is where a team builds, shares and governs the skills and tools its agents use at work. This plugin connects the agent to the team's workspace over MCP and teaches it the way Skilder works: start the task, learn the role, then act, with a session id on every call.

The roles, skills, tools and Apps themselves stay in the workspace, versioned and governed there, and are served live. Nothing of that content is bundled here.

## Install

| Client | How |
|---|---|
| Claude Code | `claude plugin marketplace add skilder-ai/plugin` then `claude plugin install skilder@skilder-ai` |
| claude.ai, Claude Desktop, Cowork | Customize › Plugins › Add, from this repository (the directory listing follows) |
| GitHub Copilot CLI | `copilot plugin install skilder-ai/plugin` |
| Codex, ChatGPT | From the plugin directory once listed; until then, add this repository as a plugin marketplace in Codex |
| Gemini CLI | `gemini extensions install https://github.com/skilder-ai/plugin` |
| Any agent, skills only | `npx skills add skilder-ai/plugin` |

The first Skilder call opens a browser sign-in on app.skilder.ai. The user signs in, picks one workspace and presses Approve. Nothing is granted before that press.

If a `skilder` or `skilder-ai` server was added to the client by hand before the plugin, remove that entry: the plugin's server points at the same endpoint, and the duplicate costs a second sign-in.

## What the plugin does, in full

| | |
|---|---|
| Server | One remote MCP server, `https://app.skilder.ai/mcp`, Streamable HTTP, operated by skilder.ai SA ([privacy](https://www.skilder.ai/en/privacy), [terms](https://www.skilder.ai/en/terms)). |
| Credentials | None in the plugin. OAuth 2.1 in the browser; the token is issued to the MCP client and stored by it. |
| What flows out | The one-sentence task summary the agent writes for `init_skilder`, and the tool calls it makes against the chosen workspace. Both are recorded in that workspace for its admins, under a session. |
| What flows in | The roles, skills, tool schemas, files and Apps the workspace's own admins published. |
| What stays local | On Claude Code and Cowork only: one small file per project under the plugin's data directory, mode 0600, holding the Skilder session id, when it was issued and the task summary, so a resumed conversation can continue its session. Nothing else is written. |
| Revoke | Personal settings → Connected apps in Skilder. Removing the server from the client stops that client from using the grant. |

## What is inside

| Path | Loaded by | Purpose |
|---|---|---|
| `skills/using-skilder` | every client | The entry protocol: `init_skilder` with a task summary, learn the role then the skill, the session id on every call, read vs write, files, Apps, feedback, and what each refusal means. |
| `skills/connect-to-skilder` | every client | Connects a client that has no Skilder server yet: discloses the connection, asks once, adds the entry, hands over to the browser sign-in. Recognises the plugin's own server and never adds a duplicate. |
| `skills/import-skills-to-skilder` | every client | Imports the Agent Skills already on the machine into the workspace, as drafts, for a workspace admin. |
| `claude/commands/skilder.md` | Claude Code, Cowork | `/skilder <task>`: summarises the task, calls `init_skilder`, reports the suggested role, learns it. |
| `claude/hooks.json` + `claude/scripts/` | Claude Code, Cowork | Two shell hooks: a line of context at session start; the session id remembered per project for a resumed conversation. No network, no permission change. |
| `plugin.json`, `mcp.json` | Codex, Copilot, Cursor, VS Code, Kiro | The Agent Plugins 1.0 manifest and MCP configuration. |
| `.claude-plugin/`, `.mcp.json` | Claude | The Claude plugin manifest, the marketplace and the MCP configuration. |
| `gemini-extension.json` | Gemini CLI | The extension manifest. |

The skills follow the open [Agent Skills](https://agentskills.io) format, and the plugin the [Agent Plugins 1.0](https://agent-plugins.org) standard, with the Claude manifest alongside.

## How a task runs

1. The agent calls `init_skilder` with a one-sentence summary of the task it wrote itself. Skilder answers with the role that fits, or candidates, or the catalog, and a session id.
2. The agent learns the role, then the skill the task needs. With session tracking on, a tool is runnable only once its skill has been learned in that session.
3. The agent runs the skill's tools through `run_read_tool` and `run_write_tool`, or its scripts through `execute_script`, with the session id. Skilder applies the workspace's permissions and guardrails and records each call.
4. At the end, `feedback_skill` tells the skill's authors what worked.

Docs: [docs.skilder.ai](https://docs.skilder.ai) · Issues: [github.com/skilder-ai/plugin/issues](https://github.com/skilder-ai/plugin/issues) · Security: [SECURITY.md](SECURITY.md)

## Develop

```bash
node scripts/check-manifests.mjs   # the manifests agree, and match the tag on a release
node scripts/lint-skills.mjs       # wording that scanners flag
claude plugin validate . --strict  # the Claude manifest, hooks and skills
scripts/package-openai.sh          # dist/skilder-openai-<version>.zip for the OpenAI directory
```

A release is a tag `vX.Y.Z` whose version equals the manifests'. The directories follow tags.

## License

MIT
