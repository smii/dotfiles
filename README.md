# dotfiles

CachyOS + Hyprland desktop for **ROG Crosshair VIII Impact + RTX 3080**.
Fully self-contained — zero omarchy dependency, zero internet lookups at runtime.

---

## Table of contents

- [Hardware](#hardware)
- [Structure](#structure)
- [Install](#install)
- [Post-install checklist](#post-install-checklist)
- [Keybindings](#keybindings)
- [Packages](#packages)
- [Systemd user services](#systemd-user-services)
- [Scripts](#scripts)
- [Configuration](#configuration)
- [Theming](#theming)
- [GPU fan control](#gpu-fan-control)
- [What changed from omarchy](#what-changed-from-omarchy)

---

## Hardware

| Component | Detail |
|-----------|--------|
| Board | ASUS ROG Crosshair VIII Impact (X570) |
| CPU | AMD Ryzen (X570 platform) |
| GPU | NVIDIA RTX 3080 |
| Fan chip | NCT6798 (motherboard sensor, routes GPU fan via FAN 1 header) |
| Monitors | Dual landscape, DP-1 + DP-2 (preferred/auto-right, scale 1) |
| Session | Hyprland via UWSM (Universal Wayland Session Manager) |

---

## Structure

```
dotfiles/
├── install.sh              # One-shot installer (paru, packages, symlinks, services)
├── packages/
│   ├── base.txt            # Core + Wayland + apps (Arch/CachyOS repos)
│   └── desktop.txt         # NVIDIA drivers, coolercontrol, ROG, gaming
├── config/
│   ├── hypr/               # Hyprland — modular config
│   │   ├── hyprland.conf   # Entry point — sources all modules
│   │   ├── envs.conf       # Env vars: NVIDIA Wayland, GTK theme, cursor
│   │   ├── monitors.conf   # Dual landscape layout + workspace assignments
│   │   ├── input.conf      # Keyboard / mouse / touchpad
│   │   ├── looknfeel.conf  # TokyoNight colours, animations, layout
│   │   ├── windows.conf    # Window rules, opacity, floating
│   │   ├── autostart.conf  # Minimal exec-once (UWSM handles daemons)
│   │   ├── bindings.conf   # All keybindings
│   │   └── apps/           # Per-app window rules (apps.conf sources these)
│   ├── waybar/
│   │   ├── config.jsonc    # Modules: workspaces, clock, GPU temp, tray
│   │   ├── style.css       # Standalone TokyoNight CSS
│   │   └── scripts/        # gpu-temp, weather, update-count, indicators
│   ├── walker/             # App launcher
│   │   ├── config.toml     # Providers, prefix keys, theme
│   │   └── themes/tokyonight/style.css
│   ├── mako/config         # Notification daemon — TokyoNight colours
│   ├── ghostty/config      # Primary terminal — full TokyoNight palette
│   ├── alacritty/alacritty.toml  # Fallback terminal — full TokyoNight palette
│   ├── nvim/               # LazyVim setup
│   ├── wlogout/            # Power menu
│   │   ├── layout          # 6 buttons: lock, hibernate, logout, shutdown, suspend, reboot
│   │   └── style.css       # TokyoNight, CachyOS-style 3×2 grid layout
│   ├── gammastep/config.ini  # Night light (replaces wlsunset)
│   ├── pcmanfm/pcmanfm.conf  # File manager — list view, ghostty terminal
│   ├── libfm/libfm.conf    # PCManFM backend — ghostty, trash enabled
│   ├── gtk-3.0/settings.ini  # GTK3 theme: Tokyonight-Dark + Papirus-Dark
│   ├── gtk-4.0/settings.ini  # GTK4 theme: prefer-dark + Papirus-Dark
│   ├── btop/
│   ├── fastfetch/
│   ├── tmux/
│   ├── lazygit/
│   └── git/
├── systemd/user/           # User services (all WantedBy=graphical-session.target)
│   ├── waybar.service
│   ├── mako.service
│   ├── hypridle.service
│   ├── swayosd-server.service
│   ├── swaybg.service
│   ├── hyprpolkitagent.service
│   └── gammastep.service
└── scripts/                # Installed to ~/.local/bin/ by install.sh
    ├── screenshot.sh
    ├── screenrecord-toggle.sh
    ├── idle-toggle.sh
    ├── nightlight-toggle.sh
    ├── notification-silencing-toggle.sh
    ├── audio-switch.sh
    ├── window-transparency-toggle.sh
    ├── window-gaps-toggle.sh
    └── keybindings.sh
```

---

## Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The installer:
1. Installs `paru` (AUR helper) if not present
2. Installs all packages from `packages/base.txt` and `packages/desktop.txt`
3. Installs AUR packages: `tokyonight-gtk-theme-git`, `papirus-folders`
4. Symlinks `config/*` → `~/.config/` (backs up existing dirs as `*.bak`)
5. Copies `scripts/*.sh` → `~/.local/bin/` with `+x`
6. Installs and enables 7 systemd user services
7. Enables `coolercontrold.service` (system) for GPU fan control
8. Writes `/etc/modprobe.d/nvidia-drm.conf` (DRM modeset for Wayland)
9. Creates `~/Pictures/Screenshots` and `~/Videos/Recordings`
10. Configures git if not already set

---

## Post-install checklist

1. **Wallpaper** — place any image at `~/.config/hypr/wallpaper`
   swaybg uses this path; PNG, JPG, and most formats work.

2. **Monitor names** — verify connector names match your system:
   ```bash
   hyprctl monitors all
   ```
   Edit `~/.config/hypr/monitors.conf` if your outputs are not `DP-1` / `DP-2`.

3. **Night light location** — edit `~/.config/gammastep/config.ini`:
   ```ini
   [manual]
   lat=52.4   # your latitude
   lon=4.9    # your longitude
   ```
   Or switch to `location-provider=geoclue2` for automatic detection.

4. **GPU fan control** — open coolercontrol at `http://localhost:11987` and:
   - Select the **NCT6798** device (your motherboard sensor chip)
   - Apply a custom fan profile to **FAN 1** (this is the GPU fan header on the ROG Crosshair VIII)
   - Link the temperature source to the **GPU sensor** (nvidia)
   See [GPU fan control](#gpu-fan-control) for details.

5. **Papirus folder colours**:
   ```bash
   papirus-folders -C blue --theme Papirus-Dark
   ```

6. **Reboot** and select a Hyprland session (via UWSM).

---

## Keybindings

> Press **Super+Ctrl+K** to open this list as a floating window at any time.

### App launchers

Pattern matches omarchy: `Super+Shift+{letter}` for apps, `Super+Return` for terminal.

| Binding | Action |
|---------|--------|
| `Super + Return` | Ghostty terminal |
| `Super + Alt + Return` | Ghostty with tmux |
| `Super + Shift + Return` | Chromium (personal profile) |
| `Super + Shift + F` | PCManFM file manager |
| `Super + Shift + N` | Neovim (in Ghostty) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + G` | Signal |
| `Super + Shift + D` | Lazydocker (in Ghostty) |
| `Super + Shift + T` | btop activity monitor (in Ghostty) |
| `Super + Shift + /` | Bitwarden |
| `Super + Space` | Walker app launcher |
| `Super + Ctrl + E` | Walker emoji/symbols picker |
| `XF86Calculator` | Qalculate-GTK |

### System

| Binding | Action |
|---------|--------|
| `Super + Ctrl + L` | Lock screen (hyprlock) |
| `Super + Escape` | Power menu (wlogout) |
| `XF86PowerOff` | Power menu (wlogout) |
| `Super + Ctrl + K` | Keybinding overview (this list) |

### Aesthetics & toggles

| Binding | Action |
|---------|--------|
| `Super + Shift + Space` | Toggle waybar |
| `Super + Backspace` | Toggle window transparency |
| `Super + Shift + Backspace` | Toggle window gaps |
| `Super + Print` | Colour picker (hyprpicker) |
| `Super + Ctrl + I` | Toggle idle lock (hypridle) |
| `Super + Ctrl + N` | Toggle night light (gammastep) |

### Notifications

| Binding | Action |
|---------|--------|
| `Super + ,` | Dismiss notification |
| `Super + Shift + ,` | Dismiss all notifications |
| `Super + Ctrl + ,` | Toggle do-not-disturb |
| `Super + Alt + ,` | Invoke notification action |
| `Super + Shift + Alt + ,` | Restore last notification |

### Screen capture

| Binding | Action |
|---------|--------|
| `Print` | Screenshot region → save + copy |
| `Alt + Print` | Screen recording toggle |
| `Super + Ctrl + Print` | OCR — extract text from region → clipboard |

### Controls

| Binding | Action |
|---------|--------|
| `Super + Ctrl + A` | PulseAudio (pavucontrol) |
| `Super + Ctrl + B` | Bluetooth (bluetui in Ghostty) |
| `Alt + Ctrl + W` | Wi-Fi (nmtui in Ghostty) |

### Zoom

| Binding | Action |
|---------|--------|
| `Super + Ctrl + Z` | Zoom in (+1) |
| `Super + Ctrl + Alt + Z` | Reset zoom |

### Window management

| Binding | Action |
|---------|--------|
| `Super + W` | Close window |
| `Ctrl + Alt + Delete` | Close all windows |
| `Super + J` | Toggle split direction |
| `Super + P` | Pseudo tile |
| `Super + T` | Toggle float/tile |
| `Super + F11` | Full screen |
| `Super + Ctrl + F` | Tiled full screen |
| `Super + Alt + F` | Full width |
| `Super + G` | Toggle window group |
| `Super + Alt + G` | Move out of group |
| `Super + O` | Pop window (float + pin) |
| `Super + Arrow` | Focus direction |
| `Super + Shift + Arrow` | Swap window direction |
| `Super + -` / `Super + =` | Resize horizontal |
| `Super + Shift + -` / `Super + Shift + =` | Resize vertical |

### Workspaces

| Binding | Action |
|---------|--------|
| `Super + 1-0` | Switch to workspace 1–10 |
| `Super + Shift + 1-0` | Move window to workspace 1–10 |
| `Super + Shift + Alt + 1-5` | Move window silently to workspace 1–5 |
| `Super + Tab` | Next workspace |
| `Super + Shift + Tab` | Prev workspace |
| `Super + Ctrl + Tab` | Last used workspace |
| `Super + S` | Toggle scratchpad |
| `Super + Alt + S` | Move window to scratchpad |
| `Super + M` | Messages scratchpad (Signal — auto-launches) |

### Multi-monitor

| Binding | Action |
|---------|--------|
| `Super + Shift + Alt + Arrow` | Move current workspace to adjacent monitor |
| `Ctrl + Alt + Tab` | Focus next monitor |
| `Ctrl + Alt + Shift + Tab` | Focus prev monitor |

### Groups

| Binding | Action |
|---------|--------|
| `Super + Alt + Arrow` | Move window into group (direction) |
| `Super + Alt + Tab` | Next window in group |
| `Super + Alt + Shift + Tab` | Prev window in group |

### Window switching

| Binding | Action |
|---------|--------|
| `Alt + Tab` | Walker window switcher (hyprland provider) |

### Mouse

| Binding | Action |
|---------|--------|
| `Super + LMB drag` | Move window |
| `Super + RMB drag` | Resize window |
| `Super + Scroll` | Switch workspace |

### Media keys

| Binding | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume up (swayosd) |
| `XF86AudioLowerVolume` | Volume down (swayosd) |
| `XF86AudioMute` | Mute toggle (swayosd) |
| `XF86AudioMicMute` | Mute microphone |
| `Alt + XF86AudioRaise/Lower` | Volume ±1 (fine control) |
| `XF86AudioNext/Prev/Play/Pause` | Media playback (swayosd → playerctl) |
| `Super + XF86AudioMute` | Cycle audio output device |

### Walker prefix keys (inside Walker)

| Prefix | Provider |
|--------|----------|
| *(none)* | Desktop apps, Hyprland windows, web search |
| `/` | List all providers |
| `.` | File browser |
| `:` | Symbols / emoji |
| `=` | Calculator |
| `@` | Web search |
| `$` | Clipboard |
| `%` | Hyprland window switcher |
| `#` | SSH hosts |
| `!` | Shell runner |

---

## Packages

### Shell & core (`base.txt`)

`fish` `bash-completion` `starship` `zoxide` `fzf` `ripgrep` `fd` `bat` `eza` `gum` `wget` `curl` `git` `tmux` `btop` `fastfetch` `neofetch`

### Wayland / Hyprland

`hyprland` `hyprlock` `hypridle` `hyprpicker` `hyprshot` `waybar` `mako` `walker` `swaybg` `swayosd` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` `xdg-user-dirs` `wl-clipboard` `wlroots` `qt5-wayland` `qt6-wayland` `qt5ct` `qt6ct` `kvantum` `kvantum-qt5` `nwg-look`

### Audio

`pipewire` `pipewire-alsa` `pipewire-pulse` `pipewire-jack` `wireplumber` `pamixer` `playerctl` `pavucontrol` `wiremix`

### Display & notifications

`gammastep` `brightnessctl` `libnotify` `geoclue`

### Fonts

`ttf-jetbrains-mono-nerd` `noto-fonts` `noto-fonts-emoji` `ttf-font-awesome`

### Terminals

`ghostty` (primary) `alacritty` (fallback) `foot`

### File management

`pcmanfm` `gvfs` `gvfs-smb` `tumbler` `file-roller` `p7zip` `unzip` `zip`

### Editors

`neovim` `helix`

### Development

`base-devel` `git` `github-cli` `lazygit` `lazydocker` `docker` `docker-compose` `docker-buildx` `python` `python-pip` `go` `mise` `uv`

### Networking

`networkmanager` `network-manager-applet` `bluetui` `bluez` `bluez-utils`

### System tools

`hyprpolkitagent` `power-profiles-daemon` `uwsm` `fcitx5` `fcitx5-gtk` `fcitx5-qt` `fcitx5-configtool` `btrfs-assistant` `snapper` `ncdu` `htop` `inxi` `iptables` `nftables`

### Screen capture

`gpu-screen-recorder` `grim` `slurp` `satty`

### Media

`mpv` `swayimg` `vlc`

### Browser & apps

`firefox` `chromium` `bitwarden` `obsidian` `signal-desktop` `qalculate-gtk`

### XDG & GTK

`xdg-utils` `gtk3` `gtk4` `libadwaita` `wlogout` `papirus-icon-theme`

### Miscellaneous

`jq` `yq` `man-db` `man-pages`

### AUR packages (installed separately)

| Package | Purpose |
|---------|---------|
| `tokyonight-gtk-theme-git` | GTK3/4 theme for blueman, pcmanfm, nm-applet, etc. |
| `papirus-folders` | Coloured folder icons for Papirus-Dark |

### Desktop / hardware (`desktop.txt`)

| Category | Packages |
|----------|---------|
| NVIDIA drivers | `nvidia-open-dkms` `nvidia-settings` `nvidia-utils` `lib32-nvidia-utils` `egl-wayland` `libva-nvidia-driver` `nvidia-container-toolkit` |
| GPU fan control | `coolercontrol` |
| ROG hardware | `ckb-next` |
| Gaming | `steam` `lib32-mesa` `lib32-vulkan-icd-loader` `vulkan-tools` `mangohud` `gamemode` |
| Display | `mesa` `vulkan-icd-loader` `vulkan-radeon` |

---

## Systemd user services

All services target `graphical-session.target` and are managed by UWSM.
They are installed to `~/.config/systemd/user/` and enabled by `install.sh`.

| Service | Binary | Notes |
|---------|--------|-------|
| `waybar.service` | `waybar` | Status bar |
| `mako.service` | `mako` | Notification daemon (Type=dbus) |
| `hypridle.service` | `hypridle` | Idle / auto-lock |
| `swayosd-server.service` | `swayosd-server` | OSD for volume/media keys |
| `swaybg.service` | `swaybg` | Wallpaper from `~/.config/hypr/wallpaper` |
| `hyprpolkitagent.service` | `/usr/lib/hyprpolkitagent` | Polkit agent (Hyprland-native) |
| `gammastep.service` | `gammastep-indicator` | Night light with system tray |

`autostart.conf` contains only 3 `exec-once` lines — env propagation for UWSM and `fcitx5`. All daemons are handled by the services above.

---

## Scripts

All scripts live in `scripts/` and are installed to `~/.local/bin/` by `install.sh`.

| Script | Binding | Description |
|--------|---------|-------------|
| `screenshot` | `Print` | Hyprshot region → `~/Pictures/Screenshots/` + clipboard + mako notify |
| `screenrecord-toggle` | `Alt+Print` | gpu-screen-recorder on/off → `~/Videos/Recordings/` + signals waybar |
| `idle-toggle` | `Super+Ctrl+I` | Kill/start hypridle + waybar indicator (SIGRTMIN+9) |
| `nightlight-toggle` | `Super+Ctrl+N` | Stop/start gammastep.service + waybar indicator (SIGRTMIN+11) |
| `notification-silencing-toggle` | `Super+Ctrl+,` | Mako do-not-disturb mode + waybar indicator (SIGRTMIN+10) |
| `audio-switch` | `Super+XF86AudioMute` | Cycle wpctl audio output sinks |
| `window-transparency-toggle` | `Super+Backspace` | `hyprctl setprop alpha` on focused window |
| `window-gaps-toggle` | `Super+Shift+Backspace` | Toggle `general:gaps_in/out` between 0 and defaults |
| `keybindings` | `Super+Ctrl+K` | Open bindings.conf in a floating Ghostty window via bat |

---

## Configuration

### Hyprland modules

| File | Purpose |
|------|---------|
| `hyprland.conf` | Sources all other modules in order |
| `envs.conf` | NVIDIA Wayland vars, `GTK_THEME=Tokyonight-Dark`, cursor, XDG, Qt |
| `monitors.conf` | `DP-1` primary (workspaces 1–5), `DP-2` right (workspaces 6–10) |
| `input.conf` | `kb_layout = us`, numlock on, repeat 40ms/250ms, clickfinger touchpad |
| `looknfeel.conf` | `col.active_border #7aa2f7`, rounding 8, Bezier animations |
| `windows.conf` | Opacity 0.97/0.9 default, float rules, suppress maximize |
| `autostart.conf` | UWSM env import, dbus activation, fcitx5 |
| `bindings.conf` | All keybindings (see Keybindings section) |

### Walker

Walker replaces wofi and the omarchy powermenu. Configured providers:

- Default: `desktopapplications`, `hyprland` (window switcher), `websearch`
- Prefix `/` → list providers; `.` files; `:` symbols; `=` calc; `@` websearch; `$` clipboard; `%` hyprland; `#` ssh; `!` runner
- Theme: `tokyonight` (standalone CSS in `config/walker/themes/tokyonight/style.css`)

### Waybar modules

**Left:** walker launcher button, hyprland workspaces

**Center:** clock, weather, update count, screen-recording indicator, idle indicator, notification-silencing indicator, night-light indicator

**Right:** tray expander, bluetooth, network, pulseaudio, GPU temp (`nvidia-smi`), CPU

Indicator signals: recording=SIGRTMIN+8, idle=SIGRTMIN+9, notifications=SIGRTMIN+10, nightlight=SIGRTMIN+11

### wlogout (power menu)

Invoked with `wlogout -b 3 -T 240 -B 240 -L 350 -R 350` for a centred 3×2 grid.

Buttons: Lock (`l`), Hibernate (`h`), Logout (`e`), Shutdown (`s`), Suspend (`u`), Reboot (`r`)

Icons served from `/usr/share/wlogout/icons/` (installed with the `wlogout` package).

### GTK theming

`GTK_THEME=Tokyonight-Dark` is exported in `envs.conf`.
`config/gtk-3.0/settings.ini` sets `Tokyonight-Dark` + `Papirus-Dark` for all GTK3 apps (blueman-manager, pcmanfm, nm-applet, pavucontrol, etc.).
`config/gtk-4.0/settings.ini` enables dark mode + Papirus-Dark.

---

## Theming

All configs use the **TokyoNight** colour scheme, inlined (no runtime theme engine).

| Role | Hex |
|------|-----|
| Background | `#1a1b26` |
| Surface | `#24283b` |
| Foreground | `#a9b1d6` |
| Foreground bright | `#c0caf5` |
| Accent (blue) | `#7aa2f7` |
| Green | `#9ece6a` |
| Yellow / amber | `#e0af68` |
| Red | `#f7768e` |
| Cyan | `#7dcfff` |
| Purple | `#bb9af7` |

Fonts: **JetBrainsMono Nerd Font** everywhere. Icons: **Papirus-Dark**.
GTK theme: **Tokyonight-Dark** (AUR `tokyonight-gtk-theme-git`).
Cursor: **Adwaita**, size 24.

---

## GPU fan control

The RTX 3080's extra fan header on the ROG Crosshair VIII Impact routes through the motherboard's **NCT6798** sensor chip (FAN 1 header), not the GPU itself. Standard GPU fan control tools that talk to the card directly won't reach this fan.

**coolercontrol** (installed as a system service by `install.sh`) provides a web UI at `http://localhost:11987`.

Setup steps:
1. Open `http://localhost:11987`
2. Go to **Devices** → select **NCT6798**
3. Under the NCT6798, find **Fan 1** (the GPU fan header)
4. Create a new **Profile**: custom curve, temperature source = **NVIDIA GPU 0** (or whichever the RTX 3080 shows as)
5. Apply the profile to Fan 1
6. The GPU fan will now follow the custom curve at all times, independent of Hyprland/Wayland session state

---

## What changed from omarchy

| Was (omarchy) | Now |
|---------------|-----|
| All `omarchy-*` commands | Direct tools or `~/.local/bin/` scripts |
| `$OMARCHY_PATH` references | Removed — all configs are standalone |
| Elephant / Walker powermenu provider | Walker uses built-in providers only |
| Elephant as "file manager" | Elephant is Walker's data backend; **pcmanfm** is the file manager |
| wofi | Removed — Walker only |
| omarchy theme engine + hot-reload | Static **TokyoNight** inlined into each config |
| omarchy waybar CSS import | Standalone CSS in `config/waybar/style.css` |
| `omarchy-theme-hotreload.lua` (nvim) | Removed |
| omarchy systemd service definitions | Native services in `systemd/user/` |
| polkit-gnome | **hyprpolkitagent** (`/usr/lib/hyprpolkitagent`) |
| wlsunset (basic night light) | **gammastep** (geoclue2 support, tray indicator, smooth fade) |
| imv (image viewer) | **swayimg** (pure Wayland, no XWayland) |
| No GPU fan control | **coolercontrol** via NCT6798 / FAN 1 |
| No pcmanfm config | Full `config/pcmanfm/` + `config/libfm/` with ghostty terminal |
| No wlogout | **wlogout** power menu with TokyoNight CSS, 3×2 grid layout |
