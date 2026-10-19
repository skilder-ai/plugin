#!/bin/sh
# Builds the ZIP that the ChatGPT + Codex plugin directory takes on
# platform.openai.com/plugins. The archive carries the portable plugin only:
# plugin.json, mcp.json, skills/, assets/, README.md, LICENSE, SECURITY.md.
# Everything Claude Code reads (claude/, .claude-plugin/, .mcp.json) and the
# other clients' manifests stay out, because a plugin that ships lifecycle
# hooks is not eligible for that directory.
#
# Usage: scripts/package-openai.sh            -> dist/skilder-openai-<version>.zip
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

version=$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' plugin.json | head -n 1)
[ -n "$version" ] || { echo "plugin.json has no version" >&2; exit 1; }

mkdir -p dist
out="dist/skilder-openai-$version.zip"
rm -f "$out"

zip -r -X "$out" \
  plugin.json mcp.json skills assets README.md LICENSE SECURITY.md \
  -x '*/.DS_Store' '.DS_Store'

echo "$out"
unzip -Z1 "$out" | sed 's/^/  /'
