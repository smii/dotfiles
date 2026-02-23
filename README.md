# Omarchy Dotfiles (Multi-System)

Personal Arch Linux (Omarchy) dotfiles with **automatic hardware profiling**. One repo, multiple machines — the installer detects hardware and applies the right kernel, drivers, monitor layout, idle behavior, and waybar modules.

> **Supported Systems:**
> - **ASUS ROG Zephyrus G14** — G14 kernel, hybrid GPU (AMD + NVIDIA), battery, touchpad, OLED brightness
> - **ROG Crosshair VIII Impact + RTX 3080** — Desktop, dual monitor (4K + QHD portrait), CoolerControl GPU fan management
> - **Generic** — Any Arch/Omarchy system with auto-detect monitors and sane defaults

> 🔄 **Installing Dual-Boot?** See the complete step-by-step guide: [DUALBOOT-GUIDE.md](DUALBOOT-GUIDE.md)

## 📂 Repository Structure

```
.dotfiles/
├── install.sh                    # Master installer (profile-aware)
├── pkglist.txt                   # Legacy package list (reference only)
├── configs/                      # Shared configs (symlinked to ~/.config/)
│   ├── hypr/                     # Hyprland (shared settings)
│   │   ├── hyprland.conf         # Main config (sources profile/)
│   │   ├── bindings.conf         # Key bindings (shared)
│   │   ├── envs.conf             # Wayland env vars (shared)
│   │   ├── input.conf            # Keyboard/touchpad (shared)
│   │   ├── looknfeel.conf        # Theme/layout (shared)
│   │   ├── windows.conf          # Window rules (shared)
│   │   ├── hyprlock.conf         # Lock screen (shared)
│   │   ├── hypridle.conf         # Stub → sources profile/
│   │   ├── hyprsunset.conf       # Night light (shared)
│   │   ├── xdph.conf             # Screen sharing (shared)
│   │   └── profile/ → ../../profiles/<name>/hypr/
│   ├── waybar/
│   │   ├── style.css             # Shared styling
│   │   └── config.jsonc → ../../profiles/<name>/waybar/config.jsonc
│   ├── nvim/                     # Neovim (LazyVim based)
│   └── winapps/                  # Windows app integration
├── profiles/                     # Per-system hardware profiles
│   ├── detect.sh                 # Auto-detect hardware → profile name
│   ├── packages-common.txt       # Packages installed on ALL systems
│   ├── g14/                      # ASUS ROG Zephyrus G14 laptop
│   │   ├── packages.txt          # linux-g14, asusctl, supergfxctl
│   │   ├── hypr/
│   │   │   ├── monitors.conf     # eDP-1 2880x1800@60 (OLED)
│   │   │   ├── hardware.conf     # Brightness keys (amdgpu_bl1)
│   │   │   ├── hypridle.conf     # Aggressive idle + suspend
│   │   │   └── autostart.conf    # G14 daemons
│   │   └── waybar/
│   │       └── config.jsonc      # With battery module
│   ├── desktop/                  # ROG Crosshair VIII Impact + RTX 3080
│   │   ├── packages.txt          # linux, nvidia-open-dkms, coolercontrol
│   │   ├── hypr/
│   │   │   ├── monitors.conf     # DP-1 4K + DP-2 QHD portrait
│   │   │   ├── hardware.conf     # NVIDIA env vars
│   │   │   ├── hypridle.conf     # Screen off only (no suspend)
│   │   │   └── autostart.conf    # CoolerControl
│   │   └── waybar/
│   │       └── config.jsonc      # GPU temp module, no battery
│   └── generic/                  # Any other system
│       ├── packages.txt          # linux, nvidia-dkms
│       ├── hypr/
│       │   ├── monitors.conf     # Auto-detect (preferred, auto, auto)
│       │   ├── hardware.conf     # Minimal
│       │   ├── hypridle.conf     # Screen off only
│       │   └── autostart.conf    # Empty
│       └── waybar/
│           └── config.jsonc      # With battery (safe fallback)
├── scripts/
│   ├── link.sh                   # Create symlinks (profile-aware)
│   ├── unlink.sh                 # Remove symlinks + profile links
│   └── migrate.sh                # Move existing configs into repo
└── shell/
    └── bash/.bashrc
```

---

## 🛠️ Automated Installation

The `install.sh` script auto-detects hardware and applies the correct profile:

1. **Profile Detection** — Reads DMI board/product name to identify `g14`, `desktop`, or `generic`.
2. **G14 Repository** *(G14 only)* — Adds the `arch.asus-linux.org` repo for G14 kernel packages.
3. **Package Installation** — Installs `packages-common.txt` + profile-specific `packages.txt`.
4. **Service Activation** — Enables hardware daemons (supergfxd, asusd, coolercontrold) per profile.
5. **Network Fixes** — Configures `systemd-resolved` for DHCP search domains.
6. **Sudoers** — Grants `NOPASSWD` for TUI tools (`ufw`, `tufw`, `iptstate`, `netscanner`).
7. **Virtualization** — Sets up QEMU/KVM + libvirt.
8. **Dotfile Deployment** — Runs `link.sh` to symlink configs and profile overlays.
9. **Cleanup** — Runs `omarchy-cleaner` to remove default bloatware.

### Profile Override

```bash
# Force a specific profile (skip auto-detection)
DOTFILES_PROFILE=desktop bash install.sh

# Just re-link configs with a different profile
DOTFILES_PROFILE=g14 bash scripts/link.sh
```

---

## 📦 Software Manifest

Packages are split into **common** (all systems) and **profile-specific**:

### Common (`profiles/packages-common.txt`)
- **Drivers**: `vulkan-tools`, `nvidia-utils`, `egl-wayland`
- **TUI Utilities**: `iptstate`, `netscanner`, `lazyjournal`, `dive`, `ncdu`, `bluetui`
- **Btrfs Management**: `btrfs-assistant`, `snapper`
- **Apps**: `firefox`, `steam`, `bitwarden`, `visual-studio-code-bin`

### G14 Profile (`profiles/g14/packages.txt`)
- `linux-g14`, `linux-g14-headers` — Custom ASUS kernel
- `asusctl`, `supergfxctl`, `rog-control-center` — ASUS hardware control
- `nvidia-dkms` — Proprietary NVIDIA driver

### Desktop Profile (`profiles/desktop/packages.txt`)
- `linux`, `linux-headers` — Standard kernel
- `nvidia-open-dkms`, `nvidia-settings` — Open NVIDIA kernel module
- `coolercontrol` — Fan/thermal control for NCT6798 sensor
  - GPU fans not directly connected; GPU temp managed via **GPU_MOBO_FAN** profile (NCT6798/FAN 1)
- `ckb-next` — Corsair keyboard/mouse

### Generic Profile (`profiles/generic/packages.txt`)
- `linux`, `linux-headers` — Standard kernel
- `nvidia-dkms` — Broadest NVIDIA compatibility

---

## 🖥️ TUI Utilities

> **Personal Selection**: These are my personally chosen terminal-based tools for system monitoring and management. Feel free to customize this list based on your preferences.

| Utility | Purpose | Access Method |
| :--- | :--- | :--- |
| **iptstate** | Real-time firewall connection monitor | Middle-click network icon in Waybar (launches `sudo tufw`) |
| **tufw** | Terminal UI for UFW firewall management | Middle-click network icon in Waybar |
| **netscanner** | Network scanning and device discovery | Terminal: `sudo netscanner` |
| **lazyjournal** | Interactive systemd journal viewer | Terminal: `lazyjournal` |
| **dive** | Docker image layer explorer | Terminal: `dive <image>` |
| **ncdu** | Disk usage analyzer with ncurses interface | Terminal: `ncdu` |
| **bluetui** | Bluetooth device manager | Terminal: `bluetui` |
| **btop** | System resource monitor | Click CPU icon in Waybar |
| **wiremix** | PipeWire/WirePlumber audio mixer | Click audio icon in Waybar |

> **Note**: Tools requiring elevated privileges (`tufw`, `iptstate`, `netscanner`) are configured in sudoers with `NOPASSWD` for seamless access.

---

## 🖥️ System Profiles

| Feature | G14 (Laptop) | Desktop (ROG Impact VIII) | Generic |
| :--- | :--- | :--- | :--- |
| **Kernel** | `linux-g14` | `linux` | `linux` |
| **GPU** | AMD iGPU + NVIDIA (hybrid) | RTX 3080 (dedicated) | NVIDIA (auto) |
| **ASUS Tools** | asusctl, supergfxctl | coolercontrol | — |
| **Monitors** | eDP-1 2880×1800 OLED | DP-1 4K + DP-2 QHD portrait | Auto-detect |
| **Brightness** | amdgpu_bl1 keys | N/A (external) | N/A |
| **Battery** | Waybar module | — | Waybar module |
| **Idle** | Screensaver → Lock → DPMS → Suspend | Screensaver → Lock → DPMS | Screensaver → Lock → DPMS |
| **GPU Temp** | — | Waybar module (nvidia-smi) | — |
| **NVIDIA Env** | — (hybrid via supergfxctl) | `LIBVA_DRIVER_NAME`, `GBM_BACKEND` | — |

---

## ⌨️ Scratchpad Keybindings

Quick access to frequently used apps via special workspaces:

| Keybinding | App | Description |
| :--- | :--- | :--- |
| `Super + A` | Gemini | Toggle Gemini AI assistant |
| `Super + M` | Gmail | Toggle Gmail |
| `Super + Alt + M` | Google Calendar | Toggle Calendar |
| `Super + S` | Spotify | Toggle Spotify music player |

---

## 🚀 How to use
1. Clone/rename your dotfiles folder: `mv ~/dotfiles ~/.dotfiles`
2. Navigate to the directory: `cd ~/.dotfiles`
3. Run the installer: `chmod +x install.sh && ./install.sh`

The installer auto-detects your hardware and applies the matching profile. To force a profile:
```bash
DOTFILES_PROFILE=desktop ./install.sh
```

### Adding a new system profile

1. Create `profiles/<name>/` with `packages.txt`, `hypr/`, and `waybar/` subdirectories
2. Add detection logic in `profiles/detect.sh`
3. Run `DOTFILES_PROFILE=<name> bash scripts/link.sh` to activate
