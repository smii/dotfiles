#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIGS="$DOTFILES/configs"
SHELL="$DOTFILES/shell/bash"

mkdir -p "$CONFIGS" "$SHELL"

move_cfg() {
  local name="$1"
  if [[ -d "$HOME/.config/$name" && ! -L "$HOME/.config/$name" ]]; then
    echo "→ Moving config: $name"
    mv "$HOME/.config/$name" "$CONFIGS/$name"
  fi
}

move_cfg hypr
move_cfg waybar
move_cfg nvim
move_cfg winapps

if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
  echo "→ Moving .bashrc"
  mv "$HOME/.bashrc" "$SHELL/.bashrc"
fi

echo "✔ Migration complete"

