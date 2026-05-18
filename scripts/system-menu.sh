#!/usr/bin/env bash
# CachyOS settings menu — Super+Alt+Space

BACK_TO_EXIT=false

back_to() {
    local parent_menu="$1"
    if [[ $BACK_TO_EXIT == "true" ]]; then
        exit 0
    elif [[ -n $parent_menu ]]; then
        "$parent_menu"
    else
        show_main_menu
    fi
}

menu() {
    local prompt="$1"
    local options="$2"
    echo -e "$options" | walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "${prompt}…" 2>/dev/null
}

in_terminal() {
    ghostty -e bash -c "$*; echo; read -rp 'Press Enter to close'" &
}

tui_float() {
    ghostty --class=tui.float -e bash -c "$*; echo; read -rp 'Press Enter to close'" &
}

edit_file() {
    ghostty -e nvim "$1" &
}

notify() {
    notify-send -u low -t 2000 "$1" "$2"
}

# ── Main ──────────────────────────────────────────────────────────────────────
show_main_menu() {
    case $(menu "CachyOS" "  System\n󰍹  Toggles\n  Setup\n  Capture\n  Config\n  Install\n󰛳  Network") in
    *System*)   show_system_menu ;;
    *Toggles*)  show_toggle_menu ;;
    *Setup*)    show_setup_menu ;;
    *Capture*)  show_capture_menu ;;
    *Config*)   show_config_menu ;;
    *Install*)  show_install_menu ;;
    *Network*)  show_network_tools_menu ;;
    esac
}

# ── System ────────────────────────────────────────────────────────────────────
show_system_menu() {
    case $(menu "System" " Lock\n Suspend\n Reboot\n Shutdown\n Logout\n  Disk Usage\n  Snapshots") in
    *Lock)      loginctl lock-session ;;
    *Suspend)   systemctl suspend ;;
    *Reboot)    systemctl reboot ;;
    *Shutdown)  systemctl poweroff ;;
    *Logout)    loginctl terminate-user "$USER" ;;
    *Disk*)     tui_float "ncdu ~" ;;
    *Snapshot*) btrfs-assistant & ;;
    *)          back_to ;;
    esac
}

# ── Toggles ───────────────────────────────────────────────────────────────────
show_toggle_menu() {
    case $(menu "Toggle" "󰔎  Nightlight\n󱫖  Idle Lock\n󰂛  Notifications\n󰍜  Top Bar\n  Window Gaps\n  Transparency") in
    *Nightlight*)    ~/.local/bin/nightlight-toggle ;;
    *Idle*)          ~/.local/bin/idle-toggle ;;
    *Notifications*) ~/.local/bin/notification-silencing-toggle ;;
    *Bar*)           pkill waybar || waybar & ;;
    *Gaps*)          ~/.local/bin/window-gaps-toggle ;;
    *Transparency*)  ~/.local/bin/window-transparency-toggle ;;
    *)               back_to ;;
    esac
}

# ── Setup ─────────────────────────────────────────────────────────────────────
show_setup_menu() {
    case $(menu "Setup" "  Audio\n  Wi-Fi\n󰂯  Bluetooth\n󱐋  Power Profile\n󰍹  Monitors\n  Fan Control") in
    *Audio*)     pavucontrol & ;;
    *Wi-Fi*)     ghostty --class=tui.nmtui -e nmtui & ;;
    *Bluetooth*) ghostty --class=tui.bluetui -e bluetui & ;;
    *Power*)     show_power_profile_menu ;;
    *Monitors*)  hyprmon -profiles & ;;
    *Fan*)       xdg-open http://localhost:11987 & ;;
    *)           back_to ;;
    esac
}

show_power_profile_menu() {
    local current
    current=$(powerprofilesctl get 2>/dev/null)
    local choice
    choice=$(printf "performance\nbalanced\npower-saver" | \
        walker --dmenu -p "Power (now: $current)…" --width 295 --maxheight 130 2>/dev/null)
    if [[ -n "$choice" ]]; then
        powerprofilesctl set "$choice"
        notify "Power Profile" "Switched to $choice"
    else
        back_to show_setup_menu
    fi
}


# ── Capture ───────────────────────────────────────────────────────────────────
show_capture_menu() {
    case $(menu "Capture" "  Screenshot\n  Screenrecord\n󰴑  Extract Text (OCR)\n󰃉  Color Picker") in
    *Screenshot*)  ~/.local/bin/screenshot ;;
    *Screenrecord*) ~/.local/bin/screenrecord-toggle ;;
    *OCR*)         hyprshot -m region -o /tmp/ocr.png 2>/dev/null && \
                       tesseract /tmp/ocr.png stdout 2>/dev/null | wl-copy && \
                       notify "OCR" "Text copied to clipboard" ;;
    *Color*)       pkill hyprpicker || hyprpicker -a ;;
    *)             back_to ;;
    esac
}

# ── Config ────────────────────────────────────────────────────────────────────
show_config_menu() {
    case $(menu "Config" "  Hyprland\n  Bindings\n  Hypridle\n  Waybar\n  Walker\n  Gammastep\n  Ghostty") in
    *Hyprland*)  edit_file ~/.config/hypr/hyprland.conf ;;
    *Bindings*)  edit_file ~/.config/hypr/bindings.conf ;;
    *Hypridle*)  edit_file ~/.config/hypr/hypridle.conf ;;
    *Waybar*)    edit_file ~/.config/waybar/config.jsonc ;;
    *Walker*)    edit_file ~/.config/walker/config.toml ;;
    *Gammastep*) edit_file ~/.config/gammastep/config.ini ;;
    *Ghostty*)   edit_file ~/.config/ghostty/config ;;
    *)           back_to ;;
    esac
}

# ── Network Tools ─────────────────────────────────────────────────────────────
show_network_tools_menu() {
    case $(menu "Network" "󰒍  Firewall (OpenSnitch)\n󰀺  Network Scan\n󰓮  IP Connections\n󰡨  Docker\n󰡨  Image Layers (dive)") in
    *Firewall*)      opensnitch-ui & ;;
    *Scan*)          tui_float "pkexec netscanner" ;;
    *Connections*)   tui_float "pkexec iptstate" ;;
    *Docker*)        ghostty --class=tui.lazydocker -e lazydocker & ;;
    *Image*)         tui_float "dive" ;;
    *)               back_to ;;
    esac
}

# ── Install ───────────────────────────────────────────────────────────────────
show_install_menu() {
    case $(menu "Install" "󰣇  Package\n  Browser\n  Editor\n  Terminal\n󰵮  Dev Env\n  Service\n󱚤  AI\n  Gaming\n󰖟  Web App\n  Remove") in
    *Package*)  in_terminal "paru" ;;
    *Browser*)  show_install_browser_menu ;;
    *Editor*)   show_install_editor_menu ;;
    *Terminal*) show_install_terminal_menu ;;
    *Dev*)      show_install_dev_menu ;;
    *Service*)  show_install_service_menu ;;
    *AI*)       show_install_ai_menu ;;
    *Gaming*)   show_install_gaming_menu ;;
    *Web*)      ghostty --class=tui.float -e ~/.local/bin/webapp-launcher & ;;
    *Remove*)   show_remove_menu ;;
    *)          back_to ;;
    esac
}

show_install_browser_menu() {
    case $(menu "Browser" "  Chrome\n  Brave\n󰖟  Zen\n  Edge\n  Firefox") in
    *Chrome*)   in_terminal "paru -S --needed google-chrome" ;;
    *Brave*)    in_terminal "paru -S --needed brave-bin" ;;
    *Zen*)      in_terminal "paru -S --needed zen-browser-bin" ;;
    *Edge*)     in_terminal "paru -S --needed microsoft-edge-stable-bin" ;;
    *Firefox*)  in_terminal "paru -S --needed firefox" ;;
    *)          back_to show_install_menu ;;
    esac
}

show_install_editor_menu() {
    case $(menu "Editor" "  VSCode\n  Cursor\n  Zed\n  Sublime\n  Vim\n  Emacs") in
    *VSCode*)   in_terminal "paru -S --needed visual-studio-code-bin" ;;
    *Cursor*)   in_terminal "paru -S --needed cursor-bin" ;;
    *Zed*)      in_terminal "paru -S --needed zed" ;;
    *Sublime*)  in_terminal "paru -S --needed sublime-text-4" ;;
    *Vim*)      in_terminal "paru -S --needed vim" ;;
    *Emacs*)    in_terminal "paru -S --needed emacs-wayland && systemctl --user enable --now emacs.service" ;;
    *)          back_to show_install_menu ;;
    esac
}

show_install_terminal_menu() {
    case $(menu "Terminal" "  Kitty\n  Warp") in
    *Kitty*)    in_terminal "paru -S --needed kitty" ;;
    *Warp*)     in_terminal "paru -S --needed warp-terminal-bin" ;;
    *)          back_to show_install_menu ;;
    esac
}

show_install_dev_menu() {
    case $(menu "Dev Env" "  Node.js\n  Python\n  Go\n  Ruby\n  Rust\n  Bun\n  Java\n  PHP\n  Elixir\n  Zig\n  .NET\n  Docker DBs\n  lazygit") in
    *Node*)     in_terminal "mise use -g node@lts" ;;
    *Python*)   in_terminal "mise use -g python@latest" ;;
    *Go*)       in_terminal "mise use -g go@latest" ;;
    *Ruby*)     in_terminal "mise use -g ruby@latest" ;;
    *Rust*)     in_terminal "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" ;;
    *Bun*)      in_terminal "mise use -g bun@latest" ;;
    *Java*)     in_terminal "mise use -g java@latest" ;;
    *PHP*)      in_terminal "paru -S --needed php php-fpm composer" ;;
    *Elixir*)   in_terminal "mise use -g elixir@latest && mix local.hex --force && mix local.rebar --force" ;;
    *Zig*)      in_terminal "mise use -g zig@latest" ;;
    *NET*)      in_terminal "mise use -g dotnet@latest" ;;
    *Docker*)   in_terminal "paru -S --needed postgresql redis mariadb" ;;
    *lazygit*)  in_terminal "paru -S --needed lazygit" ;;
    *)          back_to show_install_menu ;;
    esac
}

show_install_service_menu() {
    case $(menu "Service" "  Tailscale\n󱇱  NordVPN\n  Dropbox") in
    *Tailscale*) in_terminal "sudo pacman -S --needed tailscale && sudo systemctl enable --now tailscaled && sudo tailscale up --accept-routes" ;;
    *NordVPN*)   in_terminal "paru -S --needed nordvpn-bin && sudo systemctl enable --now nordvpnd && sudo usermod -aG nordvpn $USER" ;;
    *Dropbox*)   in_terminal "paru -S --needed dropbox && systemctl --user enable --now dropbox" ;;
    *)           back_to show_install_menu ;;
    esac
}

show_install_ai_menu() {
    local ollama_pkg="ollama"
    command -v nvidia-smi &>/dev/null && ollama_pkg="ollama-cuda"
    command -v rocminfo   &>/dev/null && ollama_pkg="ollama-rocm"
    case $(menu "AI" "󱚤  Ollama\n󱚤  LM Studio") in
    *Ollama*)   in_terminal "paru -S --needed $ollama_pkg && sudo systemctl enable --now ollama" ;;
    *Studio*)   in_terminal "paru -S --needed lmstudio-bin" ;;
    *)          back_to show_install_menu ;;
    esac
}

show_install_gaming_menu() {
    case $(menu "Gaming" "  Steam\n  Lutris\n󱓟  Heroic\n󰍹  Moonlight\n  RetroArch\n  ProtonGE") in
    *Steam*)     in_terminal "paru -S --needed steam lib32-mesa lib32-vulkan-icd-loader" ;;
    *Lutris*)    in_terminal "paru -S --needed lutris" ;;
    *Heroic*)    in_terminal "paru -S --needed heroic-games-launcher-bin" ;;
    *Moonlight*) in_terminal "paru -S --needed moonlight-qt" ;;
    *RetroArch*) in_terminal "paru -S --needed retroarch" ;;
    *ProtonGE*)  in_terminal "paru -S --needed proton-ge-custom-bin" ;;
    *)           back_to show_install_menu ;;
    esac
}

show_remove_menu() {
    case $(menu "Remove" "󰣇  Package\n󰵮  Dev Runtime") in
    *Package*)  in_terminal "paru -Rns \$(paru -Qq | fzf --multi)" ;;
    *Runtime*)  in_terminal "mise list | fzf --multi | awk '{print \$1\"@\"\$2}' | xargs -r mise uninstall" ;;
    *)          back_to show_install_menu ;;
    esac
}

# ── Entry point ───────────────────────────────────────────────────────────────
if pgrep -f "walker.*--dmenu" >/dev/null; then
    walker --close >/dev/null 2>&1
    exit 0
fi

case "${1:-}" in
system)   BACK_TO_EXIT=true; show_system_menu ;;
toggles)  BACK_TO_EXIT=true; show_toggle_menu ;;
setup)    BACK_TO_EXIT=true; show_setup_menu ;;
capture)  BACK_TO_EXIT=true; show_capture_menu ;;
config)   BACK_TO_EXIT=true; show_config_menu ;;
install)  BACK_TO_EXIT=true; show_install_menu ;;
network)  BACK_TO_EXIT=true; show_network_tools_menu ;;
*)        show_main_menu ;;
esac
