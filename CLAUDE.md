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

## Hypr Config (Lua-based)

Entry point: `hyprland.lua` — sources `hyprland/` defaults then `custom/` overrides.

**Only edit files in `hypr/custom/`** — these load after upstream defaults and survive updates.

| File | Purpose |
|------|---------|
| `custom/keybinds.lua` | Extra binds, `hl.unbind()` overrides |
| `custom/rules.lua` | Window rules, monitor layout |
| `custom/general.lua` | Input, decoration, monitor config |
| `custom/execs.lua` | Autostart apps, `hl.on("hyprland.start", ...)` |
| `custom/env.lua` | Environment variables |

### `hl.` API patterns

```lua
-- Keybind
hl.bind("SUPER+T", hl.dsp.exec_cmd("kitty"), {description = "Terminal"})
hl.unbind("SUPER+X")   -- remove upstream bind before rebinding

-- Window rule
hl.window_rule({match = {class = "^discord$"}, workspace = 3, monitor = 1})

-- Monitor
hl.monitor({output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = "1"})

-- Config option
hl.config({ input = { sensitivity = 0.0 } })

-- Autostart (runs once on compositor start)
hl.on("hyprland.start", function()
    hl.exec_cmd("mullvad-vpn")
end)
```

`.old` / `.new` files are install-script backup artifacts — ignore.

## Quickshell II (QML shell)

Full documentation: `dots/.config/quickshell/ii/CLAUDE.md`

Stack: Quickshell + QML/JS + Hyprland. Entry point: `shell.qml`.  
Personal services (MullvadVpn, BatteryUsage) live in `services/`.  
Bar indicators and popups live in `modules/ii/bar/`.  
No `qmldir` needed — Quickshell auto-discovers `.qml` files by directory.
