#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.cache/waywall/maccel-waywall-state"
mkdir -p "$(dirname "$state_file")"
state=$(cat "$state_file" 2>/dev/null || printf 'normal')
case "$state" in
  normal|reset)
    next_state="$state"
    ;;
  zoom|eye)
    next_state=reset
    ;;
  *)
    printf 'Refuse: unsupported state %s.\n' "$state" >&2
    exit 1
    ;;
esac

maccel set param sens-mult 1.0
printf '%s\n' "$next_state" > "$state_file"
