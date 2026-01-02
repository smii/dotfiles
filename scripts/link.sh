#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIGS="$DOTFILES/configs"
CONFIG="$HOME/.config"

mkdir -p "$CONFIG"

link() {
  local name="$1"
  local src="$CONFIGS/$name"
  local dest="$CONFIG/$name"

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "→ $name already exists, skipping"
  else
    echo "→ Linking $name"
    ln -s "$src" "$dest"
  fi
}

link hypr
link waybar
link nvim
link winapps

echo "✔ All configs linked"

