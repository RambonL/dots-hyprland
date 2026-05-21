-- Apps
hl.bind("CTRL+SUPER+ALT+Slash",   hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),             {description = "Custom: Edit user keybinds"})
hl.bind("CTRL+SUPER+Slash",       hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"),         {description = "Custom: Edit shell config"})

-- Shell
hl.bind("SUPER+SHIFT+minus",      hl.dsp.global("quickshell:cheatsheetToggle"),                                {description = "Custom: Toggle cheatsheet"})

-- Discord
hl.bind("CTRL+SHIFT+KP_Multiply", hl.dsp.exec_cmd("~/.local/bin/discord_mic_toggle"),                         {description = "Custom: Discord Mute"})
hl.bind("CTRL+SHIFT+KP_Divide",   hl.dsp.exec_cmd("~/.local/bin/discord_deafen_toggle"),                      {description = "Custom: Discord Full-Mute"})

-- Wayscriber
hl.unbind("SUPER + X")
hl.bind("SUPER+X", hl.dsp.exec_cmd([[bash -lc "kill -USR1 $(pgrep -fo 'wayscriber --daemon')"]]),             {description = "Custom: Toggle Wayscriber"})

-- Workspace: per-monitor groups (SUPER+N uses monitor's WS group)
local function monitor_ws(i)
    return hl.get_active_monitor().id * workspaceGroupSize + i
end

local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

for i = 1, 10 do
    hl.unbind("SUPER + " .. (i % 10))
    hl.unbind("SUPER + code:" .. numberkey[i])
    hl.unbind("SUPER + code:" .. numpadkey[i])
    hl.bind("SUPER + " .. (i % 10), function()
        hl.dispatch(hl.dsp.focus({ workspace = monitor_ws(i) }))
    end, { description = "Custom: Workspace focus " .. i })
    hl.bind("SUPER + code:" .. numberkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = monitor_ws(i) }))
    end)
    hl.bind("SUPER + code:" .. numpadkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = monitor_ws(i) }))
    end)
end

-- CTRL+SHIFT+SUPER+N: send window to WS N on DP-1 ↔ DP-2 (follow)
for i = 1, 10 do
    local function send_to_other(pos)
        local mon = hl.get_active_monitor()
        if not mon then return end
        local target_group = (mon.id == 0) and 1 or 0
        local target_ws = target_group * workspaceGroupSize + pos
        local target_mon = hl.get_monitor(target_group)
        -- local dbg = "mon=" .. tostring(mon.id) .. " tg=" .. tostring(target_group) .. " tw=" .. tostring(target_ws) .. " tm=" .. tostring(target_mon and target_mon.name or "nil")
        -- hl.dispatch(hl.dsp.exec_cmd("bash -c 'echo \"" .. dbg .. "\" >> /tmp/hypr_debug.txt'"))
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(target_ws), follow = true }))
        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(target_ws), monitor = target_mon.name }))
    end
    hl.bind("CTRL + SHIFT + SUPER + " .. (i % 10), function() send_to_other(i) end,
        { description = "Custom: Move window to WS " .. i .. " on other monitor" })
end

-- CTRL+SUPER+N: focus WS N on DP-2
for i = 1, 10 do
    hl.bind("CTRL + SUPER + " .. (i % 10), function()
        hl.dispatch(hl.dsp.focus({ workspace = 1 * workspaceGroupSize + i }))
    end, { description = "Custom: Focus WS " .. i .. " on DP-2" })
end

-- Monitor: move window to same WS on next monitor group (silent)
hl.bind("CTRL+SHIFT+SUPER+M", function()
    local ws         = hl.get_active_workspace()
    if not ws or ws.id < 0 then return end
    local num_mon    = #hl.get_monitors()
    local group      = math.floor((ws.id - 1) / workspaceGroupSize)
    local pos        = ((ws.id - 1) % workspaceGroupSize) + 1
    local next_group = (group + 1) % num_mon
    local target_ws  = next_group * workspaceGroupSize + pos
    local target_mon = hl.get_monitor(next_group)
    local prev_ws    = hl.get_active_workspace()
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(target_ws), follow = false }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(target_ws), monitor = target_mon.name }))
    hl.dispatch(hl.dsp.focus({ workspace = prev_ws.name }))
    hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch focuscurrentorlast"))
end, {description = "Custom: Move window to same WS on next monitor (silent)"})

hl.unbind("SUPER + SHIFT + M")
hl.bind("SUPER+SHIFT+M", function()
    local ws         = hl.get_active_workspace()
    if not ws or ws.id < 0 then return end
    local num_mon    = #hl.get_monitors()
    local group      = math.floor((ws.id - 1) / workspaceGroupSize)
    local pos        = ((ws.id - 1) % workspaceGroupSize) + 1
    local next_group = (group + 1) % num_mon
    local target_ws  = next_group * workspaceGroupSize + pos
    local target_mon = hl.get_monitor(next_group)
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(target_ws), follow = true }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(target_ws), monitor = target_mon.name }))
end, {description = "Custom: Move window to same WS on next monitor"})
