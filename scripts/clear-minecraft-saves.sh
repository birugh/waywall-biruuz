#!/usr/bin/env bash

set -Eeuo pipefail

readonly STATE_DIR="${MCSR_SAVE_TOOL_STATE_DIR:-$PWD/.minecraft-save-manager}"
readonly LOCATION_FILE="$STATE_DIR/locations"
readonly FOCUS_FILE="$STATE_DIR/focused"
readonly WHITELIST_DIR="$STATE_DIR/whitelists"

minecraft_folder=""

log() { printf '[INFO] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1" >&2; }
error() { printf '[ERROR] %s\n' "$1" >&2; }

clear_screen() {
    if command -v clear >/dev/null 2>&1; then
        clear
    else
        printf '\033[2J\033[H'
    fi
}

load_state() {
    if [[ -f "$FOCUS_FILE" ]]; then
        minecraft_folder="$(<"$FOCUS_FILE")"
    fi
}

instance_name() {
    local instance_dir
    instance_dir="$(dirname -- "$minecraft_folder")"
    awk -F'[:=][[:space:]]*' '$1 == "name" { print $2; exit }' "$instance_dir/instance.cfg" 2>/dev/null || true
}

show_focus() {
    local name
    name="$(instance_name)"
    printf 'Focused Minecraft folder:\n  %s\n' "$minecraft_folder"
    printf 'Instance name:\n  %s\n' "${name:-unknown}"
}

whitelist_file() {
    local short_hash
    short_hash="$(printf '%s' "$minecraft_folder" | sha256sum | cut -c1-8)"
    printf '%s/%s--%s.whitelist\n' "$WHITELIST_DIR" "$(basename -- "$(dirname -- "$minecraft_folder")")" "$short_hash"
}

validate_folder() {
    local candidate="${1%/}"
    [[ "$(basename -- "$candidate")" == ".minecraft" && -d "$candidate" ]] || {
        error "Path harus direktori .minecraft yang sudah ada: $candidate"
        return 1
    }
    minecraft_folder="$candidate"
    mkdir -p -- "$STATE_DIR" "$WHITELIST_DIR"
    touch -- "$LOCATION_FILE"
    grep -Fxq -- "$minecraft_folder" "$LOCATION_FILE" || printf '%s\n' "$minecraft_folder" >> "$LOCATION_FILE"
    printf '%s\n' "$minecraft_folder" > "$FOCUS_FILE"
    log "Active Minecraft folder: $minecraft_folder"
}

choose_folder() {
    local -a locations=() candidate
    local choice i=1
    [[ -f "$LOCATION_FILE" ]] && mapfile -t locations < <(awk 'NF' "$LOCATION_FILE")
    ((${#locations[@]})) || { error 'No Minecraft folder saved yet. Choose Add Minecraft folder first.'; return 1; }
    for candidate in "${locations[@]}"; do printf '%d) %s\n' "$i" "$candidate"; ((i++)); done
    read -r -p 'Choose Minecraft folder number (or cancel): ' choice
    [[ "$choice" == cancel ]] && return 0
    [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#locations[@]})) || { error 'Invalid choice.'; return 1; }
    validate_folder "${locations[choice-1]}"
}

add_folder() {
    local candidate
    read -r -p 'Minecraft folder (.minecraft), or cancel: ' candidate
    [[ "$candidate" == cancel ]] && return 0
    [[ -n "$candidate" ]] && validate_folder "$candidate"
}

require_folder() {
    [[ -n "$minecraft_folder" && -d "$minecraft_folder" ]] || { error 'Choose a Minecraft folder first.'; return 1; }
}

whitelist_world() {
    require_folder || return
    printf '\nWhitelist will be saved for the active instance:\n'
    show_focus
    printf '\n'
    local world
    read -r -p 'World folder name (or cancel): ' world
    [[ "$world" == cancel ]] && return 0
    [[ -n "$world" ]] || { error 'World folder name is empty.'; return 1; }
    [[ "$world" != */* && "$world" != .* && "$world" != *$'\n'* ]] || {
        error 'Invalid world folder name.'
        return 1
    }
    local saves="$minecraft_folder/saves"
    local world_path="$saves/$world"
    [[ -d "$world_path" ]] || {
        error "World folder not found: $world_path"
        return 1
    }
    local file
    file="$(whitelist_file)"
    printf '\n'; show_focus; printf '\n'
    mkdir -p -- "$WHITELIST_DIR"
    touch -- "$file"
    grep -Fxq -- "$world" "$file" || printf '%s\n' "$world" >> "$file"
    log "World whitelisted for active instance: $world"
}

remove_folder() {
    local -a locations=() candidate
    local choice i=1 answer selected whitelist
    [[ -f "$LOCATION_FILE" ]] && mapfile -t locations < <(awk 'NF' "$LOCATION_FILE")
    ((${#locations[@]})) || { error 'No saved Minecraft folders.'; return; }
    for candidate in "${locations[@]}"; do printf '%d) %s\n' "$i" "$candidate"; ((i++)); done
    read -r -p 'Choose folder to remove (or cancel): ' choice
    [[ "$choice" == cancel ]] && return 0
    [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#locations[@]})) || { error 'Invalid choice.'; return; }
    selected="${locations[choice-1]}"
    minecraft_folder="$selected"
    whitelist="$(whitelist_file)"
    printf 'WARNING: Removing this Minecraft folder from the saved locations will also remove its whitelist.\n'
    read -r -p 'Type yes to remove the saved location and whitelist, or cancel: ' answer
    [[ "$answer" == cancel ]] && return 0
    [[ "$answer" == yes ]] || { log 'Cancelled.'; return; }
    awk -v path="$selected" '$0 != path' "$LOCATION_FILE" > "$LOCATION_FILE.tmp"
    mv -- "$LOCATION_FILE.tmp" "$LOCATION_FILE"
    rm -f -- "$whitelist"
    [[ "$minecraft_folder" == "$selected" ]] && { minecraft_folder=""; rm -f -- "$FOCUS_FILE"; }
    log 'Saved Minecraft folder and its whitelist removed.'
}

remove_whitelisted_world() {
    require_folder || return
    local file="$(whitelist_file)" world answer
    [[ -f "$file" ]] || { log 'No whitelist found for the active instance.'; return; }
    cat "$file"
    read -r -p 'World name to remove from whitelist (or cancel): ' world
    [[ "$world" == cancel ]] && return 0
    grep -Fxq -- "$world" "$file" || { error 'World is not whitelisted.'; return; }
    read -r -p 'Type yes to remove this world from the whitelist, or cancel: ' answer
    [[ "$answer" == cancel ]] && return 0
    [[ "$answer" == yes ]] || { log 'Cancelled.'; return; }
    awk -v world="$world" '$0 != world' "$file" > "$file.tmp"
    mv -- "$file.tmp" "$file"
    log 'World removed from whitelist. The save folder was not deleted.'
}

clear_saves() {
    require_folder || return
    local saves="$minecraft_folder/saves"
    printf '\n'; show_focus; printf '\n'
    [[ -d "$saves" ]] || { log 'Saves folder does not exist.'; return; }
    local -a victims=() entry name
    local whitelist
    whitelist="$(whitelist_file)"
    while IFS= read -r -d '' entry; do
        name="$(basename -- "$entry")"
        if ! grep -Fxq -- "$name" "$whitelist" 2>/dev/null; then
            victims+=("$entry")
        fi
    done < <(find "$saves" -mindepth 1 -maxdepth 1 -type d -print0)

    ((${#victims[@]})) || { log 'No worlds to delete.'; return; }
    printf 'Worlds to be deleted:\n'
    printf '  %s\n' "${victims[@]}"
    local answer
    read -r -p 'Type yes to delete, or cancel to return: ' answer
    [[ "$answer" == cancel ]] && { log 'Cancelled.'; return; }
    [[ "$answer" == yes ]] || { log 'Cancelled.'; return; }
    for entry in "${victims[@]}"; do rm -rf -- "$entry"; done
    log "${#victims[@]} worlds deleted."
}

main() {
    load_state
    while :; do
        clear_screen
        if [[ -n "$minecraft_folder" ]]; then
            printf '\n'; show_focus; printf '\n'
        else
            printf '\nActive Minecraft folder: not selected\n\n'
        fi
        printf '1) Choose/focus Minecraft folder\n2) Add Minecraft folder\n3) Whitelist save world\n4) Remove Minecraft folder\n5) Remove whitelisted world\n6) Clear save worlds\n7) Exit\n'
        local choice
        read -r -p 'Choose: ' choice || break
        case "$choice" in
            1) choose_folder || true ;;
            2) add_folder || true ;;
            3) whitelist_world || true ;;
            4) remove_folder || true ;;
            5) remove_whitelisted_world || true ;;
            6) clear_saves || true ;;
            7) exit 0 ;;
            *) warn 'Invalid choice.' ;;
        esac
        printf '\n'
        read -r -p 'Press Enter to return to the main menu...' _ || break
    done
}

main "$@"
