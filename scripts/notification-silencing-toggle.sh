#!/bin/bash
# Toggle mako do-not-disturb mode
if makoctl mode | grep -q 'do-not-disturb'; then
  makoctl mode -r do-not-disturb
  notify-send -u low "Notifications enabled"
else
  makoctl mode -a do-not-disturb
fi

pkill -SIGRTMIN+10 waybar
