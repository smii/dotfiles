#!/usr/bin/env bash
# link.sh - Profile-aware config linker
# Creates symlinks for shared configs AND profile-specific overrides.
#
# Usage:
#   bash scripts/link.sh                        # Auto-detect profile
#   DOTFILES_PROFILE=desktop bash scripts/link.sh  # Force profile
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIGS="$DOTFILES/configs"
PROFILES="$DOTFILES/profiles"
CONFIG="$HOME/.config"

# ==========================================
# Profile detection
# ==========================================
if [[ -z "${DOTFILES_PROFILE:-}" ]]; then
    DOTFILES_PROFILE=$(bash "$PROFILES/detect.sh")
fi

PROFILE_DIR="$PROFILES/$DOTFILES_PROFILE"

if [[ ! -d "$PROFILE_DIR" ]]; then
    echo "✗ Profile not found: $DOTFILES_PROFILE"
    echo "  Available: $(ls -1 "$PROFILES" | grep -v '\.sh$\|\.txt$' | tr '\n' ' ')"
    exit 1
fi

echo "═══════════════════════════════════════"
echo " Linking configs (profile: $DOTFILES_PROFILE)"
echo "═══════════════════════════════════════"

mkdir -p "$CONFIG"

# ==========================================
# Link shared config directories
# ==========================================
link() {
    local name="$1"
    local src="$CONFIGS/$name"
    local dest="$CONFIG/$name"

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "→ $name already exists, skipping"
    else
        echo "→ Linking $name"
        ln -s "$src" "$dest"
    fi
}

link hypr
link waybar
link nvim
link winapps

# ==========================================
# Deploy SSH config (not a symlink — copied with correct perms)
# ==========================================
SSH_SRC="$DOTFILES/configs/ssh"
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -f "$SSH_SRC/config" ]]; then
    cp "$SSH_SRC/config" "$SSH_DIR/config"
    chmod 600 "$SSH_DIR/config"
    echo "→ SSH config deployed"
fi
if [[ -f "$SSH_SRC/authorized_keys" ]]; then
    if [[ ! -f "$SSH_DIR/authorized_keys" ]]; then
        cp "$SSH_SRC/authorized_keys" "$SSH_DIR/authorized_keys"
    else
        # Merge without duplicates
        cat "$SSH_SRC/authorized_keys" >> "$SSH_DIR/authorized_keys"
        sort -u -o "$SSH_DIR/authorized_keys" "$SSH_DIR/authorized_keys"
    fi
    chmod 600 "$SSH_DIR/authorized_keys"
    echo "→ SSH authorized_keys deployed"
fi

# ==========================================
# Link profile-specific overrides
# ==========================================
echo ""
echo "Applying profile: $DOTFILES_PROFILE"

# Hyprland profile: configs/hypr/profile → profiles/<name>/hypr (absolute)
HYPR_PROFILE_LINK="$CONFIGS/hypr/profile"
HYPR_PROFILE_TARGET="$PROFILES/$DOTFILES_PROFILE/hypr"

if [[ -L "$HYPR_PROFILE_LINK" ]]; then
    rm "$HYPR_PROFILE_LINK"
fi
if [[ -e "$HYPR_PROFILE_LINK" ]]; then
    echo "✗ $HYPR_PROFILE_LINK exists but is not a symlink - please remove manually"
else
    echo "→ Linking hypr profile → $DOTFILES_PROFILE"
    ln -s "$HYPR_PROFILE_TARGET" "$HYPR_PROFILE_LINK"
fi

# Waybar profile: configs/waybar/config.jsonc → profiles/<name>/waybar/config.jsonc (absolute)
WAYBAR_CONFIG="$CONFIGS/waybar/config.jsonc"
WAYBAR_PROFILE_TARGET="$PROFILES/$DOTFILES_PROFILE/waybar/config.jsonc"

if [[ -L "$WAYBAR_CONFIG" ]]; then
    rm "$WAYBAR_CONFIG"
fi
if [[ -f "$WAYBAR_CONFIG" && ! -L "$WAYBAR_CONFIG" ]]; then
    echo "→ Backing up existing waybar config.jsonc"
    mv "$WAYBAR_CONFIG" "${WAYBAR_CONFIG}.bak.$(date +%s)"
fi
echo "→ Linking waybar config → $DOTFILES_PROFILE"
ln -s "$WAYBAR_PROFILE_TARGET" "$WAYBAR_CONFIG"

# ==========================================
# Save active profile
# ==========================================
echo "$DOTFILES_PROFILE" > "$DOTFILES/.active-profile"

echo ""
echo "✔ All configs linked (profile: $DOTFILES_PROFILE)"
echo "  Hypr profile: $HYPR_PROFILE_LINK → $HYPR_PROFILE_TARGET"
echo "  Waybar config: $WAYBAR_CONFIG → $WAYBAR_PROFILE_TARGET"

