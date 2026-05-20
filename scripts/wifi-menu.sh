#!/usr/bin/env bash
# WiFi picker via walker --dmenu
# Left-click: connect to selected network
# Right-click (called with --scan): trigger rescan

SELF="$HOME/.local/bin/wifi-menu"

# Rescan in background if not recently done
nmcli device wifi list --rescan auto &>/dev/null &

build_list() {
    nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY,BARS device wifi list 2>/dev/null \
        | awk -F: '{
            inuse  = ($1 == "*") ? " " : "  "
            ssid   = $2
            signal = $3
            sec    = ($4 != "") ? "🔒" : "  "
            bars   = $5
            if (ssid == "") next
            printf "%s %s  %s %s\n", inuse, ssid, bars, sec
        }' \
        | sort -u
}

connect_network() {
    local ssid="$1"
    # Try to activate an existing connection first
    if nmcli connection show "$ssid" &>/dev/null; then
        nmcli connection up "$ssid" &>/dev/null && \
            notify-send -u low "WiFi" "Connected to $ssid" || \
            notify-send -u normal "WiFi" "Failed to connect to $ssid"
        return
    fi
    # Known SSID but no saved connection — check if secured
    local security
    security=$(nmcli -t -f SSID,SECURITY device wifi list 2>/dev/null \
        | awk -F: -v s="$ssid" '$1==s {print $2; exit}')
    if [[ -n "$security" ]]; then
        # Prompt for password in a terminal
        ghostty --class=tui.float --title="WiFi: $ssid" -e bash -c "
            echo 'Connecting to: $ssid'
            read -rsp 'Password: ' pass
            echo
            nmcli device wifi connect '$ssid' password \"\$pass\" && \
                notify-send -u low 'WiFi' 'Connected to $ssid' || \
                notify-send -u critical 'WiFi' 'Failed to connect to $ssid'
        "
    else
        nmcli device wifi connect "$ssid" &>/dev/null && \
            notify-send -u low "WiFi" "Connected to $ssid" || \
            notify-send -u normal "WiFi" "Failed to connect to $ssid"
    fi
}

# Build menu items
HEADER="  WiFi Networks"
SEPARATOR="─────────────────────────────────"
DISCONNECT_ITEM="󰤮  Disconnect"
SETTINGS_ITEM="󰒍  Network settings (nmtui)"

entries="$HEADER\n$SEPARATOR\n$(build_list)\n$SEPARATOR\n$DISCONNECT_ITEM\n$SETTINGS_ITEM"

selected=$(printf '%b' "$entries" | walker --dmenu --theme tokyonight-compact --placeholder "WiFi" --width 280 --height 280)

[[ -z "$selected" ]] && exit 0

case "$selected" in
    "$DISCONNECT_ITEM")
        nmcli device disconnect wlan0 2>/dev/null || nmcli device disconnect wlp* 2>/dev/null
        notify-send -u low "WiFi" "Disconnected"
        ;;
    "$SETTINGS_ITEM")
        ghostty -e nmtui
        ;;
    "$HEADER"|"$SEPARATOR"|"")
        exit 0
        ;;
    *)
        # Extract SSID — strip leading status char and bars/lock suffix
        ssid=$(echo "$selected" | sed 's/^[* ] //' | awk '{print $1}')
        [[ -n "$ssid" ]] && connect_network "$ssid"
        ;;
esac
