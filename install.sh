#!/usr/bin/env bash
# Link this repo into ~/.claude. Idempotent; existing non-symlink files are backed up with a .bak suffix.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO/claude"
CLAUDE="$HOME/.claude"
mkdir -p "$CLAUDE/hooks" "$CLAUDE/skills"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "backed up $dst -> $dst.bak"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

link "$SRC/CLAUDE.md" "$CLAUDE/CLAUDE.md"
for h in "$SRC"/hooks/*.sh; do
  chmod +x "$h"
  link "$h" "$CLAUDE/hooks/$(basename "$h")"
done
for s in "$SRC"/skills/*/; do
  s="${s%/}"
  link "$s" "$CLAUDE/skills/$(basename "$s")"
done

mkdir -p "$HOME/AI/english-learning" "${PERF_REVIEW_DIR:-$HOME/Work/perf-review}" \
  "$HOME/AI/ai-setup-private/claude/memory-audit"

cat <<EOF

Done. Now merge claude/settings.snippet.json into ~/.claude/settings.json (hooks + plugin toggles),
then open /hooks once in a running session or restart Claude Code.
EOF
