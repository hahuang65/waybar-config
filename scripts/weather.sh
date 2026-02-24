#!/bin/bash

# Waybar custom weather module using wttr.in
# Auto-detects location via IP geolocation

CACHE_FILE="/tmp/waybar-weather.json"
CACHE_MAX_AGE=600 # 10 minutes

# Use cache if fresh enough
if [[ -f "$CACHE_FILE" ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if (( age < CACHE_MAX_AGE )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Detect location via ipinfo.io (more accurate than wttr.in's IP lookup)
loc_data=$(curl -sf "https://ipinfo.io/json" 2>/dev/null)
if [[ -n "$loc_data" ]]; then
    loc_coords=$(echo "$loc_data" | jq -r '.loc')  # "lat,lon"
    loc_city=$(echo "$loc_data" | jq -r '.city')
    loc_region=$(echo "$loc_data" | jq -r '.region')
    location="${loc_city}, ${loc_region}"
    weather=$(curl -sf "wttr.in/${loc_coords}?format=j1" 2>/dev/null)
else
    weather=$(curl -sf "wttr.in/?format=j1" 2>/dev/null)
    location=""
fi

if [[ -z "$weather" ]]; then
    echo '{"text": "N/A", "tooltip": "Weather unavailable", "class": "error"}'
    exit 0
fi

# Fall back to wttr.in location if ipinfo.io didn't provide one
if [[ -z "$location" ]]; then
    location=$(echo "$weather" | jq -r '.nearest_area[0] | "\(.areaName[0].value), \(.region[0].value)"')
fi

# Map weather code to icon (using printf to preserve unicode)
weather_icon() {
    case "$1" in
        113) printf '\ue30d' ;;                    # Clear/Sunny
        116) printf '\ue302' ;;                    # Partly cloudy
        119|122) printf '\ue312' ;;                # Cloudy/Overcast
        143|248|260) printf '\ue313' ;;            # Fog/Mist
        176|263|266|293|296) printf '\ue318' ;;    # Light rain/drizzle
        299|302|305|308|356|359) printf '\ue318' ;; # Heavy rain
        179|227|320|323|326|329|332|335|338|368|371|395) printf '\ue31a' ;; # Snow
        200|386|389|392) printf '\ue31d' ;;        # Thunderstorm
        *) printf '\ue312' ;;                      # Default cloudy
    esac
}

temp=$(echo "$weather" | jq -r '.current_condition[0].temp_F')
feels_like=$(echo "$weather" | jq -r '.current_condition[0].FeelsLikeF')
humidity=$(echo "$weather" | jq -r '.current_condition[0].humidity')
desc=$(echo "$weather" | jq -r '.current_condition[0].weatherDesc[0].value')
wind_speed=$(echo "$weather" | jq -r '.current_condition[0].windspeedMiles')
wind_dir=$(echo "$weather" | jq -r '.current_condition[0].winddir16Point')
code=$(echo "$weather" | jq -r '.current_condition[0].weatherCode')

icon=$(weather_icon "$code")

# Build 12-hour forecast (next 4 three-hour slots)
current_hour=$(date +%-H)

forecast=""
slots_needed=4
slots_found=0

for day_idx in 0 1; do
    hourly=$(echo "$weather" | jq -c ".weather[$day_idx].hourly[]")
    while IFS= read -r entry; do
        time_val=$(echo "$entry" | jq -r '.time')
        hour=$((10#$time_val / 100))

        # Skip past slots for today
        if [[ $day_idx -eq 0 && $hour -le $current_hour ]]; then
            continue
        fi

        if (( slots_found >= slots_needed )); then
            break
        fi

        fc_temp=$(echo "$entry" | jq -r '.tempF')
        fc_code=$(echo "$entry" | jq -r '.weatherCode')
        fc_desc=$(echo "$entry" | jq -r '.weatherDesc[0].value' | xargs)
        fc_icon=$(weather_icon "$fc_code")

        if [[ $day_idx -eq 0 ]]; then
            fc_label=$(printf "%02d:00" "$hour")
        else
            fc_label=$(printf "Tomorrow %02d:00" "$hour")
        fi

        forecast="${forecast}
${fc_icon}  ${fc_label}  ${fc_temp}°F  ${fc_desc}"
        ((slots_found++))
    done <<< "$hourly"

    if (( slots_found >= slots_needed )); then
        break
    fi
done

tooltip=$(printf "%s\n%s  %s  %s°F\nFeels like: %s°F\nHumidity: %s%%\nWind: %s mph %s%b" \
    "$location" "$icon" "$desc" "$temp" "$feels_like" "$humidity" "$wind_speed" "$wind_dir" "$forecast")

output=$(jq -nc \
    --arg text "$icon  ${temp}°F  $location" \
    --arg tooltip "$tooltip" \
    --arg class "weather" \
    '{text: $text, tooltip: $tooltip, class: $class}')

echo "$output" > "$CACHE_FILE"
echo "$output"
