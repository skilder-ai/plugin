#!/bin/sh
# PostToolUse hook of the Skilder plugin, matched on the init_skilder tool.
#
# Reads the PostToolUse event on stdin and writes one small file in the
# plugin's data directory: the Skilder session id init_skilder returned, when
# it was returned, and the task summary the agent sent. Nothing else from the
# response is kept. The file is readable by the current user only
# (mode 0600). session-start.sh reads it to offer the id again on a resumed
# conversation. No network call, no other write.
set -u

input=$(cat)

data_dir=${CLAUDE_PLUGIN_DATA:-}
[ -n "$data_dir" ] || exit 0

one_line=$(printf '%s' "$input" | tr -d '\n')

cwd=$(printf '%s' "$one_line" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$cwd" ] || exit 0

# The session id appears once in the response text as `sks-<uuid>`.
session_id=$(printf '%s' "$one_line" | grep -o 'sks-[0-9a-fA-F][0-9a-fA-F-]*' | head -n 1)
[ -n "$session_id" ] || exit 0

# Escaped quotes inside the summary become apostrophes, so the field reads whole.
task_summary=$(printf '%s' "$one_line" | sed 's/\\"/'"'"'/g' | sed -n 's/.*"task_summary"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1 | cut -c 1-200)

key=$(printf '%s' "$cwd" | cksum | cut -d ' ' -f 1)
umask 077
mkdir -p "$data_dir/sessions" || exit 0
{
  printf 'sessionId=%s\n' "$session_id"
  printf 'createdAt=%s\n' "$(date +%s)"
  printf 'taskSummary=%s\n' "$task_summary"
} > "$data_dir/sessions/$key"
exit 0
