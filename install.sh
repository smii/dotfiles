#!/bin/bash
# install.sh - Multi-Profile Automated Setup
# Supports: ASUS G14 laptop | ROG Crosshair VIII Impact desktop | Generic
set -e

# ==========================================
# CONSTANTS & PATHS
# ==========================================
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")
DOTFILES="$USER_HOME/.dotfiles"
PROFILES_DIR="$DOTFILES/profiles"

# ==========================================
# 1. PROFILE DETECTION
# ==========================================
echo "═══════════════════════════════════════"
echo " Hardware Profile Detection"
echo "═══════════════════════════════════════"

# Ensure dmidecode is available for hardware identification
sudo pacman -S --needed --noconfirm dmidecode &>/dev/null || true

PROFILE=$(bash "$PROFILES_DIR/detect.sh")
echo "✓ Detected profile: $PROFILE"

# Allow manual override
if [[ -n "${DOTFILES_PROFILE:-}" ]]; then
    PROFILE="$DOTFILES_PROFILE"
    echo "✓ Override: using profile '$PROFILE'"
fi

# Validate profile exists
if [[ ! -d "$PROFILES_DIR/$PROFILE" ]]; then
    echo "✗ Profile directory not found: $PROFILES_DIR/$PROFILE"
    echo "  Available profiles: $(ls -1 "$PROFILES_DIR" | grep -v '\.sh$\|\.txt$' | tr '\n' ' ')"
    exit 1
fi

echo ""
case "$PROFILE" in
    g14)
        echo "  System:  ASUS ROG Zephyrus G14"
        echo "  Kernel:  linux-g14 (custom ASUS)"
        echo "  GPU:     AMD iGPU + NVIDIA dGPU (hybrid)"
        echo "  Extras:  asusctl, supergfxctl, brightness keys"
        ;;
    desktop)
        echo "  System:  ROG Crosshair VIII Impact + RTX 3080"
        echo "  Kernel:  linux (standard)"
        echo "  GPU:     NVIDIA RTX 3080 (dedicated)"
        echo "  Extras:  coolercontrol (NCT6798 fan → GPU temp)"
        echo "  Monitors: DP-1 4K (main) + DP-2 QHD (portrait)"
        ;;
    generic)
        echo "  System:  Generic / Unknown hardware"
        echo "  Kernel:  linux (standard)"
        echo "  GPU:     Default (mesa/modesetting)"
        echo "  Monitors: Auto-detect"
        ;;
esac
echo ""

# ==========================================
# 2. G14 REPOSITORY (G14 only)
# ==========================================
if [[ "$PROFILE" == "g14" ]]; then
    echo "Adding ASUS G14 Repository..."
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        sudo bash -c 'cat <<EOF >> /etc/pacman.conf
[g14]
SigLevel = Optional TrustAll
Server = https://arch.asus-linux.org
EOF'
        echo "✓ G14 repo added to pacman.conf"
    else
        echo "✓ G14 repo already configured"
    fi
fi

# ==========================================
# 3. INITIAL CORE UPDATE
# ==========================================
echo ""
echo "Updating package database..."
sudo pacman -Sy --noconfirm
sudo pacman -S --needed --noconfirm chezmoi bash-completion gum btrfs-assistant snapper git

# ==========================================
# 4. PACKAGE INSTALLATION
# ==========================================
echo ""
echo "═══════════════════════════════════════"
echo " Installing Packages ($PROFILE profile)"
echo "═══════════════════════════════════════"

# Common packages (all profiles)
COMMON_PKGS="$PROFILES_DIR/packages-common.txt"
if [[ -f "$COMMON_PKGS" ]]; then
    echo "Installing common packages..."
    grep -v '^#' "$COMMON_PKGS" | grep -v '^$' | \
        sudo pacman -S --needed --noconfirm - || true
fi

# Profile-specific packages
PROFILE_PKGS="$PROFILES_DIR/$PROFILE/packages.txt"
if [[ -f "$PROFILE_PKGS" ]]; then
    echo "Installing $PROFILE-specific packages..."
    grep -v '^#' "$PROFILE_PKGS" | grep -v '^$' | \
        sudo pacman -S --needed --noconfirm - || true
fi

# ==========================================
# 5. PROFILE-SPECIFIC SERVICES
# ==========================================
echo ""
echo "Configuring profile-specific services..."

case "$PROFILE" in
    desktop)
        # CoolerControl for GPU fan management via NCT6798
        if pacman -Qi coolercontrol &>/dev/null; then
            echo "Enabling CoolerControl daemon..."
            sudo systemctl enable --now coolercontrold || true
            echo "✓ CoolerControl enabled (configure GPU_MOBO_FAN → NCT6798/FAN 1)"
        fi
        ;;
    g14)
        # ASUS system daemons
        if pacman -Qi supergfxctl &>/dev/null; then
            sudo systemctl enable --now supergfxd || true
            echo "✓ supergfxd enabled"
        fi
        if pacman -Qi asusctl &>/dev/null; then
            sudo systemctl enable --now asusd || true
            echo "✓ asusd enabled"
        fi
        if pacman -Qi power-profiles-daemon &>/dev/null; then
            sudo systemctl enable --now power-profiles-daemon || true
        fi
        ;;
esac

# ==========================================
# 6. NETWORK & LOCAL DOMAIN RESOLUTION
# ==========================================
echo ""
echo "Configuring DHCP domain discovery..."
sudo sed -i 's/^hosts:.*/hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
for netfile in /etc/systemd/network/*.network; do
    [[ -e "$netfile" ]] || continue
    if ! grep -q "UseDomains=yes" "$netfile"; then
        sudo bash -c "echo -e '\n[DHCPv4]\nUseDomains=yes\n\n[DHCPv6]\nUseDomains=yes' >> $netfile"
    fi
done
sudo systemctl restart systemd-networkd systemd-resolved || true

# ==========================================
# 7. PRIVILEGED ACCESS (SUDOERS)
# ==========================================
echo ""
echo "Setting up NOPASSWD for $REAL_USER..."
SUDO_FILE="/etc/sudoers.d/00_$REAL_USER"
sudo bash -c "cat <<EOF > $SUDO_FILE
$REAL_USER ALL=(ALL) ALL
$REAL_USER ALL=(ALL:ALL) NOPASSWD: /usr/sbin/ufw, /usr/bin/tufw, /usr/bin/iptstate, /usr/bin/netscanner
EOF"
sudo chmod 0440 "$SUDO_FILE"

# ==========================================
# 8. SSH KEY DEPLOYMENT
# ==========================================
echo ""
echo "Deploying SSH keys..."
SSH_DIR="$USER_HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Deploy public key
SSH_SRC="$DOTFILES/configs/ssh"
if [[ -f "$SSH_SRC/authorized_keys" ]]; then
    if [[ ! -f "$SSH_DIR/authorized_keys" ]] || ! grep -qf "$SSH_SRC/authorized_keys" "$SSH_DIR/authorized_keys" 2>/dev/null; then
        cat "$SSH_SRC/authorized_keys" >> "$SSH_DIR/authorized_keys"
        sort -u -o "$SSH_DIR/authorized_keys" "$SSH_DIR/authorized_keys"
        chmod 600 "$SSH_DIR/authorized_keys"
        echo "✓ Public key added to authorized_keys"
    else
        echo "✓ Public key already in authorized_keys"
    fi
fi

# Deploy SSH config
if [[ -f "$SSH_SRC/config" ]]; then
    cp "$SSH_SRC/config" "$SSH_DIR/config"
    chmod 600 "$SSH_DIR/config"
    echo "✓ SSH config deployed"
fi

# Generate host key pair if missing
if [[ ! -f "$SSH_DIR/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -f "$SSH_DIR/id_ed25519" -N "" -C "$REAL_USER@$(hostname)"
    echo "✓ New ed25519 key generated"
    echo "  Public key: $(cat "$SSH_DIR/id_ed25519.pub")"
else
    echo "✓ SSH key pair already exists"
fi

chown -R "$REAL_USER:$REAL_USER" "$SSH_DIR"

# Enable SSH daemon
sudo systemctl enable --now sshd || true
echo "✓ SSH daemon enabled"

# ==========================================
# 9. VIRTUALIZATION
# ==========================================
echo ""
echo "Configuring QEMU/KVM..."
sudo pacman -S --needed --noconfirm qemu-full virt-manager virt-viewer dnsmasq vde2 \
    openbsd-netcat freerdp libvirt
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm "$REAL_USER"

# ==========================================
# 10. DOTFILES DEPLOYMENT (link configs + profile)
# ==========================================
echo ""
echo "═══════════════════════════════════════"
echo " Deploying Dotfiles ($PROFILE profile)"
echo "═══════════════════════════════════════"

# Run the profile-aware link script
if [[ -f "$DOTFILES/scripts/link.sh" ]]; then
    export DOTFILES_PROFILE="$PROFILE"
    bash "$DOTFILES/scripts/link.sh"
fi

# Chezmoi deployment (if using chezmoi templates)
if command -v chezmoi &>/dev/null && [[ -d "$DOTFILES/configs" ]]; then
    echo "Deploying configs with chezmoi..."
    chezmoi init --source "$DOTFILES/configs"
    chezmoi apply --force
fi

# Reload Hyprland if running
if pgrep -x "Hyprland" > /dev/null; then
    hyprctl reload
    echo "✓ Hyprland reloaded"
fi

# ==========================================
# 11. WINAPPS (Windows 10 via Docker)
# ==========================================
echo ""
echo "═══════════════════════════════════════"
echo " WinApps Setup"
echo "═══════════════════════════════════════"

# Ensure Docker is available
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx
sudo systemctl enable --now docker
sudo usermod -aG docker "$REAL_USER"

# Ensure ~/.local/bin is in PATH for winapps
export PATH="$USER_HOME/.local/bin:$PATH"

# Run WinApps setup script (fully non-interactive)
if [[ -f "$DOTFILES/scripts/setup-winapps.sh" ]]; then
    echo "Running automated WinApps setup (non-interactive)..."
    sudo -u "$REAL_USER" bash "$DOTFILES/scripts/setup-winapps.sh" || {
        echo "⚠ WinApps setup encountered issues. Run manually:"
        echo "  bash ~/.dotfiles/scripts/setup-winapps.sh"
    }
fi

# ==========================================
# 12. SYSTEM CLEANER
# ==========================================
CLEANER_DIR="$USER_HOME/.local/share/omarchy-cleaner"
[[ ! -d "$CLEANER_DIR" ]] && git clone https://github.com/maxart/omarchy-cleaner "$CLEANER_DIR"
[[ -f "$CLEANER_DIR/remove-bloat.sh" ]] && bash "$CLEANER_DIR/remove-bloat.sh"

# ==========================================
# DONE
# ==========================================
echo ""
echo "═══════════════════════════════════════"
echo " Setup Complete! (Profile: $PROFILE)"
echo "═══════════════════════════════════════"
echo ""
echo "Active profile: $PROFILE"
echo "Profile dir:    $PROFILES_DIR/$PROFILE"
echo ""
echo "To switch profiles:  DOTFILES_PROFILE=<name> bash install.sh"
echo "To relink configs:   DOTFILES_PROFILE=<name> bash scripts/link.sh"
echo ""
echo "Please reboot to apply all changes."
