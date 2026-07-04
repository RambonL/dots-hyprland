hl.on("hyprland.start", function()
    -- Start-WS pro Monitor auf Gruppenanfang setzen (id*10+1: DP-1=1, DP-2=11, HDMI=21)
    -- nur angeschlossene Monitore; absteigend nach id, damit Fokus auf DP-1 endet
    local mons = hl.get_monitors()
    table.sort(mons, function(a, b) return a.id > b.id end)
    for _, m in ipairs(mons) do
        hl.dispatch(hl.dsp.focus({ monitor = m.name }))
        hl.dispatch(hl.dsp.focus({ workspace = m.id * workspaceGroupSize + 1 }))
    end
    -- hl.exec_cmd("mullvad-vpn")  -- daemon runs via systemd
    hl.exec_cmd("systemctl --user start graphical-session.target")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("python /usr/bin/streamdeck --no-ui")
    hl.exec_cmd("keepassxc")
    hl.exec_cmd("WAYSCRIBER_TRAY_FORCE_PIXMAP=1 wayscriber --daemon")
    hl.exec_cmd("bash -c 'sleep 3 && discord --ozone-platform=x11'")
    hl.exec_cmd("env SKIKO_RENDER_API=SOFTWARE ABDownloadManager --background")
end)

-- Hotplug: neuer Monitor springt auf seinen Gruppen-WS (id*10+1), Fokus bleibt
-- workspace.move geht nicht (No-op auf nicht-existente WS) — focus erzeugt den WS
hl.on("monitor.added", function(m)
    local prev = hl.get_active_monitor().name
    hl.dispatch(hl.dsp.focus({ monitor = m.name }))
    hl.dispatch(hl.dsp.focus({ workspace = m.id * workspaceGroupSize + 1 }))
    hl.dispatch(hl.dsp.focus({ monitor = prev }))
end)

hl.window_rule({match = {class = "^brave-origin-beta$"},          			workspace = 1,  monitor = "DP-1"})
hl.window_rule({match = {class = "^code-oss$"},                   			workspace = 3,  monitor = "DP-1"})
hl.window_rule({match = {class = "^discord$"},                    			workspace = 13,  monitor = "DP-2"})
hl.window_rule({match = {class = "^Mullvad VPN$"},                			workspace = 20, monitor = "DP-2"})
hl.window_rule({match = {class = "^python3$"},                    			workspace = 20, monitor = "DP-2"})
hl.window_rule({match = {class = "^org.keepassxc.KeePassXC$"},   			workspace = 20, monitor = "DP-2"})
hl.window_rule({match = {class = "^teams-for-linux$"},   					workspace = 19, monitor = "DP-2"})
hl.window_rule({match = {class = "^com-abdownloadmanager-desktop-AppKt$"}, 	workspace = 20, monitor = "DP-2"})
