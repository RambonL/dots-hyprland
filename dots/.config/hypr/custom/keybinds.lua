-- Apps
hl.bind("CTRL+SUPER+ALT+Slash",   hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),             {description = "Edit user keybinds"})
hl.bind("CTRL+SUPER+Slash",       hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"),         {description = "Edit shell config"})

-- Shell
hl.bind("SUPER+SHIFT+minus",      hl.dsp.global("quickshell:cheatsheetToggle"),                                {description = "Toggle cheatsheet"})

-- Discord
hl.bind("CTRL+SHIFT+KP_Multiply", hl.dsp.exec_cmd("~/.local/bin/discord_mic_toggle"),                         {description = "Discord Mute"})
hl.bind("CTRL+SHIFT+KP_Divide",   hl.dsp.exec_cmd("~/.local/bin/discord_deafen_toggle"),                      {description = "Discord Full-Mute"})

-- Wayscriber
hl.unbind("SUPER + X")
hl.bind("SUPER+X", hl.dsp.exec_cmd([[bash -lc "kill -USR1 $(pgrep -fo 'wayscriber --daemon')"]]),             {description = "Toggle Wayscriber"})

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
    end, { description = "Workspace: Focus " .. i })
    hl.bind("SUPER + code:" .. numberkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = monitor_ws(i) }))
    end)
    hl.bind("SUPER + code:" .. numpadkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = monitor_ws(i) }))
    end)
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
end, {description = "Move window to same WS on next monitor (silent)"})

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
end, {description = "Move window to same WS on next monitor"})
