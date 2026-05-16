#!/usr/bin/env bash
# dotfiles installer for Claude Code config
# Run: bash install.sh
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# ───────────────────────────────────────────────────────────
# helpers
# ───────────────────────────────────────────────────────────
backup_file() {
  local target="$1"
  # only back up if it exists AND differs from source we're about to write
  local src_for_diff="$2"
  if [ -e "$target" ]; then
    if [ -n "$src_for_diff" ] && cmp -s "$target" "$src_for_diff"; then
      # identical — no backup, no-op
      return 1
    fi
    cp -r "$target" "${target}.bak.${TIMESTAMP}"
    echo "    backup: ${target} -> ${target}.bak.${TIMESTAMP}"
  fi
  return 0
}

copy_file() {
  local src="$1"
  local dst="$2"
  if [ ! -f "$src" ]; then
    echo "    skip (missing source): $src"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if backup_file "$dst" "$src"; then
    cp "$src" "$dst"
    echo "    copied: $(basename "$src") -> $dst"
  else
    echo "    unchanged: $dst"
  fi
}

sync_dir() {
  # sync source dir contents INTO destination dir (no nesting)
  # preserves user-added files in dst not present in src (no --delete)
  local src="$1"
  local dst="$2"
  if [ ! -d "$src" ] || [ -z "$(ls -A "$src" 2>/dev/null)" ]; then
    echo "    skip (empty/missing source dir): $src"
    return
  fi
  mkdir -p "$dst"
  # one-time snapshot of dst before sync (only if anything will change)
  local will_change
  will_change="$(rsync -ain "$src/" "$dst/" 2>/dev/null | grep -v '^\.' || true)"
  if [ -n "$will_change" ]; then
    if [ -d "$dst" ] && [ -n "$(ls -A "$dst" 2>/dev/null)" ]; then
      cp -r "$dst" "${dst}.bak.${TIMESTAMP}"
      echo "    backup dir: ${dst} -> ${dst}.bak.${TIMESTAMP}"
    fi
    rsync -a "$src/" "$dst/"
    echo "    synced dir: $src -> $dst/"
  else
    echo "    dir unchanged: $dst"
  fi
}

# ───────────────────────────────────────────────────────────
# install
# ───────────────────────────────────────────────────────────
echo "=== Installing dotfiles to $CLAUDE_HOME ==="
echo "    DOTFILES_DIR: $DOTFILES_DIR"
echo "    TIMESTAMP:    $TIMESTAMP"
echo ""

echo "[1/5] CLAUDE.md (global rules)"
copy_file "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

echo ""
echo "[2/5] settings.json (user preferences)"
copy_file "$DOTFILES_DIR/claude/settings.json" "$CLAUDE_HOME/settings.json"
# NOTE: settings.local.json is intentionally skipped (in .gitignore, machine-local)

echo ""
echo "[3/5] plugins/known_marketplaces.json"
copy_file "$DOTFILES_DIR/claude/plugins/known_marketplaces.json" \
          "$CLAUDE_HOME/plugins/known_marketplaces.json"

echo ""
echo "[4/5] agents/ (user-level agents)"
sync_dir "$DOTFILES_DIR/claude/agents" "$CLAUDE_HOME/agents"

echo ""
echo "[5/5] skills/ (user-level skills)"
sync_dir "$DOTFILES_DIR/claude/skills" "$CLAUDE_HOME/skills"

echo ""
echo "=== Done ==="
echo ""
echo "Note: snapshot_* directories in dotfiles/claude/ are point-in-time backups"
echo "and are NOT copied to \$HOME (they live only in the dotfiles repo)."
echo "Note: ~/.claude/.credentials.json is never touched by this script."
