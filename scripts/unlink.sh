#!/usr/bin/env bash
# unlink.sh - Remove config symlinks and profile links
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIGS="$DOTFILES/configs"
CONFIG="$HOME/.config"

echo "═══════════════════════════════════════"
echo " Unlinking configs"
echo "═══════════════════════════════════════"

unlink_cfg() {
    local name="$1"
    local dest="$CONFIG/$name"

    if [[ -L "$dest" ]]; then
        echo "→ Unlinking $name"
        rm "$dest"
    else
        echo "→ $name is not a symlink, skipping"
    fi
}

unlink_cfg hypr
unlink_cfg waybar
unlink_cfg nvim
unlink_cfg winapps

# Clean up profile symlinks
echo ""
echo "Cleaning profile links..."

HYPR_PROFILE="$CONFIGS/hypr/profile"
if [[ -L "$HYPR_PROFILE" ]]; then
    echo "→ Removing hypr profile link"
    rm "$HYPR_PROFILE"
fi

WAYBAR_CONFIG="$CONFIGS/waybar/config.jsonc"
if [[ -L "$WAYBAR_CONFIG" ]]; then
    echo "→ Removing waybar profile link"
    rm "$WAYBAR_CONFIG"
    # Restore backup if exists
    BACKUP=$(ls -t "${WAYBAR_CONFIG}".bak.* 2>/dev/null | head -1)
    if [[ -n "$BACKUP" ]]; then
        echo "→ Restoring waybar config from backup"
        mv "$BACKUP" "$WAYBAR_CONFIG"
    fi
fi

# Remove active profile marker
rm -f "$DOTFILES/.active-profile"

echo ""
echo "✔ Symlinks removed"

