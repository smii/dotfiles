#!/bin/bash
# $1 = search term
# $2 = URL or Command

if hyprctl clients | grep -i "$1" > /dev/null; then
    hyprctl dispatch togglespecialworkspace "$1"
    exit 0
fi

if [[ "$2" == http* ]]; then
    hyprctl dispatch exec "[workspace special:$1 silent] chromium --app=$2 --ozone-platform-hint=auto"
    sleep 0.8 # Increased wait for web apps to prevent "initial screen" freeze
else
    hyprctl dispatch exec "[workspace special:$1 silent] $2"
    sleep 0.3
fi

hyprctl dispatch togglespecialworkspace "$1"
