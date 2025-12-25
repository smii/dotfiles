#!/bin/bash
# Check if a window with the specific class is already managed by Hyprland
if ! hyprctl clients | grep -i "$1" >/dev/null; then
  chromium-browser --app="$2" --ozone-platform-hint=auto &
fi
