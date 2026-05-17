#!/bin/bash
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
if [[ -n "$temp" ]]; then
  printf '{"text":"󰾲 %s°C","tooltip":"RTX 3080: %s°C"}\n' "$temp" "$temp"
else
  printf '{"text":""}\n'
fi
