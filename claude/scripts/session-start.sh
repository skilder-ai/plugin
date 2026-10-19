#!/bin/sh
# SessionStart hook of the Skilder plugin (Claude Code, Cowork).
#
# Reads the SessionStart event on stdin and prints one JSON object on stdout
# that adds a line of context. It reads nothing but stdin and the plugin's own
# data directory, writes nothing, and makes no network call.
#
# On a resumed or compacted conversation (source "resume" or "compact") it also
# offers the Skilder session id that remember-session.sh stored for this
# project, when that id is less than 24 hours old. On "startup", "clear" and
# "fork" it offers nothing: a new conversation starts a new Skilder session.
set -u

input=$(cat)

field() {
  # field <name>: the string value of a top-level JSON string field, or empty.
  printf '%s' "$input" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}

source_kind=$(field source)
cwd=$(field cwd)

context='If Skilder tools are listed, start a task by calling init_skilder with a one-sentence summary you write, keep the session id it returns for every other Skilder call, and learn the role before acting (skill: using-skilder).'

if [ "$source_kind" = "resume" ] || [ "$source_kind" = "compact" ]; then
  data_dir=${CLAUDE_PLUGIN_DATA:-}
  if [ -n "$data_dir" ] && [ -n "$cwd" ]; then
    key=$(printf '%s' "$cwd" | cksum | cut -d ' ' -f 1)
    file="$data_dir/sessions/$key"
    if [ -f "$file" ]; then
      session_id=$(sed -n 's/^sessionId=\(sks-[0-9a-fA-F-]*\)$/\1/p' "$file" | head -n 1)
      created_at=$(sed -n 's/^createdAt=\([0-9]*\)$/\1/p' "$file" | head -n 1)
      now=$(date +%s)
      if [ -n "$session_id" ] && [ -n "$created_at" ] && [ $((now - created_at)) -lt 86400 ]; then
        hours=$(( (now - created_at) / 3600 ))
        context="$context A Skilder session from this conversation, $session_id, started $hours h ago in this project. Pass it as sessionId to continue it, or call init_skilder for a new one if the task changed."
      fi
    fi
  fi
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$context"
exit 0
