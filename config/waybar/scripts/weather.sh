#!/bin/bash
# Requires curl; uses wttr.in for one-line weather icon
icon=$(curl -sf "wttr.in?format=%c" 2>/dev/null | tr -d '\n')
if [[ -n "$icon" ]]; then
  icon=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
  printf '{"text":"%s"}\n' "$icon"
else
  printf '{"text":"","class":"unavailable"}\n'
fi
