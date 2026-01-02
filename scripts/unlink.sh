#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config"

unlink_cfg() {
  local name="$1"
  local dest="$CONFIG/$name"

  if [[ -L "$dest" ]]; then
    echo "→ Unlinking $name"
    rm "$dest"
  else
    echo "→ $name is not a symlink, skipping"
  fi
}

unlink_cfg hypr
unlink_cfg waybar
unlink_cfg nvim
unlink_cfg winapps

echo "✔ Symlinks removed"

