# Omarchy Setup (Universal with ASUS G14 Support)

This repository contains the configuration and automated deployment scripts for Arch Linux (Omarchy). It utilizes **chezmoi** for dotfile management and supports both generic hardware and ASUS Zephyrus G14 laptops with automatic hardware detection.

> 🖥️ **ASUS G14 Detected?** The installer automatically detects ASUS G14 hardware and installs the specialized G14 kernel and ASUS-specific packages.
> 🔧 **Other Hardware?** Works perfectly on any Arch Linux system - ASUS-specific components are skipped automatically.

> 🔄 **Installing Dual-Boot?** See the complete step-by-step guide: [DUALBOOT-GUIDE.md](DUALBOOT-GUIDE.md)

## 📂 Repository Structure

The `.dotfiles` directory is organized to support a clean `chezmoi` deployment:

- **install.sh**: The master automated installer.
- **pkglist.txt**: Native package manifest for `pacman`.
- **configs/**: The source of truth for `chezmoi`.
    - **dot_bashrc**: Managed `~/.bashrc`.
    - **dot_bash_profile**: Managed `~/.bash_profile`.
    - **dot_config/**: Configuration subdirectories.
        - **hypr/**: Hyprland (monitors, bindings, scratchpads).
        - **nvim/**: Neovim (LazyVim based).
        - **waybar/**: Status bar configuration.
        - **winapps/**: Windows app integration (WinApps).
    - **.chezmoiroot**: Instructs chezmoi to look inside the `configs` folder.

---

## 🛠️ Automated Installation

The `install.sh` script automates the following system-level configurations:

1.  **Hardware Detection**: Automatically detects if running on ASUS G14 hardware using `dmidecode`.
2.  **G14 Hardware Support** *(ASUS G14 only)*: Appends the specialized G14 repository to `pacman.conf` and installs the `linux-g14` kernel and `asusctl`.
3.  **Network Fixes**: Configures `systemd-resolved` and `systemd-networkd` to respect DHCP search domains and local resolution.
4.  **Sudoers Access**: Grants `NOPASSWD` status to specific TUI tools (`ufw`, `tufw`, `iptstate`, `netscanner`) for seamless terminal use.
5.  **Virtualization**: Sets up the QEMU/KVM stack and clones the `winapps` repository.
6.  **Dotfile Deployment**: Initializes `chezmoi` to point to `~/.dotfiles/configs` and applies the configuration.
7.  **System Cleanup**: Clones and executes the `omarchy-cleaner` to remove default bloatware.

---

## 📦 Software Manifest (pkglist.txt)

The system is built around a lean, TUI-centric software stack:

- **Drivers**: `vulkan-tools`, `nvidia-utils`, `egl-wayland`.
- **ASUS Drivers** *(G14 only)*: `linux-g14`, `linux-g14-headers`, `asusctl`.
- **TUI Utilities**: `iptstate`, `netscanner`, `lazyjournal`, `dive`, `ncdu`, `bluetui`.
- **Btrfs Management**: `btrfs-assistant`, `snapper`.
- **Dotfile Manager**: `chezmoi`.
- **Apps**: `firefox`, `steam`, `bitwarden`, `visual-studio-code-bin`.

> **Note**: ASUS-specific packages are automatically skipped on non-G14 hardware.

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

## 🖥️ System Features



| Feature | Description |
| :--- | :--- |
| **Dotfile Manager** | **chezmoi** - Replaced Stow for better template and secret management. |
| **Graphics** | OLED-optimized 2.8K resolution with XWayland zero-scaling to prevent blur. |
| **Brightness** | Keybinds mapped to `amdgpu_bl1` for precise OLED backlight control. |
| **Firewall** | UFW managed via CLI and monitored with `iptstate` TUI dashboard. |
| **Snapshots** | Automated Btrfs snapshots via `snapper`, managed by `btrfs-assistant`. |
| **WinApps** | Windows applications integrated directly into the Linux desktop via RDP/KVM. |

---

## ⌨️ Scratchpad Keybindings

Quick access to frequently used apps via special workspaces:

| Keybinding | App | Description |
| :--- | :--- | :--- |
| `Super + A` | Gemini | Toggle Gemini AI assistant |
| `Super + M` | Gmail | Toggle Gmail scratchpad |
| `Super + Alt + M` | Google Calendar | Toggle Calendar scratchpad |
| `Super + Alt + K` | Google Keep | Toggle Keep notes scratchpad |
| `Super + Shift + M` | Spotify | Toggle Spotify music player |

---

## 🚀 How to use
1. Rename your dotfiles folder: `mv ~/dotfiles ~/.dotfiles`.
2. Navigate to the directory: `cd ~/.dotfiles`.
3. Run the installer: `chmod +x install.sh && ./install.sh`.

The installer will automatically detect your hardware and install the appropriate packages. ASUS G14 users will get specialized kernel and ASUS-specific utilities, while other systems will get a universal configuration.
