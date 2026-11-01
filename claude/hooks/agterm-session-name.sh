#!/bin/bash
# UserPromptSubmit / Stop / SessionStart: name the agterm session after the topic Claude Code puts in
# its terminal title, keeping a leading [prefix] the user set. After /clear only the prefix stays.
set -u

EMPTY_NAME="✳ new"

[ -n "${AGTERM_SESSION_ID:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
ctl() { agtermctl "$@" ${AGTERM_SOCKET:+--socket "$AGTERM_SOCKET"}; }

input="$(cat)"
mode=topic
case "$(printf '%s' "$input" | jq -r '.hook_event_name + ":" + (.source // "")')" in
  SessionStart:clear | SessionStart:startup) mode=reset ;;
  SessionStart:*) exit 0 ;;
  UserPromptSubmit:*) sleep 5 ;; # Claude Code retitles a few seconds after the prompt
esac

name="$(ctl tree --json ${AGTERM_WINDOW_ID:+--window "$AGTERM_WINDOW_ID"} 2>/dev/null | jq -r \
  --arg sid "$AGTERM_SESSION_ID" --arg mode "$mode" --arg empty "$EMPTY_NAME" '
  first(.result.tree.workspaces[].sessions[] | select((.id | ascii_upcase) == ($sid | ascii_upcase)))
  | (.name // "") as $name
  | ($name | if test("^\\[[^\\]]*\\]") then capture("^(?<p>\\[[^\\]]*\\])").p else "" end) as $prefix
  | (if $mode == "reset" then "" else (.title // "" | sub("^[^\\p{L}\\p{N}\\s]+\\s+"; "")) end) as $topic
  | ($topic | if . == "Claude Code" then "" else . end) as $topic
  | (if $prefix != "" then ([$prefix, $topic] | map(select(. != "")) | join(" "))
     elif $topic != "" then $topic else $empty end)
  | select(. != $name)')"

[ -n "$name" ] && ctl session rename "$name" --target "$AGTERM_SESSION_ID" >/dev/null 2>&1
[ "$mode" = reset ] && ctl session context --clear --target "$AGTERM_SESSION_ID" >/dev/null 2>&1
exit 0
