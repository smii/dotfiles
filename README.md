# dotfiles

CachyOS + Hyprland desktop configuration. TokyoNight throughout. No runtime theme engines, no external dependencies at startup.

---

## Table of contents

- [Structure](#structure)
- [Setup](#setup)
- [Waybar](#waybar)
- [System Menu](#system-menu)
- [Keybindings](#keybindings)
- [Scripts](#scripts)
- [Configuration](#configuration)
- [Theming](#theming)

---

## Structure

```
dotfiles/
├── packages/
│   ├── base.txt              # Core Wayland + Hyprland + apps
│   ├── desktop.txt           # Gaming, display extras
│   └── hardware-nvidia.txt   # NVIDIA drivers + container toolkit
├── config/
│   ├── hypr/
│   │   ├── hyprland.conf     # Entry point — sources all modules
│   │   ├── machine.conf      # Machine-specific overrides (not committed)
│   │   ├── envs.conf         # Env vars: GTK theme, cursor, XDG, Qt
│   │   ├── monitors.conf     # Monitor layout + workspace assignments
│   │   ├── input.conf        # Keyboard / mouse / touchpad
│   │   ├── looknfeel.conf    # TokyoNight colours, animations, rounding
│   │   ├── windows.conf      # Window rules, opacity, float rules
│   │   ├── autostart.conf    # exec-once (UWSM env, fcitx5)
│   │   ├── bindings.conf     # All keybindings
│   │   ├── hypridle.conf     # Idle / auto-lock timeouts
│   │   ├── hyprlock.conf     # Lock screen appearance
│   │   └── apps/             # Per-app window rules
│   ├── waybar/
│   │   ├── config.jsonc      # Module layout + all module definitions
│   │   ├── style.css         # Standalone TokyoNight CSS
│   │   └── scripts/
│   │       ├── gpu-temp.sh           # NVIDIA GPU temperature (JSON)
│   │       ├── hyprmon.sh            # Active monitor profile (JSON)
│   │       ├── updates.sh            # Pending update count
│   │       ├── weather.sh            # wttr.in weather (JSON)
│   │       ├── screen-recording.sh   # Recording state (JSON)
│   │       ├── idle-indicator.sh     # Idle lock state (JSON)
│   │       ├── notification-silencing.sh  # DND state (JSON)
│   │       └── nightlight-indicator.sh    # Night light state (JSON)
│   ├── walker/
│   │   ├── config.toml               # Providers, prefix keys, theme
│   │   └── themes/tokyonight/        # Custom GTK4 theme for Walker
│   ├── mako/config           # Notification daemon
│   ├── ghostty/config        # Primary terminal
│   ├── alacritty/            # Fallback terminal
│   ├── nvim/                 # LazyVim config
│   ├── wlogout/              # Power menu layout + CSS
│   ├── gammastep/config.ini  # Night light
│   ├── btop/                 # System monitor theme
│   ├── tmux/                 # Tmux config
│   ├── lazygit/              # Lazygit config
│   ├── pcmanfm/              # File manager
│   ├── gtk-3.0/settings.ini
│   └── gtk-4.0/settings.ini
├── systemd/user/             # User services (graphical-session.target)
│   ├── waybar.service
│   ├── mako.service
│   ├── hypridle.service
│   ├── swayosd-server.service
│   ├── swaybg.service
│   ├── hyprpolkitagent.service
│   ├── gammastep.service
│   └── walker.service
└── scripts/                  # Installed to ~/.local/bin/
    ├── system-menu.sh
    ├── screenshot.sh
    ├── screenrecord-toggle.sh
    ├── idle-toggle.sh
    ├── nightlight-toggle.sh
    ├── notification-silencing-toggle.sh
    ├── audio-switch.sh
    ├── window-transparency-toggle.sh
    ├── window-gaps-toggle.sh
    ├── window-focus.sh
    ├── window-switcher.sh
    └── keybindings.sh
```

---

## Setup

### 1. Clone

```bash
git clone https://github.com/smii/dotfiles ~/Backup/dotfiles
cd ~/Backup/dotfiles
```

### 2. Symlink configs

```bash
for d in config/*/; do
  name=$(basename "$d")
  ln -sf ~/Backup/dotfiles/config/"$name" ~/.config/"$name"
done
```

### 3. Install scripts

```bash
for s in scripts/*.sh; do
  name=$(basename "$s" .sh)
  install -Dm755 "$s" ~/.local/bin/"$name"
done
```

### 4. Install systemd user services

```bash
cp systemd/user/*.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now waybar mako hypridle swayosd-server swaybg hyprpolkitagent gammastep
```

### 5. Machine-specific config

Create `~/.config/hypr/machine.conf` for per-machine overrides (monitors, GPU-specific settings). Can be empty:

```bash
touch ~/.config/hypr/machine.conf
```

### 6. Install packages

```bash
paru -S --needed - < packages/base.txt
# On NVIDIA machines only:
paru -S --needed - < packages/hardware-nvidia.txt
```

---

## Waybar

### Layout

**Left:** `󰣇` launcher (click = Walker, right-click = system menu) · hyprland/workspaces with embedded app taskbar

**Center:** clock · weather · mpris · update count · recording · idle · DND · night light

**Right (left→right):** tray · bluetooth · network · pulseaudio · hyprmon · memory · cpu temp · gpu temp · power profile · battery · cpu

### Workspace taskbar

`hyprland/workspaces` has `workspace-taskbar` enabled (Waybar 0.14+). Each workspace button shows its running app icons inline. Special workspaces (gemini, messages, gmail, calendar, scratchpad) are excluded automatically. Left-click an app icon to focus, middle-click to close.

### Right-side indicators

| Module | Icon | Notes |
|--------|------|-------|
| Bluetooth | 󰂯 / 󰂱 | off / connected |
| Network | 󰤯–󰤨 | signal strength icons |
| Pulseaudio | / | volume; right-click mutes |
| Hyprmon | 󰍹 | active monitor profile in tooltip; click opens hyprmon TUI |
| Memory | 󰘚 | RAM in tooltip; click opens btop |
| CPU temp | 󰔄 | coretemp; turns red ≥ 80 °C |
| GPU temp | — | nvidia-smi; only meaningful on NVIDIA machines |
| Power profile | 󰓅 / 󰾅 / 󰾆 | performance (red) / balanced (blue) / saver (green) |
| Battery | 󰂎–󰁹 / 󰂄 | capacity icons; yellow ≤ 30 %, red ≤ 15 %; green charging |
| CPU | 󰍛 | click opens btop |

### Center indicators

Toggle scripts signal waybar to update instantly rather than polling:

| Indicator | Signal |
|-----------|--------|
| Screen recording | SIGRTMIN+8 |
| Idle lock | SIGRTMIN+9 |
| Do-not-disturb | SIGRTMIN+10 |
| Night light | SIGRTMIN+11 |

---

## System Menu

Invoked with `Super+Alt+Space` (or right-click the `󰣇` launcher button). Multi-level Walker dmenu.

```
CachyOS
├── System      lock / suspend / reboot / shutdown / logout
├── Toggles     nightlight / idle / DND / top bar / gaps / transparency
├── Setup       audio / wi-fi / bluetooth / power profile / monitors (hyprmon)
├── Capture     screenshot / screenrecord / OCR / colour picker
├── Config      edit Hyprland / bindings / waybar / walker / ghostty configs
├── Install
│   ├── Package      interactive paru
│   ├── Browser      Chrome / Brave / Zen / Edge / Firefox
│   ├── Editor       VSCode / Cursor / Zed / Sublime / Vim / Emacs
│   ├── Terminal     Kitty / Warp
│   ├── Dev Env      Node / Python / Go / Ruby / Rust / Bun / Java / PHP / Elixir / Zig / .NET / Docker DBs (via mise / paru)
│   ├── Service      Tailscale / NordVPN / Dropbox
│   ├── AI           Ollama (auto-detects cuda/rocm/cpu) / LM Studio
│   ├── Gaming       Steam / Lutris / Heroic / Moonlight / RetroArch / ProtonGE
│   └── Remove       paru+fzf package removal / mise runtime removal
└── Network
    ├── Firewall     OpenSnitch GUI (opensnitchd daemon)
    └── Network Scan netscanner (polkit for raw socket access)
```

Sub-sections are also directly reachable via CLI: `system-menu install`, `system-menu network`, etc.

---

## Keybindings

> Press **Super+Ctrl+K** for a floating overview at any time.

### Launchers

| Binding | Action |
|---------|--------|
| `Super + Return` | Ghostty terminal |
| `Super + Alt + Return` | Ghostty + tmux |
| `Super + Shift + Return` | Chromium (personal profile) |
| `Super + Shift + F` | PCManFM |
| `Super + Shift + N` | Neovim |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + G` | Signal |
| `Super + Shift + D` | Lazydocker |
| `Super + Shift + T` | btop |
| `Super + Shift + /` | Bitwarden |
| `Super + Space` | Walker app launcher |
| `Super + Ctrl + E` | Walker emoji/symbols |
| `XF86Calculator` | Qalculate-GTK |

### System

| Binding | Action |
|---------|--------|
| `Super + Alt + Space` | System menu |
| `Super + Ctrl + L` | Lock screen |
| `Super + Escape` | Power menu (wlogout) |
| `XF86PowerOff` | Power menu |
| `Super + Ctrl + K` | Keybinding overview |

### Hardware keys

| Binding | Action |
|---------|--------|
| `XF86MonBrightnessUp/Down` | Screen brightness (swayosd) |
| `XF86AudioRaiseVolume/LowerVolume` | Volume up/down (swayosd) |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioMicMute` | Mic mute |
| `Alt + XF86AudioRaise/Lower` | Volume ±1 (fine control) |
| `XF86AudioNext/Prev/Play/Pause` | Media playback |
| `Super + XF86AudioMute` | Cycle audio output |

### Toggles

| Binding | Action |
|---------|--------|
| `Super + Ctrl + I` | Toggle idle lock |
| `Super + Ctrl + N` | Toggle night light |
| `Super + Shift + Space` | Toggle waybar |
| `Super + Backspace` | Toggle window transparency |
| `Super + Shift + Backspace` | Toggle window gaps |
| `Super + Print` | Colour picker |

### Notifications

| Binding | Action |
|---------|--------|
| `Super + ,` | Dismiss notification |
| `Super + Shift + ,` | Dismiss all |
| `Super + Ctrl + ,` | Toggle do-not-disturb |
| `Super + Alt + ,` | Invoke notification action |
| `Super + Shift + Alt + ,` | Restore last notification |

### Controls

| Binding | Action |
|---------|--------|
| `Super + Ctrl + A` | pavucontrol |
| `Super + Ctrl + B` | bluetui |
| `Alt + Ctrl + W` | nmtui |

### Screen capture

| Binding | Action |
|---------|--------|
| `Print` / `Super + Shift + S` | Screenshot region → save + clipboard |
| `Alt + Print` | Screen recording toggle |
| `Super + Ctrl + Print` | OCR → clipboard |

### Window management

| Binding | Action |
|---------|--------|
| `Super + W` | Close window |
| `Super + T` | Toggle float/tile |
| `Super + J` | Toggle split |
| `Super + P` | Pseudo tile |
| `Super + O` | Pop (float + pin) |
| `Super + G` | Toggle group |
| `Super + F11` | Full screen |
| `Super + Ctrl + F` | Tiled full screen |
| `Super + Alt + F` | Full width |
| `Super + Arrow` | Focus direction |
| `Super + Shift + Arrow` | Swap window |
| `Super + Ctrl + Z` / `Super + Ctrl + Alt + Z` | Zoom in / reset |

### Workspaces

| Binding | Action |
|---------|--------|
| `Super + 1–0` | Switch workspace |
| `Super + Shift + 1–0` | Move window to workspace |
| `Super + Tab / Shift+Tab` | Next / prev workspace |
| `Super + Ctrl + Tab` | Last used workspace |
| `Super + S` | Toggle scratchpad |
| `Super + A` | Toggle Gemini (auto-launches) |
| `Super + M` | Toggle Messages / Signal (auto-launches) |
| `Super + E` | Toggle Gmail (auto-launches) |
| `Super + Shift + E` | Toggle Calendar (auto-launches) |
| `Super + Shift + Alt + Arrow` | Move workspace to monitor |
| `Ctrl + Alt + Tab` | Focus next monitor |
| `Alt + Tab` | Window switcher (Walker) |

### Walker prefix keys

| Prefix | Provider |
|--------|----------|
| *(none)* | Desktop apps + web search |
| `.` | File browser |
| `:` | Symbols / emoji |
| `=` | Calculator |
| `@` | Web search |
| `$` | Clipboard history |
| `%` | Hyprland windows |
| `#` | SSH hosts |
| `!` | Shell runner |
| `/` | List all providers |

---

## Scripts

All live in `scripts/` and are deployed to `~/.local/bin/` (without `.sh` extension).

| Script | Description |
|--------|-------------|
| `system-menu` | Multi-level CachyOS settings / install menu (Super+Alt+Space) |
| `screenshot` | Region screenshot → save + clipboard + notification |
| `screenrecord-toggle` | gpu-screen-recorder on/off + signals waybar |
| `idle-toggle` | Kill/start hypridle + signals waybar indicator |
| `nightlight-toggle` | Toggle gammastep service + signals waybar indicator |
| `notification-silencing-toggle` | Mako DND mode + signals waybar indicator |
| `audio-switch` | Cycle audio output sinks via wpctl |
| `window-transparency-toggle` | Toggle focused window opacity |
| `window-gaps-toggle` | Toggle window gaps on/off |
| `window-focus` | Taskbar click handler: focus (LMB) or close (MMB) by window address |
| `window-switcher` | Walker window switcher (excludes special workspaces) |
| `keybindings` | Show bindings.conf in a floating Ghostty window |

---

## Configuration

### Hyprland modules

| File | Purpose |
|------|---------|
| `machine.conf` | Per-machine overrides (monitors, GPU flags) — not committed |
| `envs.conf` | GTK/Qt/cursor env vars, XDG dirs |
| `monitors.conf` | Display layout, workspace-to-monitor assignments |
| `input.conf` | Keyboard layout, touchpad, repeat rate |
| `looknfeel.conf` | Active border colour, rounding, bezier animations, blur |
| `windows.conf` | Opacity rules, float/center/size rules, workspace assignments |
| `autostart.conf` | UWSM env propagation, fcitx5 |
| `bindings.conf` | All keybindings |

### Special workspaces

Auto-launched on first open, toggled with Super shortcuts:

| Key | Workspace | App |
|-----|-----------|-----|
| `Super + S` | scratchpad | ghostty |
| `Super + A` | gemini | chromium --app=gemini.google.com |
| `Super + M` | messages | signal-desktop |
| `Super + E` | gmail | chromium --app=mail.google.com |
| `Super + Shift+E` | calendar | chromium --app=calendar.google.com |

### Network security

- **UFW** with LLMNR (UDP port 5355) silently dropped in `before.rules` — suppresses log spam from Windows hosts on the LAN.
- **OpenSnitch** (`opensnitchd.service`) running as application firewall. GUI: `opensnitch-ui`.
- **Netscanner** available for LAN scanning via system menu → Network → Network Scan.

### Mako (notifications)

TokyoNight colours, grouped by app+summary+body. Critical notifications persist with `layer=overlay`. Spotify notifications silenced. DND mode suppresses all except `notify-send`.

---

## Theming

**TokyoNight** inlined into every config — no runtime engine, no hot-reload dependency.

| Role | Hex |
|------|-----|
| Background | `#1a1b26` |
| Foreground | `#a9b1d6` |
| Accent blue | `#7aa2f7` |
| Purple | `#bb9af7` |
| Green | `#9ece6a` |
| Yellow | `#e0af68` |
| Red | `#f7768e` |

- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark
- **GTK:** Tokyonight-Dark (`tokyonight-gtk-theme-git` AUR)
- **Cursor:** Adwaita 24 px
