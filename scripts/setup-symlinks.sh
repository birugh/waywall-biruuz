#!/usr/bin/env bash

set -Eeuo pipefail

# Configuration
readonly HOME_DIR="/home/biru"

readonly NINJABRAIN_SOURCE="$HOME_DIR/.config/waywall/config/ninjabrain-bot/prefs.xml"
readonly NINJABRAIN_TARGET="$HOME_DIR/.java/.userPrefs/ninjabrainbot/prefs.xml"

readonly KANATA_SOURCE="$HOME_DIR/.config/waywall/config/kanata"
readonly KANATA_TARGET="$HOME_DIR/.config/kanata"

# Logging
log() {
    printf '\033[1;34m[INFO]\033[0m %s\n' "$1"
}

success() {
    printf '\033[1;32m[OK]\033[0m %s\n' "$1"
}

warn() {
    printf '\033[1;33m[WARN]\033[0m %s\n' "$1"
}

error() {
    printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2
}

# Backup
backup_existing() {
    local target="$1"
    local backup="${target}.bak"

    [[ -e "$target" || -L "$target" ]] || return 0

    if [[ -e "$backup" || -L "$backup" ]]; then
        backup="${target}.$(date '+%Y%m%d-%H%M%S').bak"

        if [[ -e "$backup" || -L "$backup" ]]; then
            error "Backup destination sudah ada: $backup"
            return 1
        fi
    fi

    mv -- "$target" "$backup"

    warn "Backup berhasil dibuat:"
    printf '       %s\n' "$backup"
}

# Symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local parent
    local current

    log "Processing: $target"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        error "Source tidak ditemukan: $source"
        return 1
    fi

    parent="$(dirname -- "$target")"
    mkdir -p -- "$parent"

    if [[ -L "$target" ]]; then
        current="$(readlink -- "$target")"

        if [[ "$current" == "$source" ]]; then
            success "Symlink sudah benar. Tidak ada perubahan."
            return 0
        fi

        warn "Symlink lama ditemukan: $current"
        backup_existing "$target"

    elif [[ -e "$target" ]]; then
        warn "File atau direktori lama ditemukan."
        backup_existing "$target"
    fi

    ln -s -- "$source" "$target"

    success "Symlink berhasil dibuat:"
    printf '       %s -> %s\n' "$target" "$source"
}

# Main
main() {
    printf '\n'
    log "Starting symlink setup..."
    printf '\n'

    create_symlink "$NINJABRAIN_SOURCE" "$NINJABRAIN_TARGET"
    printf '\n'

    create_symlink "$KANATA_SOURCE" "$KANATA_TARGET"
    printf '\n'

    success "All symlinks processed successfully!"
}

main "$@"

