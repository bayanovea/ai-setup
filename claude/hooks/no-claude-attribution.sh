#!/bin/bash
# Blocks git commits / PRs whose text carries Claude attribution (settings.attribution is off, but
# the model sometimes types the trailer by hand).
cmd=$(jq -r '.tool_input.command // empty')
grep -qE 'git[^|;&]* commit|gh (pr|release|issue)' <<<"$cmd" || exit 0
if grep -qiE 'Co-Authored-By:[^\n]*(Claude|anthropic)|noreply@anthropic\.com|Generated with \[?Claude' <<<"$cmd"; then
  echo "Blocked: no Claude attribution (Co-Authored-By / 'Generated with Claude Code') in commits or PRs. Remove it and retry." >&2
  exit 2
fi
exit 0
