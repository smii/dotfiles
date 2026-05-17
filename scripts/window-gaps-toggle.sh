#!/bin/bash
# Toggle window gaps on/off
current=$(hyprctl getoption general:gaps_out -j | jq -r '.custom')
if [[ "$current" == "0 0 0 0" ]] || [[ "$current" == "0" ]]; then
  hyprctl keyword general:gaps_in  5
  hyprctl keyword general:gaps_out 10
else
  hyprctl keyword general:gaps_in  0
  hyprctl keyword general:gaps_out 0
fi
