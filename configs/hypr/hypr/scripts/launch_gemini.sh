#!/bin/bash

# The specific class from your hyprctl output
CLASS="chrome-gemini.google.com__-Default"

# The command to launch your Chrome Web App
LAUNCH_CMD="chromium --app=https://gemini.google.com/"

# 1. Check if the window class is already open
if hyprctl clients | grep -q "class: $CLASS"; then
    # 2. If it is open, focus the existing window
    hyprctl dispatch focuswindow "class:$CLASS"
else
    # 3. If it is NOT open, launch a new instance
    $LAUNCH_CMD &
fi
