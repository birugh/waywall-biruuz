#!/usr/bin/env bash
set -euo pipefail
maccel set param sens-mult 1.0
printf 'reset\n' > "${XDG_RUNTIME_DIR:-/tmp}/maccel-waywall-state"
