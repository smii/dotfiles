#!/usr/bin/env bash
# setup-winapps.sh - Automated WinApps installation
# Downloads Win10 ISO from Google Drive, installs WinApps, and starts the VM.
#
# Usage: bash scripts/setup-winapps.sh
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
WINAPPS_CONF="$DOTFILES/configs/winapps"
ISO_DIR="$HOME/.local/share/winapps"
ISO_PATH="$ISO_DIR/win10.iso"
WINAPPS_REPO="$HOME/.local/share/winapps-src"

# Google Drive folder ID containing the Windows 10 ISO
GDRIVE_FOLDER_ID="1FevplJG1Tw37FGqYgL3QXdgpiJMl5lZv"

echo "═══════════════════════════════════════"
echo " WinApps Automated Setup"
echo "═══════════════════════════════════════"

# ==========================================
# 1. Prerequisites
# ==========================================
echo ""
echo "[1/5] Checking prerequisites..."

# Ensure Docker is running
if ! systemctl is-active --quiet docker; then
    echo "  Starting Docker..."
    sudo systemctl enable --now docker
fi

# Ensure user is in docker group
if ! groups | grep -q docker; then
    echo "  Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "  ⚠ You may need to log out and back in for group changes to take effect."
fi

# Install gdown for Google Drive downloads
if ! command -v gdown &>/dev/null; then
    echo "  Installing gdown (Google Drive downloader)..."
    pip install --user gdown 2>/dev/null || pipx install gdown 2>/dev/null || {
        echo "  ✗ Failed to install gdown. Install manually: pip install gdown"
        exit 1
    }
fi

# Ensure gdown is in PATH
export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# 2. Download Windows 10 ISO
# ==========================================
echo ""
echo "[2/5] Windows 10 ISO..."
mkdir -p "$ISO_DIR"

if [[ -f "$ISO_PATH" ]]; then
    echo "  ✓ ISO already exists: $ISO_PATH"
else
    echo "  Downloading Windows 10 ISO from Google Drive..."
    echo "  Folder: https://drive.google.com/drive/folders/$GDRIVE_FOLDER_ID"
    echo "  This may take a while depending on your connection..."
    echo ""

    # Download all files from the Google Drive folder
    gdown --folder "https://drive.google.com/drive/folders/$GDRIVE_FOLDER_ID" \
        -O "$ISO_DIR/gdrive_download" --remaining-ok || {
        echo "  ✗ Download failed. The folder may require authentication."
        echo "  Try: gdown --folder 'https://drive.google.com/drive/folders/$GDRIVE_FOLDER_ID' -O '$ISO_DIR/gdrive_download'"
        exit 1
    }

    # Find the ISO file in downloaded content
    FOUND_ISO=$(find "$ISO_DIR/gdrive_download" -name "*.iso" -type f | head -1)
    if [[ -z "$FOUND_ISO" ]]; then
        echo "  ✗ No .iso file found in downloaded folder."
        echo "  Contents: $(ls -la "$ISO_DIR/gdrive_download/" 2>/dev/null)"
        exit 1
    fi

    mv "$FOUND_ISO" "$ISO_PATH"
    rm -rf "$ISO_DIR/gdrive_download"
    echo "  ✓ ISO saved: $ISO_PATH"
fi

# ==========================================
# 3. Deploy WinApps config
# ==========================================
echo ""
echo "[3/5] Deploying WinApps configuration..."

WINAPPS_CONFIG_DIR="$HOME/.config/winapps"
mkdir -p "$WINAPPS_CONFIG_DIR"

# Copy config files
cp "$WINAPPS_CONF/winapps.conf" "$WINAPPS_CONFIG_DIR/winapps.conf"
echo "  ✓ winapps.conf deployed"

# Prepare compose.yaml with the ISO path
COMPOSE_DEST="$WINAPPS_CONFIG_DIR/compose.yaml"
sed "s|#ISO_PATH_PLACEHOLDER|$ISO_PATH|g" "$WINAPPS_CONF/compose.yaml" > "$COMPOSE_DEST"
echo "  ✓ compose.yaml deployed (ISO: $ISO_PATH)"

# Copy OEM files
if [[ -d "$WINAPPS_CONF/oem" ]]; then
    cp -r "$WINAPPS_CONF/oem" "$WINAPPS_CONFIG_DIR/"
    echo "  ✓ OEM customizations deployed"
fi

# ==========================================
# 4. Install WinApps
# ==========================================
echo ""
echo "[4/5] Installing WinApps..."

if command -v winapps &>/dev/null; then
    echo "  ✓ WinApps already installed"
else
    if [[ -d "$WINAPPS_REPO" ]]; then
        echo "  Updating existing WinApps repo..."
        git -C "$WINAPPS_REPO" pull || true
    else
        echo "  Cloning WinApps..."
        git clone https://github.com/winapps-org/winapps.git "$WINAPPS_REPO"
    fi

    echo "  Running WinApps installer (non-interactive)..."
    cd "$WINAPPS_REPO"
    # --user: install for current user (~/.local/bin)
    # --setupAllOfficiallySupportedApps: auto-configure all supported apps
    bash setup.sh --user --setupAllOfficiallySupportedApps || {
        echo "  ⚠ WinApps installer failed. Retrying with basic install..."
        bash setup.sh --user || {
            echo "  ✗ WinApps installation failed."
            echo "    Run manually: cd $WINAPPS_REPO && bash setup.sh --user"
        }
    }
fi

# ==========================================
# 5. Start Windows VM
# ==========================================
echo ""
echo "[5/5] Starting Windows VM..."

cd "$WINAPPS_CONFIG_DIR"
if docker compose ps 2>/dev/null | grep -q "WinApps"; then
    echo "  ✓ Windows VM already running"
else
    echo "  Starting Docker Compose..."
    docker compose up -d
    echo "  ✓ Windows VM started"
    echo ""
    echo "  VNC access: http://127.0.0.1:8006"
    echo "  RDP access: 127.0.0.1:3389"
    echo ""
    echo "  ⚠ Windows will take several minutes to install on first boot."
    echo "  Monitor progress at http://127.0.0.1:8006"
fi

echo ""
echo "═══════════════════════════════════════"
echo " WinApps Setup Complete"
echo "═══════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Wait for Windows to finish installing (VNC: http://127.0.0.1:8006)"
echo "  2. Once Windows is ready, run: winapps check"
echo "  3. Scan for apps: winapps scan"
