# Dotfiles

Personal dotfiles based on [Omadora](https://github.com/omadora/omadora) - a modern Fedora-based Hyprland environment.

## Contents

This repository contains configuration files for:

- **hypr/** - Hyprland compositor configuration
  - Window rules, keybindings, monitors, animations
  - Custom scripts for application launching
  - Hypridle, hyprlock, and hyprsunset configs
  
- **omadora/** - Omadora-specific configurations
  - Branding and theme files
  - Theme collections (Catppuccin, Gruvbox, Tokyo Night, Rose Pine, etc.)
  
- **waybar/** - Status bar configuration
  - Custom styling and modules
  
- **wofi/** - Application launcher configuration
  - Custom themes and styling

## Installation

### Prerequisites

- [Omadora](https://github.com/omadora/omadora) installed (Fedora-based Hyprland distribution)
- Git

### Quick Install

Clone this repository and run the installer:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The installer will:
- Backup existing configurations (if any)
- Create symlinks from this repository to `~/.config`
- Preserve your ability to track changes via git

### Manual Installation

If you prefer to install manually:

```bash
# Backup existing configs
mkdir -p ~/.config/backup
mv ~/.config/hypr ~/.config/backup/ 2>/dev/null
mv ~/.config/waybar ~/.config/backup/ 2>/dev/null
mv ~/.config/wofi ~/.config/backup/ 2>/dev/null

# Create symlinks
ln -sf ~/dotfiles/hypr ~/.config/hypr
ln -sf ~/dotfiles/omadora ~/.config/omadora
ln -sf ~/dotfiles/waybar ~/.config/waybar
ln -sf ~/dotfiles/wofi ~/.config/wofi
```

## Customization

### Themes

Multiple themes are available in `omadora/themes/`. To switch themes:

1. Update the symlink in `omadora/current/theme`
2. Reload Hyprland with `Super + Shift + R` or re-login

Available themes:
- catppuccin / catppuccin-latte
- everforest
- flexoki-light
- gruvbox
- kanagawa
- matte-black
- nord
- osaka-jade
- ristretto
- rose-pine / rose-pine-darker
- tokyo-night

### Keybindings

Main keybindings are defined in `hypr/bindings.conf`. Default mod key is `Super` (Windows key).

### Monitors

Configure your monitor setup in `hypr/monitors.conf`.

## Changes from Original Omadora

### Custom Scratchpad Workspaces

This configuration adds several special workspaces (scratchpads) for quick access to web applications:

#### Gemini AI Assistant
- **Keybinding:** `Super + A`
- **Workspace:** `special:gemini`
- **Application:** Opens Gemini AI in Chrome app mode
- **Script:** Uses `launch_app.sh` to prevent duplicates

#### Gmail
- **Keybinding:** `Super + M`
- **Workspace:** `special:mail`
- **Application:** Gmail in Chrome app mode
- **Script:** Uses `launch_app.sh` to prevent duplicates

#### Google Calendar
- **Keybinding:** `Super + Shift + C`
- **Workspace:** `special:calendar`
- **Application:** Google Calendar in Chrome app mode
- **Features:** 95% opacity, idle inhibit on focus
- **Script:** Uses `launch_app.sh` to prevent duplicates

#### Google Keep (Notes)
- **Keybinding:** `Super + N`
- **Workspace:** `special:notes`
- **Application:** Google Keep in Chrome app mode
- **Features:** 95% opacity, idle inhibit on focus
- **Script:** Uses `launch_app.sh` to prevent duplicates

These scratchpads allow you to quickly toggle overlay windows for frequently used web applications without cluttering your regular workspaces.

## Uninstall

To remove the symlinks and restore backups:

```bash
rm ~/.config/hypr ~/.config/omadora ~/.config/waybar ~/.config/wofi
mv ~/.config/backup/* ~/.config/ 2>/dev/null
```

## Credits

Based on [Omadora](https://github.com/omadora/omadora) by the Omadora team.

## License

MIT License - Feel free to use and modify as needed.
