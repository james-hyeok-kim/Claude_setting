#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ]; then
    echo "  backup: $dst -> $dst.bak"
    cp -r "$dst" "$dst.bak"
  fi

  cp -r "$src" "$dst"
  echo "  copied: $src -> $dst"
}

echo "=== Installing dotfiles ==="

# Claude Code
copy "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
copy "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

echo "=== Done ==="
