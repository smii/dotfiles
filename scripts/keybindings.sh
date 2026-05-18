#!/usr/bin/env bash
# Display a formatted keybinding overview in a floating terminal window.
# Hyprland window rule matches on title "Keybindings" — see windows.conf.

BINDINGS="${HOME}/.config/hypr/bindings.conf"

ghostty \
  --title="Keybindings" \
  --window-decoration=false \
  -e bash -c "bat --style=grid,header --language=ini --color=always --paging=always '${BINDINGS}'"
