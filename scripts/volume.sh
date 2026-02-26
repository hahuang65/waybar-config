#!/bin/bash
# Custom volume output module for waybar
# Monitors default sink volume and mute state

ICON_VOL_OFF=$(printf '\uf026')    # FontAwesome volume-off
ICON_VOL_DOWN=$(printf '\uf027')   # FontAwesome volume-down
ICON_VOL_UP=$(printf '\uf028')     # FontAwesome volume-up
ICON_VOL_MUTED=$(printf '\U000f075f') # nf-md-volume-mute
ICON_BT=$(printf '\uf294')         # FontAwesome bluetooth

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
volume=$(echo "$info" | grep -oP 'Volume: \K[0-9.]+')
muted=$(echo "$info" | grep -c MUTED)

# Convert to percentage
pct=$(awk "BEGIN {printf \"%.0f\", $volume * 100}")

# Get sink name (nickname)
sink_name=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep 'node.nick' | sed 's/.*= "//' | sed 's/"//')
if [[ -z "$sink_name" ]]; then
    sink_name=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep 'node.description' | sed 's/.*= "//' | sed 's/"//')
fi

# Check if bluetooth
is_bt=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -c 'api.bluez5')

# Pick icon
if [[ "$muted" -eq 1 ]]; then
    text="$ICON_VOL_MUTED"
    class="muted"
elif [[ "$pct" -le 30 ]]; then
    icon="$ICON_VOL_OFF"
    text="$icon $pct%"
    class=""
elif [[ "$pct" -le 60 ]]; then
    icon="$ICON_VOL_DOWN"
    text="$icon $pct%"
    class=""
else
    icon="$ICON_VOL_UP"
    text="$icon $pct%"
    class=""
fi

# Prepend bluetooth icon if applicable
if [[ "$is_bt" -ge 1 && "$muted" -ne 1 ]]; then
    text="$ICON_BT $text"
    class="bluetooth"
fi

tooltip="$sink_name"

# Escape for JSON
text="${text//\"/\\\"}"
tooltip="${tooltip//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
