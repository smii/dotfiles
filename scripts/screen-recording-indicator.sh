#!/bin/bash
# Screen recording indicator for waybar
# Returns JSON for waybar custom module

if pgrep -x wf-recorder > /dev/null; then
    echo '{"text": "󰻃", "tooltip": "Recording... Click to stop", "class": "active"}'
else
    echo '{"text": "", "tooltip": "", "class": ""}'
fi
