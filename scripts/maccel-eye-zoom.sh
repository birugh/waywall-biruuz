#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.cache/waywall/maccel-waywall-state"
mkdir -p "$(dirname "$state_file")"
state=$(cat "$state_file" 2>/dev/null || printf 'normal')

case "$state" in
  reset)
    maccel set param sens-mult 1.0
    printf 'normal\n' > "$state_file"
    printf '(f7)\n'
    ;;
  normal)
    maccel set param sens-mult 0.10415
    printf 'zoom\n' > "$state_file"
    printf '(f7)\n'
    ;;
  eye|zoom)
    maccel set param sens-mult 1.0
    printf 'normal\n' > "$state_file"
    printf '(f7)\n'
    ;;
  *)
    printf 'Refuse: unsupported state %s.\n' "$state" >&2
    exit 1
    ;;
esac
