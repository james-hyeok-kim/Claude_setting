#!/usr/bin/env bash
# save.sh — live (~/.claude) → dotfiles
# Backs up current Claude config into this repo so it can be committed.
# Run: bash save.sh
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# ───────────────────────────────────────────────────────────
# helpers
# ───────────────────────────────────────────────────────────
copy_file() {
  local src="$1"
  local dst="$2"
  if [ ! -f "$src" ]; then
    echo "    skip (missing source): $src"
    return
  fi
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "    unchanged: $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "    saved: $src -> $dst"
}

sync_dir() {
  local src="$1"
  local dst="$2"
  if [ ! -d "$src" ] || [ -z "$(ls -A "$src" 2>/dev/null)" ]; then
    echo "    skip (empty/missing source dir): $src"
    return
  fi
  mkdir -p "$dst"
  local will_change
  will_change="$(rsync -ain "$src/" "$dst/" 2>/dev/null | grep -v '^\.' || true)"
  if [ -n "$will_change" ]; then
    rsync -a "$src/" "$dst/"
    echo "    synced dir: $src -> $dst/"
  else
    echo "    dir unchanged: $dst"
  fi
}

# ───────────────────────────────────────────────────────────
# save
# ───────────────────────────────────────────────────────────
echo "=== Saving ~/.claude → dotfiles/claude ==="
echo "    CLAUDE_HOME:  $CLAUDE_HOME"
echo "    DOTFILES_DIR: $DOTFILES_DIR"
echo ""

echo "[1/5] CLAUDE.md (global rules)"
copy_file "$CLAUDE_HOME/CLAUDE.md" "$DOTFILES_DIR/claude/CLAUDE.md"

echo ""
echo "[2/5] settings.json (user preferences)"
copy_file "$CLAUDE_HOME/settings.json" "$DOTFILES_DIR/claude/settings.json"
# NOTE: settings.local.json intentionally skipped (machine-local, in .gitignore)

echo ""
echo "[3/5] plugins/known_marketplaces.json"
copy_file "$CLAUDE_HOME/plugins/known_marketplaces.json" \
          "$DOTFILES_DIR/claude/plugins/known_marketplaces.json"

echo ""
echo "[4/5] agents/ (user-level agents)"
sync_dir "$CLAUDE_HOME/agents" "$DOTFILES_DIR/claude/agents"

echo ""
echo "[5/5] skills/ (user-level skills)"
sync_dir "$CLAUDE_HOME/skills" "$DOTFILES_DIR/claude/skills"

echo ""
echo "=== Done — review changes with: git -C $DOTFILES_DIR diff ==="
echo "Commit when ready: git -C $DOTFILES_DIR add -p && git -C $DOTFILES_DIR commit"
