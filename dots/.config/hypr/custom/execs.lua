hl.on("hyprland.start", function()
    -- hl.exec_cmd("mullvad-vpn")  -- daemon runs via systemd
    hl.exec_cmd("python /usr/bin/streamdeck --no-ui")
    hl.exec_cmd("keepassxc")
    hl.exec_cmd("WAYSCRIBER_TRAY_FORCE_PIXMAP=1 wayscriber --daemon")
    hl.exec_cmd("discord --ozone-platform=x11")
end)

hl.window_rule({match = {class = "^brave-origin-beta$"},          workspace = 1,  monitor = "DP-1"})
hl.window_rule({match = {class = "^code-oss$"},                   workspace = 4,  monitor = "DP-1"})
hl.window_rule({match = {class = "^discord$"},                    workspace = 13,  monitor = "DP-2"})
hl.window_rule({match = {class = "^Mullvad VPN$"},                workspace = 20, monitor = "DP-2"})
hl.window_rule({match = {class = "^python3$"},                    workspace = 20, monitor = "DP-2"})
hl.window_rule({match = {class = "^org.keepassxc.KeePassXC$"},   workspace = 20, monitor = "DP-2"})
