#!/bin/bash
if systemctl --user is-active --quiet gammastep.service; then
  systemctl --user stop gammastep.service
  notify-send -u low "Night light disabled"
else
  systemctl --user start gammastep.service
  notify-send -u low "Night light enabled"
fi
pkill -SIGRTMIN+11 waybar
