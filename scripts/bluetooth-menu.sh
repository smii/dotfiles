#!/usr/bin/env bash
# Bluetooth picker via walker --dmenu

SCAN_TIMEOUT=10

bt_powered() { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }

connected_devices() {
    bluetoothctl devices Connected 2>/dev/null \
        | awk '{$1=$2=""; print substr($0,3)}'
}

paired_devices() {
    bluetoothctl devices Paired 2>/dev/null \
        | awk '{mac=$2; $1=$2=""; name=substr($0,3); print mac " " name}'
}

build_list() {
    local connected=()
    local paired_only=()

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        mac="${line%% *}"
        name="${line#* }"
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            connected+=("󰂱  $name (connected)__$mac")
        else
            paired_only+=("󰂯  $name__$mac")
        fi
    done < <(paired_devices)

    for item in "${connected[@]}";   do echo "$item"; done
    for item in "${paired_only[@]}"; do echo "$item"; done
}

HEADER="  Bluetooth"
SEPARATOR="─────────────────────────────────"
SCAN_ITEM="󰂰  Scan for new devices"
TOGGLE_OFF_ITEM="󰂲  Turn Bluetooth off"
TOGGLE_ON_ITEM="󰂯  Turn Bluetooth on"
SETTINGS_ITEM="󰒍  Open bluetui"

if ! bt_powered; then
    entries="$HEADER\n$SEPARATOR\n$TOGGLE_ON_ITEM\n$SETTINGS_ITEM"
    selected=$(printf '%b' "$entries" | walker --dmenu --label "Bluetooth" --width 340 --height 200)
    case "$selected" in
        "$TOGGLE_ON_ITEM") bluetoothctl power on; notify-send -u low "Bluetooth" "Turned on" ;;
        "$SETTINGS_ITEM")  ghostty -e bluetui ;;
    esac
    exit 0
fi

device_list=$(build_list)
entries="$HEADER\n$SEPARATOR"
[[ -n "$device_list" ]] && entries+="\n$device_list"
entries+="\n$SEPARATOR\n$SCAN_ITEM\n$TOGGLE_OFF_ITEM\n$SETTINGS_ITEM"

selected=$(printf '%b' "$entries" | walker --dmenu --label "Bluetooth" --width 380 --height 360)

[[ -z "$selected" ]] && exit 0

mac="${selected##*__}"
label="${selected%__*}"

case "$selected" in
    "$SCAN_ITEM")
        notify-send -u low "Bluetooth" "Scanning ${SCAN_TIMEOUT}s…"
        bluetoothctl --timeout "$SCAN_TIMEOUT" scan on &>/dev/null
        # Re-open menu after scan
        exec "$0"
        ;;
    "$TOGGLE_OFF_ITEM")
        bluetoothctl power off
        notify-send -u low "Bluetooth" "Turned off"
        ;;
    "$SETTINGS_ITEM")
        ghostty -e bluetui
        ;;
    "$HEADER"|"$SEPARATOR"|"")
        exit 0
        ;;
    *)
        [[ "$mac" == "$label" ]] && exit 0   # no __ separator found
        if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$mac"
            name="${label#*  }"
            name="${name% (connected)}"
            notify-send -u low "Bluetooth" "Disconnected $name"
        else
            bluetoothctl connect "$mac"
            name="${label#*  }"
            notify-send -u low "Bluetooth" "Connecting to $name…"
        fi
        ;;
esac
