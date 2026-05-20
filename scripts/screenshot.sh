#!/bin/bash
# Screenshot region → clipboard + save to ~/Pictures/Screenshots/
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

if hyprshot -m region -o "$dir" -f "$(basename "$file")" 2>/dev/null; then
  wl-copy < "$file"
  notify-send -u low "Screenshot copied & saved" "$file" -i "$file"
fi
