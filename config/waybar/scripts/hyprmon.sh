#!/usr/bin/env bash
profile=$(hyprmon -active-profile 2>/dev/null)
if [[ -n "$profile" ]]; then
    echo "{\"text\":\"󰍹\",\"tooltip\":\"Monitor: $profile\",\"class\":\"active\"}"
else
    echo "{\"text\":\"󰍹\",\"tooltip\":\"Monitors\"}"
fi
