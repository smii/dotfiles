#!/bin/bash
# install.sh - Automated Setup (Universal with ASUS G14 Support)
set -e

# HARDWARE DETECTION
echo "Detecting hardware..."
PRODUCT_NAME=$(sudo dmidecode -s system-product-name 2>/dev/null || echo "Unknown")
IS_ASUS_G14=false
USERNAME=$USER
# Check if this is an ASUS G14 (matches various G14 models)
if echo "$PRODUCT_NAME" | grep -qiE "ROG.*G14|GA40[0-9]"; then
    IS_ASUS_G14=true
    echo "✓ ASUS G14 detected: $PRODUCT_NAME"
    echo "  ASUS-specific packages will be installed."
else
    echo "✓ Hardware: $PRODUCT_NAME"
    echo "  Generic installation (skipping ASUS-specific packages)"
fi
echo ""

# 1. G14 REPOSITORY SETUP (CONDITIONAL)
if [ "$IS_ASUS_G14" = true ]; then
    echo "Adding ASUS G14 Repository..."
    if ! grep -q "\[g14\]" /etc/pacman.conf; then
        sudo bash -c 'cat <<EOF >> /etc/pacman.conf
[g14]
SigLevel = Optional TrustAll
Server = https://arch.asus-linux.org
EOF'
    echo "Updating Brightness controls"
    if ! grep -q "\asus\]" $HOME/.config/hypr/hyprland.conf; then
        sudo bash -c 'cat <<EOF >> /$HOME/.config/hypr/hyprland.conf
source = ~/.config/hypr/asus-specific.conf'
    else 
      sed -i 's/^# \(source = ~\/\.config\/hypr\/asus-specific\.conf\)/\1/' ~/.dotfiles/configs/hypr/hyprland.conf
    fi
else
    echo "Skipping ASUS G14 repository (not G14 hardware)..."
fi

# 2. INITIAL CORE UPDATE
sudo pacman -Sy --noconfirm
sudo pacman -S --needed --noconfirm chezmoi bash-completion gum btrfs-assistant snapper git

# 3. NETWORK & LOCAL DOMAIN RESOLUTION
echo "Configuring DHCP domain discovery..."
sudo sed -i 's/^hosts:.*/hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns/' /etc/nsswitch.conf
for netfile in /etc/systemd/network/*.network; do
    if ! grep -q "UseDomains=yes" "$netfile"; then
        sudo bash -c "echo -e '\n[DHCPv4]\nUseDomains=yes\n\n[DHCPv6]\nUseDomains=yes' >> $netfile"
    fi
done
sudo systemctl restart systemd-networkd systemd-resolved

# 4. PRIVILEGED ACCESS (SUDOERS)
echo "Setting up NOPASSWD for TUI Network tools..."
sudo bash -c "cat <<EOF > /etc/sudoers.d/00_$(USER)
mlopes ALL=(ALL) ALL
mlopes ALL=(ALL:ALL) NOPASSWD: /usr/sbin/ufw, /usr/bin/tufw, /usr/bin/iptstate, /usr/bin/netscanner
EOF"
sudo chmod 0440 /etc/sudoers.d/00_$(USER)

# 5. BULK PACKAGE INSTALLATION
echo "Installing software from pkglist.txt..."
if [ "$IS_ASUS_G14" = true ]; then
    # Install all packages including ASUS-specific ones
    sudo pacman -S --needed --noconfirm - < ~/.dotfiles/pkglist.txt
else
    # Filter out ASUS-specific packages (linux-g14, asusctl, etc.)
    grep -v -E '^(linux-g14|asusctl)' ~/.dotfiles/pkglist.txt | \
        grep -v '^#' | grep -v '^$' | \
        sudo pacman -S --needed --noconfirm -
fi

# 6. VIRTUALIZATION & WINAPPS
echo "Configuring QEMU/KVM..."
sudo pacman -S --needed --noconfirm qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils \
    openbsd-netcat freerdp libvirt nvidia-container-toolkit dmidecode
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm "$USER"
[ ! -d "$HOME/.local/share/winapps" ] && git clone https://github.com/winapps-org/winapps.git ~/.local/share/winapps-src

# 7. DOTFILES DEPLOYMENT (CHEZMOI)
echo "Deploying configs with chezmoi..."
# Initialize using the configs directory as the root
chezmoi init --source ~/.dotfiles/configs
chezmoi apply --force


# Reloading Hyprland for configs
hyprctl reload

# 8. OMARCHY CLEANER (BLOAT REMOVAL)
echo "Cloning and running Omarchy Cleaner..."
CLEANER_DIR="$HOME/.local/share/omarchy-cleaner"
[ ! -d "$CLEANER_DIR" ] && git clone https://github.com/maxart/omarchy-cleaner "$CLEANER_DIR"
bash "$CLEANER_DIR/remove-bloat.sh"

if [ "$IS_ASUS_G14" = true ]; then
    echo ""
    echo "Setup Complete! Please reboot to load the g14 kernel."
else
    echo ""
    echo "Setup Complete! Please reboot to apply changes."
fi
