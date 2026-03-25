#!/usr/bin/env bash
# List sinks with friendly names: "description [name]"
sink=$(pactl list sinks | awk '
    /^\tName:/ { name = $2 }
    /^\tDescription:/ { sub(/^\tDescription: /, ""); desc = $0; print desc " [" name "]" }
' | fuzzel --dmenu --prompt='Audio output: ' | grep -oP '(?<=\[)[^\]]+')

[ -n "$sink" ] && pactl set-default-sink "$sink"
