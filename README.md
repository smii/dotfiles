# dotfiles

CachyOS + Hyprland desktop. Fully self-contained — no runtime internet lookups, no omarchy dependency.

---

## Structure

```
dotfiles/
├── install.sh              # One-shot installer
├── packages/
│   ├── base.txt            # Core packages
│   └── desktop.txt         # GPU drivers, gaming, hardware-specific
├── config/                 # Symlinked to ~/.config/
│   ├── hypr/               # Hyprland (modular: envs, monitors, input, windows, bindings…)
│   ├── waybar/             # Bar + scripts + TokyoNight CSS
│   ├── walker/             # App launcher + tokyonight theme
│   ├── mako/               # Notifications
│   ├── ghostty/            # Primary terminal
│   ├── alacritty/          # Fallback terminal
│   ├── nvim/               # LazyVim
│   ├── wlogout/            # Power menu
│   └── …                   # btop, tmux, lazygit, git, gtk, gammastep, pcmanfm
├── systemd/user/           # 7 user services (waybar, mako, hypridle, …)
└── scripts/                # Installed to ~/.local/bin/
```

---

## Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

The installer installs `paru`, all packages, symlinks configs, copies scripts, enables systemd user services, and creates default directories.

---

## Post-install checklist

1. **Wallpaper** — place any image at `~/.config/hypr/wallpaper`
2. **Monitor names** — run `hyprctl monitors all` and edit `~/.config/hypr/monitors.conf` if needed
3. **Night light location** — edit `~/.config/gammastep/config.ini` (lat/lon or switch to `geoclue2`)
4. **GPU fan control** — open `http://localhost:11987` (coolercontrol), configure a fan curve linked to the GPU temperature sensor
5. **Papirus folders** — `papirus-folders -C blue --theme Papirus-Dark`
6. **Reboot** and select a Hyprland session via UWSM

---

## Keybindings

> **Super+Ctrl+K** opens the full keybinding list as a floating window.

### App launchers
| Binding | Action |
|---------|--------|
| `Super + Return` | Terminal (Ghostty) |
| `Super + Alt + Return` | Terminal + tmux |
| `Super + Shift + Return` | Chromium |
| `Super + Shift + F/N/O/G/D/T` | PCManFM / Neovim / Obsidian / Signal / Lazydocker / btop |
| `Super + Shift + /` | Bitwarden |
| `Super + Space` | Walker launcher |
| `Super + Ctrl + E` | Emoji/symbols picker |

### System & toggles
| Binding | Action |
|---------|--------|
| `Super + Alt + Space` | System menu |
| `Super + Ctrl + L` | Lock screen |
| `Super + Escape` | Power menu |
| `Super + Shift + Space` | Toggle waybar |
| `Super + Backspace` | Toggle transparency |
| `Super + Shift + Backspace` | Toggle window gaps |
| `Super + Ctrl + I / N` | Toggle idle lock / night light |
| `Super + Ctrl + ,` | Toggle do-not-disturb |
| `Super + Ctrl + A / B` | Audio (pavucontrol) / Bluetooth (bluetui) |

### Screen capture
| Binding | Action |
|---------|--------|
| `Print` / `Super + Shift + S` | Screenshot region |
| `Alt + Print` | Screen recording toggle |
| `Super + Ctrl + Print` | OCR → clipboard |
| `Super + Print` | Colour picker |

### Window management
| Binding | Action |
|---------|--------|
| `Super + W` | Close window |
| `Super + T` | Toggle float/tile |
| `Super + J` | Toggle split |
| `Super + F11 / Ctrl+F / Alt+F` | Fullscreen modes |
| `Super + Arrow` | Focus direction |
| `Super + Shift + Arrow` | Swap window |
| `Super + O` | Pop (float + pin) |
| `Super + G / Alt+G` | Toggle / leave group |

### Workspaces
| Binding | Action |
|---------|--------|
| `Super + 1–0` | Switch workspace |
| `Super + Shift + 1–0` | Move window to workspace |
| `Super + Tab / Shift+Tab` | Next / prev workspace |
| `Super + S` | Scratchpad toggle |
| `Super + A / M / E` | Special workspaces (Gemini / Messages / Gmail) |

### Walker prefixes
| Prefix | Provider |
|--------|----------|
| *(none)* | Apps + web search |
| `.` | Files | `:` | Symbols | `=` | Calculator |
| `@` | Web search | `$` | Clipboard | `%` | Windows |
| `#` | SSH hosts | `!` | Shell runner |

---

## Packages

### Core (`base.txt`)
`fish` `starship` `zoxide` `fzf` `ripgrep` `fd` `bat` `eza` `tmux` `btop` `fastfetch` `git` `wget` `curl`

### Wayland / Hyprland
`hyprland` `hyprlock` `hypridle` `hyprpicker` `hyprshot` `waybar` `mako` `walker` `swaybg` `swayosd` `wl-clipboard` `xdg-desktop-portal-hyprland`

### Audio
`pipewire` `pipewire-pulse` `wireplumber` `pamixer` `playerctl` `pavucontrol`

### Terminals & editors
`ghostty` `alacritty` `foot` `neovim` `helix`

### Development
`base-devel` `github-cli` `lazygit` `lazydocker` `docker` `docker-compose` `mise` `uv` `python` `go`

### Networking
`networkmanager` `bluetui` `bluez` `bluez-utils`

### Apps & media
`firefox` `chromium` `bitwarden` `obsidian` `signal-desktop` `qalculate-gtk` `mpv` `swayimg` `vlc` `pcmanfm`

### Fonts & theming
`ttf-jetbrains-mono-nerd` `noto-fonts` `noto-fonts-emoji` `papirus-icon-theme`

### AUR
`tokyonight-gtk-theme-git` `papirus-folders`

### Desktop / hardware (`desktop.txt`)
NVIDIA drivers, `coolercontrol`, gaming (Steam, MangoHud, GameMode), ROG tools

---

## Systemd user services

All target `graphical-session.target`, managed by UWSM.

| Service | Purpose |
|---------|---------|
| `waybar.service` | Status bar |
| `mako.service` | Notifications |
| `hypridle.service` | Idle / auto-lock |
| `swayosd-server.service` | Volume/brightness OSD |
| `swaybg.service` | Wallpaper |
| `hyprpolkitagent.service` | Polkit agent |
| `gammastep.service` | Night light |

---

## Scripts

All installed to `~/.local/bin/` by `install.sh`.

| Script | Binding | Description |
|--------|---------|-------------|
| `screenshot` | `Print` | Region screenshot → file + clipboard |
| `screenrecord-toggle` | `Alt+Print` | gpu-screen-recorder on/off |
| `idle-toggle` | `Super+Ctrl+I` | Toggle hypridle + waybar signal |
| `nightlight-toggle` | `Super+Ctrl+N` | Toggle gammastep + waybar signal |
| `notification-silencing-toggle` | `Super+Ctrl+,` | Mako do-not-disturb + waybar signal |
| `audio-switch` | `Super+XF86Mute` | Cycle audio output sinks |
| `window-transparency-toggle` | `Super+Backspace` | Toggle focused window opacity |
| `window-gaps-toggle` | `Super+Shift+Backspace` | Toggle window gaps |
| `keybindings` | `Super+Ctrl+K` | Show keybindings in floating window |
| `system-menu` | `Super+Alt+Space` | Multi-level settings menu (via Walker) |
| `window-focus` | *(taskbar)* | Focus or close window by address |

---

## Configuration

### Hyprland modules

| File | Purpose |
|------|---------|
| `hyprland.conf` | Entry point — sources all modules |
| `envs.conf` | Env vars: Wayland, GTK theme, cursor, Qt |
| `monitors.conf` | Monitor layout + workspace assignments |
| `input.conf` | Keyboard, mouse, touchpad |
| `looknfeel.conf` | TokyoNight colours, rounding, animations |
| `windows.conf` | Opacity, float rules, window tags |
| `bindings.conf` | All keybindings |
| `autostart.conf` | Minimal exec-once (UWSM handles daemons) |

### Waybar

**Left:** launcher, workspaces + taskbar (app icons per workspace, special workspaces excluded)  
**Center:** clock, weather, MPRIS, update count, recording / idle / DnD / night-light indicators  
**Right:** tray, bluetooth, network, battery, audio, power profile, monitor profile, RAM, CPU temp, GPU temp, CPU

Indicator signals: recording=`SIGRTMIN+8`, idle=`SIGRTMIN+9`, DnD=`SIGRTMIN+10`, nightlight=`SIGRTMIN+11`

### System menu (`Super+Alt+Space`)

| Section | Items |
|---------|-------|
| System | Lock, Suspend, Reboot, Shutdown, Logout |
| Toggles | Night light, Idle lock, Notifications, Bar, Gaps, Transparency |
| Setup | Audio, Wi-Fi, Bluetooth, Power profile, Monitors (hyprmon), Fan control |
| Capture | Screenshot, Screen record, OCR, Colour picker |
| Config | Edit Hyprland, Bindings, Hypridle, Waybar, Walker, Gammastep, Ghostty |
| Network | Firewall (OpenSnitch), Network scan (netscanner) |
| Install | Package, Browser, Editor, Terminal, Dev env, Service, AI, Gaming, Remove |

---

## Theming

**TokyoNight** inlined into every config — no runtime theme engine.

| Role | Hex |
|------|-----|
| Background | `#1a1b26` |
| Foreground | `#a9b1d6` |
| Accent (blue) | `#7aa2f7` |
| Purple | `#bb9af7` |
| Green | `#9ece6a` |
| Yellow | `#e0af68` |
| Red | `#f7768e` |

**Font:** JetBrainsMono Nerd Font · **Icons:** Papirus-Dark · **GTK:** Tokyonight-Dark · **Cursor:** Adwaita 24px

---

## GPU fan control

`coolercontrol` runs as a system service and provides a web UI at `http://localhost:11987`.

1. Open the UI → **Devices** → select your motherboard sensor chip
2. Find the fan header connected to the GPU fan
3. Create a profile with a custom curve, temperature source = GPU
4. Apply the profile to that fan header
