# AGENTS.md

## What this repo is

`waywall-biruuz` — `birugh`'s fork of [arjuncgore/waywall_generic_config](https://github.com/arjuncgore/waywall_generic_config), a Waywall config for Minecraft speedrunning on Linux/Wayland: resolution macros (thin/wide/tall), pie-chart/e-counter mirrors, Ninjabrain Bot + Paceman launchers, keyboard remaps. The fork exists to carry the user's personal speedrunning tweaks on top of upstream. Changes are documented in `README.md` (speedrunning terms, Indonesian); the upstream README is kept as `README-CONFIG.md` — do not delete it.

The user communicates in Indonesian — respond in Indonesian.

**This fork is purely personal — never fetch or rebase from upstream.** No tracking, pulling, or syncing with `arjuncgore/waywall_generic_config` ever again.

## One repo, symlinked as the live config

`~/<folder-dotfiles>/waywall-biruuz` is the only repo (part of the user's dotfiles collection in `~/dotfiles-biru`). `~/.config/waywall` is a symlink to it, so edits in the repo are live immediately and there is nothing to sync. The old standalone clone sits at `~/.config/waywall.bak` — a backup, not edited.

**Never push to GitHub unless the user explicitly asks.**

## Structure

- `init.lua` — user-facing config (settings live here).
- `remaps.lua` — keyboard remaps.
- `main.lua` — code. Deliberate fork change: thin/wide/tall resize actions are NOT gated on chat mode (`remaps_active`) — different from upstream, do not "fix" it back. The `chat_mode_helper` gate was intentionally removed from `resize_helper`.
- `extras.lua` — extension hook.
- `scripts/mcsr-calcsens` — git submodule (mcsr sensitivity calculator). Cloning the fork requires `--recurse-submodules`; a plain clone needs `git submodule update --init --recursive`. Updating it = commit the new submodule pointer (`git add scripts/mcsr-calcsens`).
- `.github/workflows/sync-1440.yml` — upstream's workflow (rebases the 1440 branch onto main). The fork has no 1440 branch, so the action fails harmlessly; leave it alone unless asked.
