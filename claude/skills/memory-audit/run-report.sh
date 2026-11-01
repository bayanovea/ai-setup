#!/bin/bash
# Headless memory audit, launched weekly by launchd; runs only if the last report is 13+ days old.
# The mechanical checks are done here (deterministic) and handed to the model in the prompt.
set -u
P="$HOME/.claude/projects"
OUT="$HOME/AI/ai-setup-private/claude/memory-audit"   # outside ~/.claude: headless writes there are refused
mkdir -p "$OUT"
last=$(ls -t "$OUT"/*.md 2>/dev/null | head -1)
if [ -n "$last" ] && [ "$(find "$last" -mtime -13)" ]; then
  echo "$(date '+%F %T') skip: last report $(basename "$last") is newer than 13 days"; exit 0
fi

checks=$(
  cd "$P" || exit 1
  for d in ./*/memory; do
    [[ "$d" == *scratchpad* ]] && continue
    ls "$d"/*.md >/dev/null 2>&1 || continue
    proj=${d#./}; proj=${proj%/memory}
    if [ -n "$last" ]; then
      newer=$(find "./$proj" -maxdepth 1 -name '*.jsonl' -newer "$last" | head -1)
      [ -z "$newer" ] && { echo "SKIP $proj (no sessions since $(basename "$last"))"; continue; }
    fi
    n=$(ls "$d"/*.md | wc -l | tr -d ' '); b=$(cat "$d"/*.md | wc -c | tr -d ' ')
    i=$(grep -c '^- \[' "$d/MEMORY.md" 2>/dev/null || echo 0)
    echo "PROJECT $proj: $n files, $b bytes, $i index lines"
    grep -oh '\[\[[^]]*\]\]' "$d"/*.md 2>/dev/null | sort -u | tr -d '[]' | while read -r l; do
      [ -f "$d/$l.md" ] || echo "  dangling link [[${l}]]"; done
    for f in "$d"/*.md; do bn=$(basename "$f"); [ "$bn" = MEMORY.md ] && continue
      grep -q "($bn)" "$d/MEMORY.md" 2>/dev/null || echo "  not indexed: $bn"; done
    grep -o '\]([a-zA-Z0-9_.-]*\.md)' "$d/MEMORY.md" 2>/dev/null | sed 's/^](//; s/)$//' | while read -r bn; do
      [ -f "$d/$bn" ] || echo "  index line without file: $bn"; done
    find "$d" -name '*.md' -size +2k | sed 's|.*/|  over 2 KB: |'
  done
)

echo "$(date '+%F %T') start"
cd "$(dirname "$(realpath "$0")")/../../.." && /opt/homebrew/bin/claude -p "/memory-audit --report

Previous report: ${last:-none}. Report path: $OUT/$(date +%F).md
Mechanical checks (already computed; list them in the report, do not edit memory files):
$checks" \
  --model sonnet \
  --permission-mode acceptEdits \
  --allowedTools "Read,Write,Bash(ls:*),Bash(cat:*),Bash(grep:*),Bash(head:*)" \
  --add-dir "$HOME/.claude/projects" "$HOME/AI" "$HOME/Web" \
  --max-turns 120
echo "$(date '+%F %T') done rc=$?"
