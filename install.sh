#!/usr/bin/env bash
# CachyOS / Arch dotfiles installer
# Idempotent — safe to re-run after pulling updates.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BIN="$HOME/.local/bin"

ok()   { echo "  ✓ $*"; }
info() { echo ""; echo "→ $*"; }
warn() { echo "  ! $*"; }

# ─── paru ────────────────────────────────────────────────────────────────────
info "paru"
if ! command -v paru &>/dev/null; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
fi
ok "paru $(paru --version | head -1)"

# ─── packages ─────────────────────────────────────────────────────────────────
pkg_list() { grep -v '^\s*#' "$1" | grep -v '^\s*$'; }

info "Base packages"
pkg_list "$DOTFILES/packages/base.txt" | paru -S --needed --noconfirm - 2>&1 | grep -E "^(installing|upgrading|error)" || true
ok "base.txt done"

info "AUR packages"
pkg_list "$DOTFILES/packages/aur.txt" | paru -S --needed --noconfirm - 2>&1 | grep -E "^(installing|upgrading|error)" || true
ok "aur.txt done"

if lsmod | grep -q '^nvidia' || command -v nvidia-smi &>/dev/null; then
    info "NVIDIA hardware detected"
    pkg_list "$DOTFILES/packages/hardware-nvidia.txt" | paru -S --needed --noconfirm - 2>&1 | grep -E "^(installing|upgrading|error)" || true
    ok "hardware-nvidia.txt done"
fi

# ─── configs (symlinks) ───────────────────────────────────────────────────────
info "Config symlinks"
mkdir -p "$CONFIG"
for src in "$DOTFILES/config"/*/; do
    name="$(basename "$src")"
    dst="$CONFIG/$name"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.bak.$(date +%s)"
        warn "backed up existing $dst"
    fi
    ln -sfn "$src" "$dst"
done
ok "~/.config/* linked"

# ─── machine.conf ─────────────────────────────────────────────────────────────
touch "$CONFIG/hypr/machine.conf"
ok "machine.conf present"

# ─── scripts → ~/.local/bin ───────────────────────────────────────────────────
info "Scripts"
mkdir -p "$BIN"
for s in "$DOTFILES/scripts"/*.sh; do
    install -Dm755 "$s" "$BIN/$(basename "$s" .sh)"
done
ok "scripts → $BIN"

# ─── systemd user services ────────────────────────────────────────────────────
info "Systemd user services"

elephant service enable
mkdir -p "$CONFIG/systemd/user"
cp "$DOTFILES/systemd/user/"*.service "$CONFIG/systemd/user/"
systemctl --user daemon-reload
for svc in waybar mako hypridle swayosd-server swaybg hyprpolkitagent gammastep elephant walker; do
    systemctl --user enable --now "$svc" 2>/dev/null && ok "$svc enabled" || warn "$svc not found (skip)"
done

# ─── opensnitchd (application firewall) ──────────────────────────────────────
info "OpenSnitch"
if command -v opensnitchd &>/dev/null; then
    sudo systemctl enable --now opensnitchd
    ok "opensnitchd active"
else
    warn "opensnitchd not installed (run: sudo pacman -S opensnitch)"
fi

# ─── Btrfs / snapper ──────────────────────────────────────────────────────────
info "Snapper (btrfs)"
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    if ! sudo snapper list-configs 2>/dev/null | grep -q '^root'; then
        sudo snapper -c root create-config /
        ok "snapper root config created"
    fi
    sudo snapper -c root set-config "NUMBER_CLEANUP=yes"
    sudo snapper -c root set-config "NUMBER_LIMIT=6"
    sudo snapper -c root set-config "NUMBER_LIMIT_IMPORTANT=3"
    sudo snapper -c root set-config "TIMELINE_CREATE=no"
    sudo snapper -c root set-config "TIMELINE_CLEANUP=yes"
    sudo snapper -c root set-config "TIMELINE_LIMIT_HOURLY=0"
    sudo snapper -c root set-config "TIMELINE_LIMIT_DAILY=0"
    sudo snapper -c root set-config "TIMELINE_LIMIT_MONTHLY=0"
    sudo snapper -c root set-config "TIMELINE_LIMIT_WEEKLY=0"
    sudo snapper -c root cleanup number 2>/dev/null || true
    ok "snapper: NUMBER_LIMIT=6 (3 pre/post pairs), timeline off"
else
    warn "/ is not btrfs — skipping snapper"
fi

# ─── UFW — suppress LLMNR multicast noise ─────────────────────────────────────
info "UFW"
if command -v ufw &>/dev/null; then
    B4=/etc/ufw/before.rules
    B6=/etc/ufw/before6.rules
    if ! sudo grep -q "LLMNR" "$B4" 2>/dev/null; then
        sudo sed -i '/^# allow dhcp client to work/i # suppress LLMNR noise from Windows hosts (silent drop, no log)\n-A ufw-before-input -p udp -d 224.0.0.252 --dport 5355 -j DROP\n' "$B4"
        sudo sed -i '/^COMMIT/i # suppress LLMNR noise (IPv6) from Windows hosts\n-A ufw6-before-input -p udp -d ff02::1:3 --dport 5355 -j DROP\n' "$B6"
        sudo ufw reload
        ok "LLMNR drop rules added + UFW reloaded"
    else
        ok "LLMNR rules already present"
    fi
else
    warn "ufw not found — skipping"
fi

# ─── Papirus folder colours ────────────────────────────────────────────────────
info "Papirus"
if command -v papirus-folders &>/dev/null; then
    papirus-folders -C bluegrey --theme Papirus-Dark 2>/dev/null || true
    ok "folder colour: bluegrey / Papirus-Dark"
else
    warn "papirus-folders not installed"
fi

# ─── Directories ──────────────────────────────────────────────────────────────
info "Directories"
mkdir -p ~/Pictures/Screenshots ~/Videos/Recordings ~/.local/share/applications
ok "~/Pictures/Screenshots  ~/Videos/Recordings  ~/.local/share/applications"

# ─── Chromium profiles ─────────────────────────────────────────────────────────
info "Chromium profiles"
if command -v chromium &>/dev/null; then
    for profile in private work; do
        dir="$HOME/.config/chromium/$profile"
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            # Minimal Preferences so Chromium recognises it as a valid profile
            cat > "$dir/Preferences" <<'JSON'
{"profile":{"name":""},"browser":{"has_seen_welcome_page":true}}
JSON
            ok "profile '$profile' initialised"
        else
            ok "profile '$profile' already exists"
        fi
    done
    warn "Open each profile once to finish setup:"
    warn "  chromium --profile-directory=private"
    warn "  chromium --profile-directory=work"
else
    warn "chromium not found — skipping profile init"
fi

echo ""
echo "Install complete. Reboot and select a Hyprland/UWSM session."
