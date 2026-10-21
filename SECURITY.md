# Security

## What this plugin does, in full

- It configures one remote MCP server, `https://app.skilder.ai/mcp`, operated by skilder.ai SA. Sign-in is OAuth 2.1 in the user's browser; the plugin carries no key, token or secret.
- It ships three skills (text files) and, for Claude Code and Cowork, one command and two hooks. The hooks are plain shell scripts: one adds a line of context at session start, the other writes a small file (`sessionId`, `createdAt`, `taskSummary`) under the plugin's data directory, mode 0600, so a resumed conversation can continue its Skilder session. Neither makes a network call or changes any permission.
- It bundles no executable, no stdio server, no package install.

Everything an agent does with Skilder goes through that MCP server and is recorded in the user's workspace, where its admins see it in Activity and where the user revokes an application under Personal settings → Connected apps.

## Reporting a vulnerability

Email security@skilder.ai. Include the plugin version (`plugin.json`), the client, and what you observed. We acknowledge within 3 business days and keep you informed until the fix is published.

Please do not open a public issue for a vulnerability.

## Releases and withdrawal

- Every release is a signed tag `vX.Y.Z` on a protected `main`; the manifests' `version` equals the tag, enforced by CI.
- The directories (Anthropic, OpenAI, Gemini, Grok) are pointed at tags, not at `main`.
- If a published version has to be withdrawn: delist it in the directory's portal, publish a fixed version with a raised `version`, and, if a grant could be at risk, revoke it server-side from Connected apps. Uninstalling the plugin does not revoke a grant; Connected apps does.
