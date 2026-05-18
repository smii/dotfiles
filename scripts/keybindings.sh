#!/usr/bin/env bash
# Searchable keybinding overview via Walker dmenu.
# Parses all bind*d entries (those with an inline description).

BINDINGS="${HOME}/.config/hypr/bindings.conf"

fmt_mods() {
    local m="${1// /+}"
    m="${m//SUPER/Super}"
    m="${m//SHIFT/Shift}"
    m="${m//CTRL/Ctrl}"
    m="${m//ALT/Alt}"
    echo "$m"
}

fmt_key() {
    case "$1" in
        RETURN)      echo "Enter" ;;
        SPACE)       echo "Space" ;;
        ESCAPE)      echo "Esc" ;;
        TAB)         echo "Tab" ;;
        BACKSPACE)   echo "Backspace" ;;
        PRINT)       echo "PrtSc" ;;
        DELETE)      echo "Del" ;;
        comma)       echo "," ;;
        period)      echo "." ;;
        SLASH)       echo "/" ;;
        fullscreen)  echo "F11" ;;
        code:10)     echo "1" ;;  code:11) echo "2" ;;
        code:12)     echo "3" ;;  code:13) echo "4" ;;
        code:14)     echo "5" ;;  code:15) echo "6" ;;
        code:16)     echo "7" ;;  code:17) echo "8" ;;
        code:18)     echo "9" ;;  code:19) echo "0" ;;
        code:20)     echo "-" ;;  code:21) echo "=" ;;
        XF86MonBrightnessUp)    echo "BrightnessUp" ;;
        XF86MonBrightnessDown)  echo "BrightnessDown" ;;
        XF86AudioRaiseVolume)   echo "Vol+" ;;
        XF86AudioLowerVolume)   echo "Vol-" ;;
        XF86AudioMute)          echo "Mute" ;;
        XF86AudioMicMute)       echo "MicMute" ;;
        XF86AudioNext)          echo "Next" ;;
        XF86AudioPrev)          echo "Prev" ;;
        XF86AudioPlay)          echo "Play" ;;
        XF86AudioPause)         echo "Pause" ;;
        XF86PowerOff)           echo "Power" ;;
        XF86Calculator)         echo "Calc" ;;
        mouse:272)   echo "LMB" ;;
        mouse:273)   echo "RMB" ;;
        mouse_down)  echo "Scroll↓" ;;
        mouse_up)    echo "Scroll↑" ;;
        *)           echo "$1" ;;
    esac
}

grep -E '^bind[a-z]*d\s*=' "$BINDINGS" | while IFS= read -r line; do
    content="${line#*=}"
    IFS=',' read -ra f <<< "$content"
    mods=$(echo "${f[0]}" | xargs)
    key=$( echo "${f[1]}" | xargs)
    desc=$(echo "${f[2]}" | xargs)
    [[ -z "$desc" ]] && continue

    key_display=$(fmt_key "$key")
    if [[ -n "$mods" ]]; then
        combo="$(fmt_mods "$mods")+${key_display}"
    else
        combo="$key_display"
    fi

    printf "%-36s %s\n" "$combo" "$desc"
done | walker --dmenu -p "Keybindings…" --width 720 --minheight 1 --maxheight 900 2>/dev/null
