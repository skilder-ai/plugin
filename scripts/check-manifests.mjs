#!/usr/bin/env node
// Checks that the plugin's manifests agree with each other and with the
// release tag, so a client never installs a half-updated plugin.
//
//   node scripts/check-manifests.mjs            # local
//   GITHUB_REF_NAME=v0.1.0 node scripts/...     # on a tag: version must match
//
// What it checks:
//   - every manifest parses as JSON
//   - plugin.json (Agent Plugins 1.0) carries only the fields the schema allows
//   - mcp.json carries $schema and servers with only type, url, headers
//   - the three MCP configs name the same servers and the same https URLs
//   - plugin.json, .claude-plugin/plugin.json and gemini-extension.json share one version
//   - on a release tag vX.Y.Z, that version equals X.Y.Z
import { readFileSync, existsSync } from 'node:fs';

const errors = [];
const fail = (message) => errors.push(message);

const read = (path) => {
  if (!existsSync(path)) {
    fail(`${path}: missing`);
    return null;
  }
  try {
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch (error) {
    fail(`${path}: invalid JSON (${error.message})`);
    return null;
  }
};

const portable = read('plugin.json');
const portableMcp = read('mcp.json');
const claude = read('.claude-plugin/plugin.json');
const claudeMcp = read('.mcp.json');
const marketplace = read('.claude-plugin/marketplace.json');
const gemini = read('gemini-extension.json');

// Agent Plugins 1.0: closed root object.
const PORTABLE_FIELDS = new Set(['$schema', 'name', 'version', 'description', 'author', 'homepage', 'repository', 'license', 'keywords', 'extensions']);
if (portable) {
  if (portable.$schema !== 'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json') fail('plugin.json: $schema is not the Agent Plugins 1.0.0 plugin schema');
  for (const key of Object.keys(portable)) if (!PORTABLE_FIELDS.has(key)) fail(`plugin.json: field "${key}" is not allowed by the Agent Plugins schema`);
  if (!/^(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$/.test(portable.name ?? '')) fail('plugin.json: name does not match the Agent Plugins pattern');
}

// Agent Plugins 1.0: closed server entries.
const MCP_FIELDS = new Set(['type', 'url', 'headers']);
if (portableMcp) {
  if (portableMcp.$schema !== 'https://agent-plugins.org/schemas/1.0.0/mcp.schema.json') fail('mcp.json: $schema is not the Agent Plugins 1.0.0 mcp schema');
  for (const [name, server] of Object.entries(portableMcp.mcpServers ?? {})) {
    if (server.type !== 'streamable-http') fail(`mcp.json: server "${name}" must be streamable-http`);
    for (const key of Object.keys(server)) if (!MCP_FIELDS.has(key)) fail(`mcp.json: server "${name}" field "${key}" is not allowed by the Agent Plugins schema`);
    if (server.headers) fail(`mcp.json: server "${name}" declares headers; this plugin ships none (they would be visible package data)`);
  }
}

// One server list, one URL, https only.
const servers = (config, pick) => Object.fromEntries(Object.entries(config?.mcpServers ?? {}).map(([name, server]) => [name, pick(server)]));
const a = servers(portableMcp, (s) => s.url);
const b = servers(claudeMcp, (s) => s.url);
const c = servers(gemini, (s) => s.httpUrl);
const same = (x, y) => JSON.stringify(x) === JSON.stringify(y);
if (!same(a, b)) fail(`mcp.json and .mcp.json name different servers or URLs: ${JSON.stringify(a)} vs ${JSON.stringify(b)}`);
if (!same(a, c)) fail(`mcp.json and gemini-extension.json name different servers or URLs: ${JSON.stringify(a)} vs ${JSON.stringify(c)}`);
for (const [name, server] of Object.entries(claudeMcp?.mcpServers ?? {})) if (server.type !== 'http') fail(`.mcp.json: server "${name}" must be type http for the Claude directory`);
for (const url of [...Object.values(a), ...Object.values(b), ...Object.values(c)]) if (!/^https:\/\//.test(url ?? '')) fail(`MCP URL is not https: ${url}`);

// One version everywhere, equal to the tag on a release.
const versions = { 'plugin.json': portable?.version, '.claude-plugin/plugin.json': claude?.version, 'gemini-extension.json': gemini?.version };
const distinct = new Set(Object.values(versions));
if (distinct.size !== 1) fail(`versions differ: ${JSON.stringify(versions)}`);
const tag = process.env.GITHUB_REF_NAME ?? '';
if (/^v\d+\.\d+\.\d+$/.test(tag) && portable?.version !== tag.slice(1)) fail(`tag ${tag} but manifests say ${portable?.version}`);

// Marketplace points at this plugin.
if (marketplace) {
  const entry = (marketplace.plugins ?? []).find((p) => p.name === claude?.name);
  if (!entry) fail('.claude-plugin/marketplace.json: no entry named like .claude-plugin/plugin.json');
  else if (entry.source !== './' && entry.source !== '.') fail('.claude-plugin/marketplace.json: the entry must point at the repository root');
  if (entry?.version) fail('.claude-plugin/marketplace.json: leave version out of the entry; plugin.json carries it');
}

// Names agree.
if (portable && claude && portable.name !== claude.name) fail(`plugin.json name "${portable.name}" differs from .claude-plugin/plugin.json "${claude.name}"`);
if (gemini && portable && gemini.name !== portable.name) fail(`gemini-extension.json name "${gemini.name}" differs from plugin.json "${portable.name}"`);

if (errors.length) {
  for (const e of errors) console.error(`✗ ${e}`);
  process.exit(1);
}
console.log(`✔ manifests agree (version ${portable?.version}, ${Object.keys(a).length} MCP server)`);
