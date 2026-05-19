# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo

Fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)  
Own fork: `https://github.com/RambonL/dots-hyprland`  
Local clone: `~/dots/`

Configs live under `~/dots/dots/.config/` and are symlinked:
- `~/.config/quickshell/ii` → `~/dots/dots/.config/quickshell/ii`
- `~/.config/hypr` → `~/dots/dots/.config/hypr`

**If something looks missing or broken, verify symlinks first:**
```bash
ls -la ~/.config/hypr ~/.config/quickshell/ii
```
Both must show `->` (symlink). If either is a real directory, the upstream install script overwrote it. Fix:
```bash
mv ~/.config/quickshell/ii ~/.config/quickshell/ii.bak
ln -s ~/dots/dots/.config/quickshell/ii ~/.config/quickshell/ii
```

**The upstream install script overwrites the `quickshell/ii` symlink on every run.** After each upstream sync, re-check and re-create the symlink if needed.

## Commits

Never add `Co-Authored-By` trailers to commits.

Two separate commits — important for clean rebasing:

| Commit | Content | Touch? |
|--------|---------|--------|
| `upstream baseline` | upstream dots-hyprland updates | No |
| `custom: ...` | personal changes | Yes |

## Upstream Update

```bash
cd ~/dots
git fetch upstream
git rebase upstream/main
# Conflicts likely in: BarContent.qml, StyledPopup.qml
# → resolve manually, then:
git rebase --continue
git push origin main
```

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
