#!/bin/sh
# Builds the Microsoft 365 app package that Copilot Cowork installs:
# dist/skilder-cowork-<version>.zip, a manifest.json with every skill and
# one connector to the Skilder MCP server, plus the two icons.
#
# Microsoft's own converter does the work: `atk import openplugin` reads
# .claude-plugin/plugin.json, .mcp.json and skills/ and scaffolds an Agents
# Toolkit project. This script then adjusts what the converter cannot know:
#   - the connector carries no `authorization` block: Cowork registers its own
#     OAuth client (dynamic client registration), which Skilder accepts
#   - the package has its own version, in scripts/cowork-version: Microsoft
#     updates an installed app only to a higher version, so raise it with every
#     package this script publishes and never lower it
#   - the outline icon is the logo's silhouette in white on transparent
#
# Usage: scripts/package-cowork.sh            (needs node, npx, ImageMagick `magick`)
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
m365_version=$(tr -d '[:space:]' < scripts/cowork-version)
printf '%s' "$m365_version" | grep -Eq '^[1-9][0-9]*\.[0-9]+\.[0-9]+$' || { echo "scripts/cowork-version is not a version from 1.0.0 up" >&2; exit 1; }

# A real path: the converter refuses a symlinked output path, and macOS temp
# directories live behind the /var -> /private/var link.
work=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/src"
git archive HEAD | tar -x -C "$work/src"
magick assets/logo.png -resize 192x192 -background white -alpha remove -alpha off "$work/src/color.png"
magick assets/logo.png -resize 32x32 -fill white -colorize 100% "$work/src/outline.png"

npx -y @microsoft/m365agentstoolkit-cli@1.1.18 import openplugin \
  --path "$work/src" --output "$work/project" \
  --privacy-url https://www.skilder.ai/en/privacy \
  --terms-url https://www.skilder.ai/en/terms \
  --website-url https://www.skilder.ai

node - "$work/project/appPackage/manifest.json" "$m365_version" <<'EOF'
const fs = require('fs');
const [path, version] = process.argv.slice(2);
const m = JSON.parse(fs.readFileSync(path, 'utf8'));
m.version = version;
m.accentColor = '#06B6D4';
m.description.short = 'The entry point to your Skilder workspace: plugins, skills, MCP tools and Apps';
const c = m.agentConnectors[0];
c.displayName = 'Skilder workspace';
c.description = "Skilder's MCP server: the plugins, skills, tools and Apps your workspace publishes, served live. Sign-in opens in the browser; Cowork registers its own OAuth client.";
delete c.toolSource.remoteMcpServer.authorization;
fs.writeFileSync(path, JSON.stringify(m, null, 4) + '\n');
EOF

mkdir -p dist
out="$root/dist/skilder-cowork-$m365_version.zip"
(cd "$work/project" && npx -y @microsoft/m365agentstoolkit-cli@1.1.18 package \
  --manifest-file ./appPackage/manifest.json \
  --output-package-file "$out" --output-folder ./appPackage/build >/dev/null)
(cd "$work/project" && npx -y @microsoft/m365agentstoolkit-cli@1.1.18 validate --package-file "$out" 2>&1 | grep -E 'failed|passed|\(×\)' || true)
echo "$out"
unzip -Z1 "$out" | sed 's/^/  /'
