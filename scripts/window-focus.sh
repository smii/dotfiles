#!/usr/bin/env bash
# Left click: focus window. Middle click: close window.
case "$2" in
    1) hyprctl dispatch focuswindow "address:$1" ;;
    2) hyprctl dispatch closewindow "address:$1" ;;
esac
