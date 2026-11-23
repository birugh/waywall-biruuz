#!/usr/bin/env bash

set -Eeuo pipefail

readonly WORKDIR="${PWD}/config/mcsr"
readonly TARGET="/home/biru/.local/share/multimc/instances/MCSRRanked-1.16.1-RSG/.minecraft/config/mcsr"

log() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\033[1;32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

clear_screen() {
    command -v clear >/dev/null 2>&1 && clear || printf '\033[2J\033[H'
}

backup_existing() {
    local path="$1" backup
    [[ -e "$path" || -L "$path" ]] || return 0
    while :; do
        backup="${path}.bak-$(date '+%Y%m%d-%H%M%S-%N')"
        [[ ! -e "$backup" && ! -L "$backup" ]] && break
        sleep 0.001
    done
    mv -- "$path" "$backup"
    warn "Backup berhasil dibuat:"
    printf '       %s\n' "$backup"
}

symlink_config() {
    [[ -d "$WORKDIR" ]] || { error "Workdir tidak ditemukan: $WORKDIR"; return 1; }
    mkdir -p -- "$(dirname -- "$TARGET")"

    if [[ -L "$TARGET" && "$(readlink -- "$TARGET")" == "$WORKDIR" ]]; then
        success "Symlink sudah benar."
        return
    fi
    [[ -e "$TARGET" || -L "$TARGET" ]] && backup_existing "$TARGET"
    ln -s -- "$WORKDIR" "$TARGET"
    success "Symlink dibuat: $TARGET -> $WORKDIR"
}

update_config() {
    [[ -e "$TARGET" && ! -L "$TARGET" ]] || {
        error "Target bukan direktori config nyata: $TARGET"
        error "Symlink harus dihapus/ter-override game sebelum update."
        return 1
    }
    [[ -d "$TARGET" ]] || { error "Target bukan direktori: $TARGET"; return 1; }
    backup_existing "$WORKDIR"
    mkdir -p -- "$WORKDIR"
    cp -a -- "$TARGET"/. "$WORKDIR"/
    success "Config dibawa ke workdir: $TARGET -> $WORKDIR"
}

main() {
    while :; do
        clear_screen
        printf '\nMCSR config: %s\nTarget: %s\n\n' "$WORKDIR" "$TARGET"
        printf '1) Symlink\n2) Update\n3) Exit\n'
        local choice
        read -r -p 'Choose: ' choice || break
        case "$choice" in
            1) symlink_config || true ;;
            2) update_config || true ;;
            3) exit 0 ;;
            *) error 'Pilihan tidak valid.' ;;
        esac
        printf '\n'
        read -r -p 'Press Enter untuk kembali...' _ || break
    done
}

main "$@"
