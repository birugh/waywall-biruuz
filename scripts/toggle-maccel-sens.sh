#!/usr/bin/env bash
set -euo pipefail

current=$(maccel get all common | awk '/Sens-Multiplier:/ {print $2}')
case "$current" in
  1.000000000)
    maccel set param sens-mult 0.10415
    ;;
  0.104150000)
    maccel set param sens-mult 1.0
    ;;
  *)
    printf 'Refuse: unsupported Sens-Multiplier %s; expected 1.000000000 or 0.104150000.\n' "$current" >&2
    exit 1
    ;;
esac
