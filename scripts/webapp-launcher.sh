#!/usr/bin/env bash
# Create a Chromium webapp .desktop launcher
# Launched from: system-menu → Install → Web App

APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"

echo ""
echo "  Create Web App Launcher"
echo "  ─────────────────────────────────────"
echo ""
read -rp "  App name:                  " name
[[ -z "$name" ]] && echo "  Cancelled." && read -rp "" && exit 0

read -rp "  URL (https://...):         " url
[[ -z "$url" ]] && echo "  Cancelled." && read -rp "" && exit 0

read -rp "  Profile [work/private]:    " profile
profile="${profile:-work}"
[[ "$profile" != "work" && "$profile" != "private" ]] && profile="work"

safe=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
desktop="$APPS_DIR/webapp-${safe}.desktop"

cat > "$desktop" << DESKTOP
[Desktop Entry]
Version=1.0
Name=${name}
Comment=Web app: ${url}
Exec=chromium --app=${url} --profile-directory=${profile}
Icon=chromium
Type=Application
Categories=Network;WebApp;
StartupWMClass=chromium
DESKTOP

chmod 644 "$desktop"
echo ""
echo "  ✓ ${name}"
echo "    ${url}"
echo "    Profile: ${profile}"
echo "    File:    ${desktop}"
echo ""
read -rp "  Press Enter to close"
