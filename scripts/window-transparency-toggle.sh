#!/bin/bash
# Toggle active window between full opacity and default transparent opacity
addr=$(hyprctl activewindow -j | jq -r '.address')
current=$(hyprctl clients -j | jq -r --arg a "$addr" '.[] | select(.address==$a) | .alpha')

if (( $(echo "$current > 0.95" | bc -l) )); then
  hyprctl setprop address:"$addr" alpha 0.90 lock:0
else
  hyprctl setprop address:"$addr" alpha 1.0 lock:0
fi
