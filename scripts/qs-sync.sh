#!/usr/bin/env bash
# Run after dots-hyprland install script to sync quickshell upstream changes into the dots repo.
# Protects custom files, re-creates symlink.

set -e

QS_LIVE="$HOME/.config/quickshell/ii"
QS_DOTS="$HOME/dots/dots/.config/quickshell/ii"
BACKUP="$HOME/.config/quickshell/ii.bak.$(date +%Y%m%d-%H%M%S)"

# Custom files — never overwritten by rsync
CUSTOM_EXCLUDES=(
    "services/MullvadVpn.qml"
    "services/BatteryUsage.qml"
    "modules/ii/bar/MullvadIndicator.qml"
    "modules/ii/bar/MullvadPopup.qml"
    "modules/ii/bar/BatteryResources.qml"
    "modules/ii/bar/BatteryRessource.qml"
    "modules/ii/bar/DevicesBatteryPopup.qml"
    "modules/ii/bar/ResourceUsagePopup.qml"
)

# Already a symlink — nothing to do
if [ -L "$QS_LIVE" ]; then
    echo "Already a symlink, nothing to sync."
    exit 0
fi

if [ ! -d "$QS_LIVE" ]; then
    echo "ERROR: $QS_LIVE not found."
    exit 1
fi

EXCLUDE_ARGS=()
for f in "${CUSTOM_EXCLUDES[@]}"; do
    EXCLUDE_ARGS+=(--exclude="$f")
done

echo "→ Backing up $QS_LIVE to $BACKUP"
mv "$QS_LIVE" "$BACKUP"

echo "→ Syncing upstream files into dots repo (custom files protected)"
rsync -av --delete "${EXCLUDE_ARGS[@]}" "$BACKUP/" "$QS_DOTS/"

echo "→ Re-creating symlink"
ln -s "$QS_DOTS" "$QS_LIVE"

# Files with custom patches — warn if upstream changed them
PATCH_WARN=(
    "modules/ii/bar/StyledPopup.qml"
    "modules/ii/bar/BarContent.qml"
)

echo ""
echo "=== Manual checks needed ==="
for f in "${PATCH_WARN[@]}"; do
    if ! diff -q "$BACKUP/$f" "$QS_DOTS/$f" &>/dev/null; then
        echo "⚠  $f changed upstream — re-apply custom patch manually"
    fi
done

echo ""
echo "Then commit:"
echo "  git add dots/.config/quickshell/ii"
echo "  git commit -m 'upstream baseline: qs update'"
