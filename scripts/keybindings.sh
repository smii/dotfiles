#!/usr/bin/env bash
# Keybinding overview — Page 1: bindings  Page 2: installed tools & TUI apps

BINDINGS="${HOME}/.config/hypr/bindings.conf"
W=(--dmenu --theme tokyonight-compact --width 760 --height 680)

fmt_mods() {
    local m="$1"
    m="${m//SUPER/Super}"; m="${m//SHIFT/Shift}"
    m="${m//CTRL/Ctrl}";   m="${m//ALT/Alt}"
    m="${m// /+}"
    echo "$m"
}

fmt_key() {
    case "$1" in
        RETURN)     echo "Enter"      ;;  SPACE)       echo "Space"     ;;
        ESCAPE)     echo "Esc"        ;;  TAB)         echo "Tab"       ;;
        BACKSPACE)  echo "Backspace"  ;;  PRINT)       echo "PrtSc"     ;;
        DELETE)     echo "Del"        ;;  comma)       echo ","          ;;
        SLASH)      echo "/"          ;;  fullscreen)  echo "F11"        ;;
        code:10)    echo "1"  ;;  code:11) echo "2"  ;;  code:12) echo "3"  ;;
        code:13)    echo "4"  ;;  code:14) echo "5"  ;;  code:15) echo "6"  ;;
        code:16)    echo "7"  ;;  code:17) echo "8"  ;;  code:18) echo "9"  ;;
        code:19)    echo "0"  ;;  code:20) echo "-"  ;;  code:21) echo "="  ;;
        XF86MonBrightnessUp)   echo "Brightness+"  ;;
        XF86MonBrightnessDown) echo "Brightness-"  ;;
        XF86AudioRaiseVolume)  echo "Vol+"          ;;
        XF86AudioLowerVolume)  echo "Vol-"          ;;
        XF86AudioMute)         echo "Mute"          ;;
        XF86AudioMicMute)      echo "MicMute"       ;;
        XF86AudioNext)         echo "Next"          ;;
        XF86AudioPrev)         echo "Prev"          ;;
        XF86AudioPlay)         echo "Play"          ;;
        XF86AudioPause)        echo "Pause"         ;;
        XF86PowerOff)          echo "Power"         ;;
        XF86Calculator)        echo "Calc"          ;;
        mouse:272)  echo "LMB"      ;;
        mouse:273)  echo "RMB"      ;;
        mouse_down) echo "Scroll↓"  ;;
        mouse_up)   echo "Scroll↑"  ;;
        *)          echo "$1"        ;;
    esac
}

build_bindings() {
    grep -E '^bind[a-z]*d[[:space:]]*=' "$BINDINGS" | while IFS= read -r line; do
        content="${line#*=}"
        # Split on commas using awk to avoid read -a portability issues
        mods=$(echo "$content" | awk -F, '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$1); print $1}')
        key=$(echo  "$content" | awk -F, '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2}')
        desc=$(echo "$content" | awk -F, '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3}')
        [[ -z "$desc" ]] && continue
        key_str=$(fmt_key "$key")
        [[ -n "$mods" ]] && combo="$(fmt_mods "$mods")+${key_str}" || combo="$key_str"
        printf "%-32s %s\n" "$combo" "$desc"
    done
}

has() { command -v "$1" &>/dev/null; }

page_keybindings() {
    local body
    body=$(build_bindings)
    local nav="$(printf '%-32s %s' '' '→ Installed Tools & Apps')"
    local sel
    sel=$(printf '%s\n%s' "$body" "$nav" | walker "${W[@]}" -p "Keybindings…" 2>/dev/null)
    [[ "$sel" == *"Installed Tools"* ]] && page_tools
}

page_tools() {
    local L=""
    L+="── Network & Security ─────────────────────────────────────────────\n"
    has opensnitch-ui && L+="󰒍  OpenSnitch       Application firewall — allow/block connections per app\n"
    has netscanner    && L+="󰀺  netscanner       LAN host + port scanner\n"
    has iptstate      && L+="󰓮  iptstate         Live view of active network connections (iptables)\n"
    L+="── Docker ─────────────────────────────────────────────────────────\n"
    has lazydocker    && L+="󰡨  lazydocker       Container + image dashboard  Super+Shift+D\n"
    has dive          && L+="󰡨  dive             Inspect Docker image layers\n"
    L+="── System TUI Apps ────────────────────────────────────────────────\n"
    has btop          && L+="󰍛  btop             CPU / memory / process monitor  Super+Shift+T\n"
    has htop          && L+="󰍛  htop             Lightweight process viewer\n"
    has bluetui       && L+="󰂯  bluetui          Bluetooth device manager  Super+Ctrl+B\n"
    has nmtui         && L+="  nmtui            Wi-Fi / network manager  Alt+Ctrl+W\n"
    has lazygit       && L+="  lazygit          Interactive git interface\n"
    has ncdu          && L+="  ncdu             Disk usage browser (ncurses)\n"
    L+="── Utilities ──────────────────────────────────────────────────────\n"
    has pavucontrol   && L+="  pavucontrol      PulseAudio / PipeWire mixer  Super+Ctrl+A\n"
    has hyprpicker    && L+="  hyprpicker       Screen color picker  Super+PrtSc\n"
    has qalculate-gtk && L+="  qalculate        Scientific calculator  Calc key\n"
    has btrfs-assistant && L+="  btrfs-assistant  Btrfs snapshot manager\n"
    L+="── ← Back to Keybindings"

    local sel
    sel=$(printf '%b' "$L" | walker "${W[@]}" -p "Tools & Apps…" 2>/dev/null)

    case "$sel" in
        *"← Back"*)        page_keybindings ;;
        *OpenSnitch*)      opensnitch-ui & ;;
        *netscanner*)      ghostty --class=tui.float -e bash -c "pkexec netscanner; read -rp 'Press Enter to close'" & ;;
        *iptstate*)        ghostty --class=tui.float -e bash -c "pkexec iptstate; read -rp 'Press Enter to close'" & ;;
        *lazydocker*)      ghostty --class=tui.lazydocker -e lazydocker & ;;
        *dive*)            ghostty --class=tui.float -e dive & ;;
        *btop*)            ghostty --class=tui.btop -e btop & ;;
        *htop*)            ghostty --class=tui.float -e htop & ;;
        *bluetui*)         ghostty --class=tui.bluetui -e bluetui & ;;
        *nmtui*)           ghostty --class=tui.nmtui -e nmtui & ;;
        *lazygit*)         ghostty --class=tui.float -e lazygit & ;;
        *ncdu*)            ghostty --class=tui.float -e ncdu & ;;
        *pavucontrol*)     pavucontrol & ;;
        *hyprpicker*)      hyprpicker -a & ;;
        *qalculate*)       qalculate-gtk & ;;
        *btrfs-assistant*) btrfs-assistant & ;;
    esac
}

page_keybindings
