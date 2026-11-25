#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/maccel-waywall-state"
state=$(cat "$state_file" 2>/dev/null || printf 'normal')
case "$state" in
  normal|reset)
    next_state="$state"
    ;;
  zoom)
    next_state=reset
    ;;
  *)
    printf 'Refuse: unsupported state %s.\n' "$state" >&2
    exit 1
    ;;
esac

maccel set param sens-mult 1.0
printf '%s\n' "$next_state" > "$state_file"
