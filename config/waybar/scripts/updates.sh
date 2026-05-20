#!/bin/bash
# Emit icon if pending pacman or AUR updates exist
count=$(checkupdates 2>/dev/null | wc -l)
aur_count=0
if command -v paru &>/dev/null; then
  aur_count=$(paru -Qua 2>/dev/null | wc -l)
fi
total=$((count + aur_count))
if (( total > 0 )); then
  printf ''
fi
