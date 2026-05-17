#!/bin/bash
# Cycle through available PipeWire audio sinks
sinks=$(wpctl status | awk '/Audio Sinks/,/Audio Sources/' | grep -E '^\s+[0-9]+\.' | awk '{print $1}' | tr -d '.')
current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $1}')
sink_list=($sinks)

next=false
for sink in "${sink_list[@]}"; do
  if $next; then
    wpctl set-default "$sink"
    name=$(wpctl inspect "$sink" 2>/dev/null | grep 'node.nick\|node.name' | head -1 | cut -d'"' -f2)
    notify-send -u low "Audio output: $name"
    exit 0
  fi
  if [[ "$sink" == "$current" ]]; then
    next=true
  fi
done

# Wrap around to first sink
wpctl set-default "${sink_list[0]}"
name=$(wpctl inspect "${sink_list[0]}" 2>/dev/null | grep 'node.nick\|node.name' | head -1 | cut -d'"' -f2)
notify-send -u low "Audio output: $name"
