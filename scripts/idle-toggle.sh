#!/bin/bash
# Toggle hypridle (idle lock) on/off
if pgrep -x hypridle >/dev/null; then
  pkill hypridle
  notify-send -u low "Idle lock disabled"
else
  hypridle &
  notify-send -u low "Idle lock enabled"
fi

pkill -SIGRTMIN+9 waybar
