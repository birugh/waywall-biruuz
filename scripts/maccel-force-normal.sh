#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.cache/waywall/maccel-waywall-state"
mkdir -p "$(dirname "$state_file")"

maccel set param sens-mult 1.0
printf 'normal\n' > "$state_file"
