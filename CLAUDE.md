# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo

Fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)  
Own fork: `https://github.com/RambonL/dots-hyprland`  
Local clone: `~/dots/`

Configs live under `~/dots/dots/.config/` and are symlinked:
- `~/.config/quickshell/ii` → `~/dots/dots/.config/quickshell/ii`
- `~/.config/hypr` → `~/dots/dots/.config/hypr`
- `~/.config/fish/config.fish` → `~/dots/dots/.config/fish/config.fish`

**If something looks missing or broken, verify symlinks first:**
```bash
ls -la ~/.config/hypr ~/.config/quickshell/ii ~/.config/fish/config.fish
```
All must show `->` (symlink). If not, the upstream install script overwrote it.

Fix quickshell:
```bash
mv ~/.config/quickshell/ii ~/.config/quickshell/ii.bak
ln -s ~/dots/dots/.config/quickshell/ii ~/.config/quickshell/ii
```
Fix fish:
```bash
ln -sf ~/dots/dots/.config/fish/config.fish ~/.config/fish/config.fish
```

**The upstream install script overwrites symlinks on every run.** `qs-sync.sh` restores both quickshell and fish symlinks automatically — always run it after the install script.

## Commits

Never add `Co-Authored-By` trailers to commits.

Two separate commits — important for clean rebasing:

| Commit | Content | Touch? |
|--------|---------|--------|
| `upstream baseline` | upstream dots-hyprland updates | No |
| `custom: ...` | personal changes | Yes |

## Upstream Update

Updating happens via the **dots-hyprland install script** (not git rebase — upstream remote is not fetched).

After running the install script:

**1. Sync quickshell into dots repo:**
```bash
~/dots/scripts/qs-sync.sh
```
Renames the live `~/.config/quickshell/ii` to a timestamped backup, rsyncs upstream files into the dots repo (custom files protected), re-creates the symlink.

The script prints warnings for files with custom patches that changed upstream:
- `⚠ StyledPopup.qml` — screen-clamping patch (prevents popup overflow onto second monitor)
- `⚠ BarContent.qml` — MullvadIndicator + BatteryResources additions

If warned, re-apply the patch manually, then commit separately as `custom: ...`.

**2. Commit:**
```bash
git add dots/.config/quickshell/ii
git commit -m "upstream baseline: qs update"
# if custom patches re-applied:
git add dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml \
        dots/.config/quickshell/ii/modules/ii/bar/StyledPopup.qml
git commit -m "custom: re-apply bar patches after qs update"
git push origin main
```

### Custom patches in quickshell

| File | Patch |
|------|-------|
| `modules/ii/bar/StyledPopup.qml` | Screen-clamping: clamps popup `left` margin to `screenWidth - popupWidth` to prevent overflow onto second monitor |
| `modules/ii/bar/BarContent.qml` | Adds `MullvadIndicator` to right section, `BatteryResources` to clock group |

## Hypr Config

See `dots/.config/hypr/CLAUDE.md` for full docs.

Only edit files in `hypr/custom/` — load after upstream defaults, survive updates.

## Quickshell II

See `dots/.config/quickshell/ii/CLAUDE.md` for full docs.

Stack: Quickshell + QML/JS. Entry point: `shell.qml`.  
Personal services in `services/`, bar components in `modules/ii/bar/`.
