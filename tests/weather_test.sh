#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TEST_DIR="$(mktemp -d)"
readonly MOCK_BIN_DIR="$TEST_DIR/bin"
trap 'rm -rf "$TEST_DIR"' EXIT
mkdir -p "$MOCK_BIN_DIR"

cat >"$MOCK_BIN_DIR/curl" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$*" == *ipinfo.io* ]]; then
  printf '%s\n' '{"loc":"30.0,-97.0","city":"Spring","region":"Texas"}'
else
  tomorrow="$(date -d tomorrow +%Y-%m-%d)"
  printf '{"current":{"temperature_2m":94,"relative_humidity_2m":40,"apparent_temperature":96,"weather_code":0,"wind_speed_10m":8,"wind_direction_10m":180},"hourly":{"time":["%sT00:00","%sT03:00","%sT06:00","%sT09:00"],"temperature_2m":[80,78,76,82],"weather_code":[0,1,2,3]}}\n' \
    "$tomorrow" "$tomorrow" "$tomorrow" "$tomorrow"
fi
MOCK
chmod +x "$MOCK_BIN_DIR/curl"

output="$(PATH="$MOCK_BIN_DIR:$PATH" XDG_CACHE_HOME="$TEST_DIR/cache" \
  "$REPOSITORY_DIR/scripts/weather.sh")"

jq -e '.text | contains("Spring") | not' <<<"$output" >/dev/null
jq -e '.tooltip | startswith("Spring, Texas\n")' <<<"$output" >/dev/null
