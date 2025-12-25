#!/bin/bash

# Dotfiles installer script
# Symlinks configuration folders to ~/.config

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration folders to symlink
CONFIGS=("hypr" "omadora" "waybar" "wofi")

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}  Dotfiles Installer (Omadora)${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""
echo -e "This script will symlink dotfiles from:"
echo -e "${GREEN}${DOTFILES_DIR}${NC}"
echo -e "to ${GREEN}~/.config${NC}"
echo ""

# Function to backup existing config
backup_config() {
    local config_name=$1
    local config_path="$HOME/.config/$config_name"
    local backup_dir="$HOME/.config/backup"
    
    if [ -e "$config_path" ] && [ ! -L "$config_path" ]; then
        echo -e "${YELLOW}  → Backing up existing $config_name${NC}"
        mkdir -p "$backup_dir"
        mv "$config_path" "$backup_dir/${config_name}_$(date +%Y%m%d_%H%M%S)"
    elif [ -L "$config_path" ]; then
        echo -e "${YELLOW}  → Removing existing symlink for $config_name${NC}"
        rm "$config_path"
    fi
}

# Function to create symlink
create_symlink() {
    local config_name=$1
    local source="$DOTFILES_DIR/$config_name"
    local target="$HOME/.config/$config_name"
    
    if [ ! -d "$source" ]; then
        echo -e "${RED}  ✗ Source directory $source not found, skipping${NC}"
        return 1
    fi
    
    ln -sf "$source" "$target"
    echo -e "${GREEN}  ✓ Linked $config_name${NC}"
}

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Ask for confirmation
read -p "Continue with installation? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Starting installation...${NC}"
echo ""

# Process each config folder
for config in "${CONFIGS[@]}"; do
    backup_config "$config"
    create_symlink "$config"
done

echo ""
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""
echo -e "Your dotfiles are now symlinked to ~/.config"
echo -e "Any backups were saved to ${YELLOW}~/.config/backup${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Log out and log back in, or reload Hyprland"
echo -e "  2. Check ${GREEN}$DOTFILES_DIR/README.md${NC} for customization options"
echo -e "  3. Customize themes in ${GREEN}omadora/current/${NC}"
echo ""
