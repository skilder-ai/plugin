#!/usr/bin/env node
// Lints the wording of every skill and command in this plugin against the
// patterns that plugin scanners (Snyk agent-scan, the Claude directory's
// security scan) and marketplace policies flag:
//   - unconditional coercion: "always", "never ask", "without further questions",
//     "proceed without", "do not ask"
//   - Skilder tool names in prose instead of code spans
//   - the endpoint URL in a body (it belongs in frontmatter metadata and in code blocks)
//   - a frontmatter without name, description, version
//   - an unquoted frontmatter value holding ": ", which YAML reads as a nested mapping
//
//   node scripts/lint-skills.mjs
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

// Only the names that are not also ordinary English words; `learn`, `manage`,
// `display`, `analytics` and `delegate` read fine as verbs or nouns in prose.
const TOOL_NAMES = ['init_skilder', 'run_read_tool', 'run_write_tool', 'execute_script', 'read_skilder_file', 'upload_skilder_file', 'feedback_skill', 'display_action', 'open_app', 'app_action', 'describe-tool'];
const COERCION = [/\balways\b/i, /\bnever ask\b/i, /without further questions/i, /\bproceed without\b/i, /\bdo not ask\b/i];

const files = [];
const walk = (dir) => {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path);
    else if (/\.md$/.test(entry)) files.push(path);
  }
};
walk('skills');
walk('claude');

const errors = [];
for (const file of files) {
  const text = readFileSync(file, 'utf8');
  const [, frontmatter = ''] = text.match(/^---\n([\s\S]*?)\n---/) ?? [];
  const isSkill = /SKILL\.md$/.test(file);
  for (const key of isSkill ? ['name', 'description', 'version'] : ['description']) {
    if (!new RegExp(`^${key}:`, 'm').test(frontmatter)) errors.push(`${file}: frontmatter has no ${key}`);
  }
  if (isSkill) {
    const [, version = ''] = frontmatter.match(/^version:\s*(\S+)/m) ?? [];
    if (version && !/^[1-9]\d*\.\d+\.\d+$/.test(version)) errors.push(`${file}: version ${version} is below 1.0.0`);
  }
  frontmatter.split('\n').forEach((line) => {
    const [, key, value = ''] = line.match(/^([\w-]+):\s*(.*)$/) ?? [];
    if (key && !/^["'|>]/.test(value) && /:\s/.test(value)) errors.push(`${file}: frontmatter ${key} holds ": " unquoted; YAML reads it as a nested mapping`);
  });
  const body = text.replace(/^---\n[\s\S]*?\n---/, '');
  const prose = body.replace(/```[\s\S]*?```/g, '').replace(/`[^`\n]*`/g, '');
  prose.split('\n').forEach((line, i) => {
    const at = `${file}:${i + 1}`;
    for (const pattern of COERCION) if (pattern.test(line)) errors.push(`${at}: coercive wording "${line.match(pattern)[0]}"`);
    for (const name of TOOL_NAMES) {
      const bare = new RegExp(`(^|[^\\w\`-])${name.replace(/[-]/g, '\\-')}(?=$|[^\\w-])`);
      if (bare.test(line)) errors.push(`${at}: tool name "${name}" outside a code span`);
    }
    if (/https?:\/\/app\.skilder\.ai\/mcp/.test(line)) errors.push(`${at}: endpoint URL in prose; keep it in frontmatter metadata or a code block`);
  });
}

if (errors.length) {
  for (const e of errors) console.error(`✗ ${e}`);
  process.exit(1);
}
console.log(`✔ ${files.length} skill and command files pass the wording lint`);
