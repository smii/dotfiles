#!/bin/bash
# Toggle gpu-screen-recorder
dir="$HOME/Videos/Recordings"
mkdir -p "$dir"

if pgrep -f "^gpu-screen-recorder" >/dev/null; then
  pkill -SIGINT -f "^gpu-screen-recorder"
  notify-send -u low "Recording stopped"
else
  output=$(hyprctl monitors -j | jq -r '.[0].name')
  file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"
  gpu-screen-recorder -w "$output" -f 60 -a default_output -o "$file" &
  notify-send -u low "Recording started" "$output → $file"
fi

# Signal waybar to update the indicator
pkill -SIGRTMIN+8 waybar
