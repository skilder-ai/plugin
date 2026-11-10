#!/bin/sh
# Builds the ZIP that the ChatGPT + Codex plugin directory takes on
# platform.openai.com/plugins. The archive carries the portable plugin only:
# plugin.json, mcp.json, skills/, the two listing icons, LICENSE, and the README and
# SECURITY written for that directory (openai/). Everything Claude Code reads
# (claude/, .claude-plugin/, .mcp.json), the other clients' manifests and the
# repository's own README and SECURITY stay out: a plugin that ships, or
# describes, lifecycle hooks is not eligible for that directory. The README
# images (demo.jpg, platform-*.svg) stay out too: with them the directory's
# review reported hooks on a package that had none (2026-11).
#
# Usage: scripts/package-openai.sh            -> dist/skilder-openai-<version>.zip
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

version=$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' plugin.json | head -n 1)
[ -n "$version" ] || { echo "plugin.json has no version" >&2; exit 1; }

mkdir -p dist
out="$root/dist/skilder-openai-$version.zip"
rm -f "$out"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
cp -R plugin.json mcp.json skills LICENSE "$stage/"
mkdir "$stage/assets"
cp assets/icon.png assets/logo.png "$stage/assets/"
cp openai/README.md openai/SECURITY.md "$stage/"

(cd "$stage" && zip -r -X "$out" \
  plugin.json mcp.json skills assets README.md LICENSE SECURITY.md \
  -x '*/.DS_Store' '.DS_Store' >/dev/null)

echo "dist/skilder-openai-$version.zip"
unzip -Z1 "$out" | sed 's/^/  /'
