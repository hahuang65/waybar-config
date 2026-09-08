#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONFIG_FILE="$REPOSITORY_DIR/config"
readonly STYLE_FILE="$REPOSITORY_DIR/style.css"

assert_config_contains() {
  local expected="$1"

  if ! grep -Fq -- "$expected" "$CONFIG_FILE"; then
    printf 'Expected Waybar config to contain: %s\n' "$expected" >&2
    return 1
  fi
}

assert_config_contains '"layer": "top"'
assert_config_contains '"modules-left": ["niri/workspaces"'
assert_config_contains '"niri/workspaces": {'
assert_config_contains '"format": "{icon}"'
assert_config_contains '"1:web": "󰈹"'
assert_config_contains '"2:chat": ""'
assert_config_contains '"3:media": ""'
assert_config_contains '"4:game": ""'
assert_config_contains '"5:code": ""'
assert_config_contains '"scratchpads": ""'
assert_config_contains '"7": ""'

grep -Fq '#workspaces button#niri-workspace-scratchpads,' "$STYLE_FILE"
grep -Fq '#workspaces button#niri-workspace-7' "$STYLE_FILE"
grep -Fq 'font-size: 0;' "$STYLE_FILE"
grep -Fq 'padding: 0 10px;' "$STYLE_FILE"
grep -Fq '#workspaces button:first-child' "$STYLE_FILE"
grep -Fq 'padding-right: 14px;' "$STYLE_FILE"
