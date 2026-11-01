#!/bin/bash
# SessionEnd hook: if the project opted in via a marker in CLAUDE.local.md,
# distill the session transcript into the performance-review artifact through a
# headless `claude -p` call running the perf-review-log skill. Silent no-op otherwise.
#
# Opt a project in: add the line `perf-review-track: true` to its CLAUDE.local.md.
# The artifact lives in $REVIEW_DIR/review.md (see skills/perf-review-log/SKILL.md).
set -uo pipefail

REVIEW_DIR="${PERF_REVIEW_DIR:-$HOME/Work/perf-review}"
LOG="$HOME/.claude/perf-review-hook.log"
MARKER="perf-review-track: true"

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"

[ -z "$cwd" ] && exit 0
[ -z "$transcript" ] && exit 0
[ -f "$transcript" ] || exit 0

marker_file="$cwd/CLAUDE.local.md"
[ -f "$marker_file" ] || exit 0
grep -qF "$MARKER" "$marker_file" || exit 0
[ -d "$REVIEW_DIR" ] || exit 0

workdir="$(mktemp -d)"
condensed="$workdir/condensed.md"
trap 'rm -rf "$workdir"' EXIT

# Keep only plain text turns (user/assistant); drop tool_use/tool_result/thinking noise.
jq -r '
  select(.message.role == "user" or .message.role == "assistant") |
  .message.content[]? |
  select(.type == "text") |
  .text
' "$transcript" > "$condensed" 2>/dev/null

[ -s "$condensed" ] || exit 0

# Cap input size; keep the tail — final outcomes are more concrete than early exploration.
MAX_BYTES=100000
if [ "$(wc -c < "$condensed")" -gt "$MAX_BYTES" ]; then
  tail -c "$MAX_BYTES" "$condensed" > "$condensed.tmp" && mv "$condensed.tmp" "$condensed"
fi

{
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') SessionEnd project=$cwd ==="
  # Scrubbed so the headless run cannot rename or badge the agterm session it was spawned from.
  env -u AGTERM_ENABLED -u AGTERM_SESSION_ID -u AGTERM_PANE -u AGTERM_PANE_ID \
    claude -p "/perf-review-log $condensed" \
    --allowedTools "Read,Edit" \
    --add-dir "$REVIEW_DIR" \
    --add-dir "$workdir" \
    --permission-mode acceptEdits \
    --max-budget-usd 1 \
    --model sonnet
  echo "--- exit code: $? ---"
} >> "$LOG" 2>&1

exit 0
