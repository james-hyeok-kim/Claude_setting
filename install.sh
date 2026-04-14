#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  backup: $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "  linked: $dst -> $src"
}

echo "=== Installing dotfiles ==="

# Claude Code
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

echo "=== Done ==="
