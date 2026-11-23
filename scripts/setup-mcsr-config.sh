#!/usr/bin/env bash

set -Eeuo pipefail

readonly WORKDIR="${PWD}/config/.minecraft"
readonly TARGET="/home/biru/.local/share/multimc/instances/MCSRRanked-1.16.1-RSG/.minecraft"
readonly MCSR_WORKDIR="${PWD}/config/mcsr"
readonly MCSR_TARGET="$TARGET/config/mcsr"
readonly FILES=("icon.png" "options.txt")

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

dirs_differ() {
    ! diff -qr -- "$1" "$2" >/dev/null 2>&1
}

files_differ() {
    ! cmp -s -- "$1" "$2"
}

symlink_config() {
    [[ -d "$WORKDIR" ]] || { error "Workdir tidak ditemukan: $WORKDIR"; return 1; }
    [[ -d "$TARGET" && ! -L "$TARGET" ]] || { error "Target .minecraft tidak valid: $TARGET"; return 1; }

    local file source target
    for file in "${FILES[@]}"; do
        source="$WORKDIR/$file"
        target="$TARGET/$file"
        [[ -e "$source" || -L "$source" ]] || { error "Source tidak ditemukan: $source"; return 1; }
        if [[ -L "$target" && "$(readlink -- "$target")" == "$source" ]]; then
            continue
        fi
        if [[ -f "$target" ]] && ! files_differ "$source" "$target"; then
            rm -- "$target"
        elif [[ -e "$target" || -L "$target" ]]; then
            backup_existing "$target"
        fi
        ln -s -- "$source" "$target"
        success "Symlink dibuat: $target -> $source"
    done

    [[ -d "$MCSR_WORKDIR" ]] || { error "Workdir tidak ditemukan: $MCSR_WORKDIR"; return 1; }
    if [[ -L "$MCSR_TARGET" && "$(readlink -- "$MCSR_TARGET")" == "$MCSR_WORKDIR" ]]; then
        success "Symlink dibuat: $MCSR_TARGET -> $MCSR_WORKDIR"
    elif [[ -d "$MCSR_TARGET" ]] && ! dirs_differ "$MCSR_WORKDIR" "$MCSR_TARGET"; then
        rm -rf -- "$MCSR_TARGET"
        ln -s -- "$MCSR_WORKDIR" "$MCSR_TARGET"
        success "Symlink dibuat tanpa backup; MCSR config sama."
    else
        [[ -e "$MCSR_TARGET" || -L "$MCSR_TARGET" ]] && backup_existing "$MCSR_TARGET"
        ln -s -- "$MCSR_WORKDIR" "$MCSR_TARGET"
        success "Symlink dibuat: $MCSR_TARGET -> $MCSR_WORKDIR"
    fi
}

update_config() {
    [[ -d "$TARGET" && ! -L "$TARGET" ]] || {
        error "Target .minecraft bukan direktori nyata: $TARGET"
        return 1
    }

    local file source target
    for file in "${FILES[@]}"; do
        source="$TARGET/$file"
        target="$WORKDIR/$file"
        [[ -e "$source" && ! -L "$source" ]] || continue
        [[ -e "$target" || -L "$target" ]] || { cp -a -- "$source" "$target"; continue; }
        files_differ "$source" "$target" || continue
        backup_existing "$target"
        cp -a -- "$source" "$target"
    done

    [[ -d "$MCSR_TARGET" && ! -L "$MCSR_TARGET" ]] || {
        [[ -L "$MCSR_TARGET" ]] && return 0
        error "Target MCSR tidak valid: $MCSR_TARGET"
        return 1
    }
    if ! dirs_differ "$MCSR_WORKDIR" "$MCSR_TARGET"; then
        success "MCSR config sama. Tidak ada backup."
        return 0
    fi
    backup_existing "$MCSR_WORKDIR"
    mkdir -p -- "$MCSR_WORKDIR"
    cp -a -- "$MCSR_TARGET"/. "$MCSR_WORKDIR"/
    success "Icon, options, dan MCSR config dibawa ke workdir."
}

main() {
    while :; do
        clear_screen
        printf '\nMinecraft config: %s\nTarget: %s\n\n' "$WORKDIR" "$TARGET"
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
