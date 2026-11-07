# Security

## What this package does, in full

- It configures one remote MCP server, `https://app.skilder.ai/mcp`, operated by skilder.ai SA. Sign-in is OAuth 2.1 in the user's browser; the package carries no key, token or secret.
- It ships seven skills, which are text files.
- It bundles no executable, no local server, no package install, and writes nothing on the user's machine.

Everything an agent does with Skilder goes through that MCP server and is recorded in the user's workspace, where its admins see it in Activity and where the user revokes an application under Personal settings → Connected apps.

## Reporting a vulnerability

Email security@skilder.ai. Include the plugin version (`plugin.json`), the client, and what you observed. We acknowledge within 3 business days and keep you informed until the fix is published.

Please do not open a public issue for a vulnerability.
