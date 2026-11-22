#!/usr/bin/env bash

set -Eeuo pipefail

# Configuration
readonly HOME_DIR="/home/biru"

readonly NINJABRAIN_SOURCE="$HOME_DIR/.config/waywall/config/ninjabrain-bot/prefs.xml"
readonly NINJABRAIN_TARGET="$HOME_DIR/.java/.userPrefs/ninjabrainbot/prefs.xml"

readonly KANATA_SOURCE="$HOME_DIR/.config/waywall/config/kanata"
readonly KANATA_TARGET="$HOME_DIR/.config/kanata"
readonly HOTBAR_SOURCE="$HOME_DIR/.config/waywall/config/mpk/hotbar.nbt"
readonly LOCATION_STATE_DIR="${MCSR_LOCATION_STATE_DIR:-$PWD/.minecraft-save-manager}"
readonly LOCATION_FILE="$LOCATION_STATE_DIR/locations"
readonly FOCUS_FILE="$LOCATION_STATE_DIR/focused"

MINECRAFT_FOLDER="${MINECRAFT_FOLDER:-}"
HOTBAR_TARGET=""

validate_minecraft_folder() {
    local candidate="${1%/}"
    if [[ "$(basename -- "$candidate")" != ".minecraft" || ! -d "$candidate" ]]; then
        error "MINECRAFT_FOLDER harus direktori .minecraft yang sudah ada: $candidate"
        return 1
    fi
    MINECRAFT_FOLDER="$candidate"
    HOTBAR_TARGET="$MINECRAFT_FOLDER/hotbar.nbt"
}

save_location() {
    mkdir -p -- "$LOCATION_STATE_DIR"
    touch -- "$LOCATION_FILE"
    grep -Fxq -- "$MINECRAFT_FOLDER" "$LOCATION_FILE" || printf '%s\n' "$MINECRAFT_FOLDER" >> "$LOCATION_FILE"
    printf '%s\n' "$MINECRAFT_FOLDER" > "$FOCUS_FILE"
}

choose_minecraft_folder() {
    local candidate choice i=1
    mapfile -t locations < <([[ -f "$LOCATION_FILE" ]] && awk 'NF' "$LOCATION_FILE")
    if ((${#locations[@]})); then
        printf 'Saved Minecraft folders:\n'
        for candidate in "${locations[@]}"; do printf '  %d) %s\n' "$i" "$candidate"; ((i++)); done
        printf '  n) New folder\n'
        read -r -p 'Choose folder: ' choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#locations[@]})); then
            validate_minecraft_folder "${locations[choice-1]}" && save_location
            return
        fi
        [[ "$choice" == n ]] || { error 'Pilihan tidak valid.'; return 1; }
    fi
    read -r -p 'Minecraft folder (.minecraft): ' candidate
    validate_minecraft_folder "$candidate" && save_location
}

select_focused_location() {
    [[ -n "$MINECRAFT_FOLDER" ]] || {
        if [[ -f "$FOCUS_FILE" ]]; then validate_minecraft_folder "$(<"$FOCUS_FILE")" || true; fi
    }
    [[ -n "$MINECRAFT_FOLDER" ]] || choose_minecraft_folder
}

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
    local backup

    [[ -e "$target" || -L "$target" ]] || return 0

    while :; do
        backup="${target}.bak-$(date '+%Y%m%d-%H%M%S-%N')"
        [[ ! -e "$backup" && ! -L "$backup" ]] && break
        sleep 0.001
    done

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

    select_focused_location

    create_symlink "$NINJABRAIN_SOURCE" "$NINJABRAIN_TARGET"
    printf '\n'

    create_symlink "$KANATA_SOURCE" "$KANATA_TARGET"
    printf '\n'

    create_symlink "$HOTBAR_SOURCE" "$HOTBAR_TARGET"
    printf '\n'

    success "All symlinks processed successfully!"
}

main "$@"

