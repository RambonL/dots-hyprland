hl.monitor({output = "DP-1",     mode = "2560x1440@165", position = "0x0",        scale = "1"})
hl.monitor({output = "DP-2",     mode = "1920x1080@144", position = "2560x0",     scale = "1"})
hl.monitor({output = "HDMI-A-1", mode = "1920x1080@165", position = "1280x-1080", scale = "1"})

hl.config({
    input = {
        accel_profile = "flat",
        sensitivity   = 0.0,
        kb_layout     = "de",
    },
    decoration = {
        active_opacity     = 1.0,
        inactive_opacity   = 1.0,
        fullscreen_opacity = 1.0,
    },
    debug = {
        --suppress_errors = true,
    },
})
