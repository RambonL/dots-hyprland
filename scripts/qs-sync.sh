#!/usr/bin/env bash
# Run after dots-hyprland install script to sync quickshell upstream changes into the dots repo.
# Edit qs-custom.conf to manage custom/patched files — do not edit this script.

set -e

QS_LIVE="$HOME/.config/quickshell/ii"
QS_DOTS="$HOME/dots/dots/.config/quickshell/ii"
BACKUP="$HOME/.config/quickshell/ii.bak.$(date +%Y%m%d-%H%M%S)"
CONF="$(dirname "$0")/qs-custom.conf"

CUSTOM_EXCLUDES=()
PATCH_WARN=()

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    [[ "$line" == EXCLUDE:* ]] && CUSTOM_EXCLUDES+=("${line#EXCLUDE:}")
    [[ "$line" == PATCH:* ]]   && PATCH_WARN+=("${line#PATCH:}")
done < "$CONF"

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

echo ""
echo "=== Manual checks needed ==="
for f in "${PATCH_WARN[@]}"; do
    if ! diff -q "$BACKUP/$f" "$QS_DOTS/$f" &>/dev/null; then
        echo "⚠  $f changed upstream — re-apply custom patch manually"
    fi
done

echo ""
echo "=== Restoring symlinks ==="
FISH_LIVE="$HOME/.config/fish/config.fish"
FISH_DOTS="$HOME/dots/dots/.config/fish/config.fish"
if [ ! -L "$FISH_LIVE" ]; then
    echo "→ Restoring fish config symlink"
    ln -sf "$FISH_DOTS" "$FISH_LIVE"
else
    echo "✓ fish config symlink intact"
fi

echo ""
echo "Then commit:"
echo "  git add dots/.config/quickshell/ii"
echo "  git commit -m 'upstream baseline: qs update'"
