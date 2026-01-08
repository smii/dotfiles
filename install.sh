#!/bin/bash
# install.sh - Automated Setup (Universal with ASUS G14 Support)
set -e

# Define current user correctly
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")

# HARDWARE DETECTION
echo "Detecting hardware..."
PRODUCT_NAME=$(sudo dmidecode -s system-product-name 2>/dev/null || echo "Unknown")
IS_ASUS_G14=false

if echo "$PRODUCT_NAME" | grep -qiE "ROG.*G14|GA40[0-9]"; then
    IS_ASUS_G14=true
    echo "✓ ASUS G14 detected: $PRODUCT_NAME"
else
    echo "✓ Hardware: $PRODUCT_NAME (Generic installation)"
fi

# 1. G14 REPOSITORY SETUP
if [ "$IS_ASUS_G14" = true ]; then
    echo "Adding ASUS G14 Repository..."
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        sudo bash -c 'cat <<EOF >> /etc/pacman.conf
[g14]
SigLevel = Optional TrustAll
Server = https://arch.asus-linux.org
EOF'
    fi
    
    # Enable ASUS specific configs in Hyprland
    HYPR_CONF="$USER_HOME/.config/hypr/hyprland.conf"
    if [ -f "$HYPR_CONF" ]; then
        if ! grep -q "asus-specific.conf" "$HYPR_CONF"; then
            echo "source = ~/.config/hypr/asus-specific.conf" >> "$HYPR_CONF"
        else
            # Uncomment the line if it already exists but is commented out
            sed -i 's|^# \(source = ~/.config/hypr/asus-specific.conf\)|\1|' "$HYPR_CONF"
        fi
    fi
fi

# 2. INITIAL CORE UPDATE
sudo pacman -Sy --noconfirm
sudo pacman -S --needed --noconfirm chezmoi bash-completion gum btrfs-assistant snapper git

# 3. NETWORK & LOCAL DOMAIN RESOLUTION
echo "Configuring DHCP domain discovery..."
sudo sed -i 's/^hosts:.*/hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
for netfile in /etc/systemd/network/*.network; do
    [ -e "$netfile" ] || continue
    if ! grep -q "UseDomains=yes" "$netfile"; then
        sudo bash -c "echo -e '\n[DHCPv4]\nUseDomains=yes\n\n[DHCPv6]\nUseDomains=yes' >> $netfile"
    fi
done
sudo systemctl restart systemd-networkd systemd-resolved || true

# 4. PRIVILEGED ACCESS (SUDOERS)
echo "Setting up NOPASSWD for $REAL_USER..."
SUDO_FILE="/etc/sudoers.d/00_$REAL_USER"
sudo bash -c "cat <<EOF > $SUDO_FILE
$REAL_USER ALL=(ALL) ALL
$REAL_USER ALL=(ALL:ALL) NOPASSWD: /usr/sbin/ufw, /usr/bin/tufw, /usr/bin/iptstate, /usr/bin/netscanner
EOF"
sudo chmod 0440 "$SUDO_FILE"

# 5. BULK PACKAGE INSTALLATION
PKGLIST="$USER_HOME/.dotfiles/pkglist.txt"
if [ -f "$PKGLIST" ]; then
    echo "Installing software from pkglist.txt..."
    if [ "$IS_ASUS_G14" = true ]; then
        sudo pacman -S --needed --noconfirm - < "$PKGLIST"
    else
        # Filter out ASUS-specific packages
        grep -v -E '^(linux-g14|asusctl|supergfxctl|rog-control-center)' "$PKGLIST" | \
            grep -v '^#' | grep -v '^$' | \
            sudo pacman -S --needed --noconfirm -
    fi
fi

# 6. VIRTUALIZATION
echo "Configuring QEMU/KVM..."
sudo pacman -S --needed --noconfirm qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils \
    openbsd-netcat freerdp libvirt nvidia-container-toolkit
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm "$REAL_USER"

# 7. DOTFILES DEPLOYMENT
if [ -d "$USER_HOME/.dotfiles/configs" ]; then
    echo "Deploying configs with chezmoi..."
    chezmoi init --source "$USER_HOME/.dotfiles/configs"
    chezmoi apply --force
fi

# Only reload if Hyprland is actually active
if pgrep -x "Hyprland" > /dev/null; then
    hyprctl reload
fi

# 8. CLEANER
CLEANER_DIR="$USER_HOME/.local/share/omarchy-cleaner"
[ ! -d "$CLEANER_DIR" ] && git clone https://github.com/maxart/omarchy-cleaner "$CLEANER_DIR"
[ -f "$CLEANER_DIR/remove-bloat.sh" ] && bash "$CLEANER_DIR/remove-bloat.sh"

echo "Setup Complete! Please reboot."
