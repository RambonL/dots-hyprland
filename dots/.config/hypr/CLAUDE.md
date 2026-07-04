# Hypr Config (Lua-based)

Entry point: `hyprland.lua` — sources `hyprland/` defaults then `custom/` overrides.

**Only edit files in `hypr/custom/`** — these load after upstream defaults and survive updates.

| File | Purpose |
|------|---------|
| `custom/keybinds.lua` | Extra binds, `hl.unbind()` overrides |
| `custom/rules.lua` | Window rules, monitor layout |
| `custom/general.lua` | Input, decoration, monitor config |
| `custom/execs.lua` | Autostart apps, `hl.on("hyprland.start", ...)` |
| `custom/env.lua` | Environment variables |

## `hl.` API patterns

```lua
-- Keybind
hl.bind("SUPER+T", hl.dsp.exec_cmd("kitty"), {description = "Terminal"})
hl.unbind("SUPER+X")   -- remove upstream bind before rebinding

-- Window rule (monitor must be string name, not integer)
hl.window_rule({match = {class = "^discord$"}, workspace = 3, monitor = "DP-1"})

-- Monitor
hl.monitor({output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = "1"})

-- Config option
hl.config({ input = { sensitivity = 0.0 } })

-- Autostart (runs once on compositor start)
hl.on("hyprland.start", function()
    hl.exec_cmd("some-app")
end)

-- Dispatch (also works for monitor focus, not just workspace/direction)
hl.dispatch(hl.dsp.focus({ monitor = "HDMI-A-1" }))
hl.dispatch(hl.dsp.focus({ workspace = 21 }))
```

## Lua-Hyprland dispatch gotchas

Classic `hyprctl dispatch focusmonitor DP-1` syntax **does not work** under Lua-based Hyprland — dispatch arguments are parsed as Lua expressions (`dispatch X` becomes `hl.dispatch(X)`). This is the same root cause as the upstream hypridle/hyprsunset fixes.

- From shell: `hyprctl dispatch 'hl.dsp.focus({ monitor = "HDMI-A-1" })'`
- From config: use `hl.dispatch(hl.dsp.focus({...}))` directly — no `hl.exec_cmd("hyprctl ...")` detour.
- `hl.dsp.focus` accepts `monitor =`, `workspace =`, and `direction =` (all live-tested).

## Monitors

| Output | Resolution | Role |
|--------|-----------|------|
| `DP-1` | 2560x1440@165 | Main (1440p, KTC) — monitor id 0 |
| `DP-2` | 1920x1080@144 | Secondary (Dell) — monitor id 1 |
| `HDMI-A-1` | 1920x1080@165 | Occasional (only sometimes on) — monitor id 2 when connected |

## Workspace Groups

`workspaceGroupSize = 10` (defined in `hyprland/variables.lua`).

| Monitor | Workspace range | Formula |
|---------|----------------|---------|
| DP-1 (id 0) | WS 1–10 | `0 * 10 + i` |
| DP-2 (id 1) | WS 11–20 | `1 * 10 + i` |
| HDMI-A-1 (id 2) | WS 21–30 | `2 * 10 + i` |

`SUPER+1–9` is overridden in `custom/keybinds.lua` to always use the **focused monitor's** group — pressing `SUPER+5` on DP-1 goes to WS 5, on DP-2 goes to WS 15.

**No workspace→monitor rules exist** — the group scheme is purely dynamic via keybinds (`active_monitor.id * 10 + i`). At compositor start, Hyprland assigns each monitor the next free WS (1, 2, 3 …), so `custom/execs.lua` dispatches each connected monitor to its group start (`id * workspaceGroupSize + 1`) in the `hyprland.start` handler. Iterates `hl.get_monitors()` sorted by id descending, so focus ends on DP-1.

**Hotplug** is handled by a `monitor.added` handler in `custom/execs.lua`: newly connected monitors (HDMI) jump to their group-start WS, focus is restored to the previously active monitor. Findings (live-tested with `hyprctl output create headless`):
- Events exist: `monitor.added`, `monitor.removed`, `monitor.focused` (also `hyprland.start/shutdown`, `window.*`, `workspace.*` — from binary strings).
- Callback receives a monitor **userdata** object with `.name` and `.id`.
- `hl.dsp.workspace.move` on a non-existent workspace is a **silent no-op** — use `hl.dsp.focus({ workspace = N })` to create it, then refocus the previous monitor.

## Custom Keybinds (keybinds.lua)

| Keybind | Action |
|---------|--------|
| `SUPER+1–9` | Focus workspace i on active monitor's group |
| `CTRL+SUPER+1–9` | Focus workspace i on DP-2 (always group 1) |
| `CTRL+SHIFT+SUPER+1–9` | Move window to WS i on DP-1 ↔ DP-2 (follow) |
| `SUPER+SHIFT+M` | Move window to same-position WS on next monitor (follow) |
| `CTRL+SHIFT+SUPER+M` | Move window to same-position WS on next monitor (silent) |

## Window Rules

`monitor` field requires string (output name), not integer — integers are silently ignored.  
`class` must match exactly — verify with `hyprctl clients -j | python3 -c "import sys,json; [print(c['class']) for c in json.load(sys.stdin)]"`.

Convention: DP-1 apps → WS 1–10; DP-2 background apps → WS 20.

## Upstream Keybind Triple-Fire Bug

Upstream binds each number key **three times** per combo (key name + `code:numberkey` + `code:numpadkey`). For actions that move the active window (`window.move`), all three fire in sequence — each callback sees the *new* active window after the previous move, causing 2–3 windows to move instead of 1.

**Affected upstream binds:** `SUPER+ALT+N` (send window to WS N).  
**Fix in `custom/keybinds.lua`:** `hl.unbind` the keycode variants, keep only the key name bind.

```lua
for i = 1, 10 do
    hl.unbind("SUPER + ALT + code:" .. numberkey[i])
    hl.unbind("SUPER + ALT + code:" .. numpadkey[i])
end
```

Focus-only actions (like `SUPER+N`) are safe with triple-fire since focusing the same WS twice is idempotent.

## Notes

`.old` / `.new` files are install-script backup artifacts — ignore.

`hyprland/colors.lua` is generated by matugen on wallpaper change — gitignored, do not commit.
