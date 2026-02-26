#!/bin/bash
# Custom microphone module for waybar
# Monitors default source volume and mute state

ICON_MIC=$(printf '\uf130')        # FontAwesome microphone
ICON_MIC_MUTED=$(printf '\uf131')  # FontAwesome microphone-slash

info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
volume=$(echo "$info" | grep -oP 'Volume: \K[0-9.]+')
muted=$(echo "$info" | grep -c MUTED)

# Convert to percentage
pct=$(awk "BEGIN {printf \"%.0f\", $volume * 100}")

# Get source name
source_name=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep 'node.nick' | sed 's/.*= "//' | sed 's/"//')
if [[ -z "$source_name" ]]; then
    source_name=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep 'node.description' | sed 's/.*= "//' | sed 's/"//')
fi

if [[ "$muted" -eq 1 ]]; then
    text="$ICON_MIC_MUTED"
    class="muted"
else
    text="$ICON_MIC $pct%"
    class=""
fi

tooltip="$source_name"

# Escape for JSON
text="${text//\"/\\\"}"
tooltip="${tooltip//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
