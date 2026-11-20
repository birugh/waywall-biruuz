#!/usr/bin/env bash

set -euo pipefail

# Configuration
BASE_DIR="$HOME/.config/waywall"
SERVICE_DIR="$BASE_DIR/systemd"

KANATA_SERVICE="kanata.service"
SWITCHER_SERVICE="kanata-switcher.service"

SYSTEM_SERVICE_DEST="/etc/systemd/system"
USER_SERVICE_DEST="$HOME/.config/systemd/user"

# Validation
if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Do not run this script with sudo."
    exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
    echo "ERROR: systemctl not found."
    exit 1
fi

for service in "$KANATA_SERVICE" "$SWITCHER_SERVICE"; do
    if [[ ! -f "$SERVICE_DIR/$service" ]]; then
        echo "ERROR: Missing service file: $SERVICE_DIR/$service"
        exit 1
    fi
done

KANATA_BIN="$(command -v kanata || true)"
SWITCHER_BIN="$(command -v kanata-switcher || true)"

if [[ -z "$KANATA_BIN" ]]; then
    echo "ERROR: Kanata binary not found in PATH."
    exit 1
fi

if [[ -z "$SWITCHER_BIN" ]]; then
    echo "ERROR: kanata-switcher binary not found in PATH."
    exit 1
fi

if ! getent group input >/dev/null; then
    echo "ERROR: Group 'input' does not exist."
    exit 1
fi

# Prepare temporary service files
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

sed \
    -e "s|@SERVICE_USER@|$(id -un)|g" \
    -e "s|@KANATA_BIN@|$KANATA_BIN|g" \
    -e "s|@HOME@|$HOME|g" \
    "$SERVICE_DIR/$KANATA_SERVICE" \
    > "$TEMP_DIR/$KANATA_SERVICE"

sed \
    -e "s|@SWITCHER_BIN@|$SWITCHER_BIN|g" \
    "$SERVICE_DIR/$SWITCHER_SERVICE" \
    > "$TEMP_DIR/$SWITCHER_SERVICE"

# Install system-wide service: Kanata
echo "Installing $KANATA_SERVICE..."

sudo install -D -m 644 \
    "$TEMP_DIR/$KANATA_SERVICE" \
    "$SYSTEM_SERVICE_DEST/$KANATA_SERVICE"

sudo systemctl daemon-reload
sudo systemctl enable --now "$KANATA_SERVICE"

# Install user-level service: kanata-switcher
echo "Installing $SWITCHER_SERVICE..."

mkdir -p "$USER_SERVICE_DEST"

install -m 644 \
    "$TEMP_DIR/$SWITCHER_SERVICE" \
    "$USER_SERVICE_DEST/$SWITCHER_SERVICE"

systemctl --user daemon-reload
systemctl --user enable --now "$SWITCHER_SERVICE"

# Done
echo
echo "Kanata services installed successfully!"
echo
echo "Kanata:"
sudo systemctl status "$KANATA_SERVICE" --no-pager

echo
echo "Kanata Switcher:"
systemctl --user status "$SWITCHER_SERVICE" --no-pager

