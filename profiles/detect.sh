#!/usr/bin/env bash
# detect.sh - Detect system hardware and return the appropriate profile name
# Usage: source this script or run it to get the profile name
#   PROFILE=$(bash profiles/detect.sh)
#
# Supported profiles:
#   g14      - ASUS ROG Zephyrus G14 laptop (AMD iGPU + NVIDIA dGPU)
#   desktop  - ASUS ROG Crosshair VIII Impact (RTX 3080, dual monitor)
#   generic  - Any other system (auto-detect monitors, minimal assumptions)

set -euo pipefail

detect_profile() {
    local board_name product_name

    board_name=$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null || echo "Unknown")
    product_name=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "Unknown")

    # ASUS ROG Zephyrus G14 laptop
    if echo "$product_name" | grep -qiE "ROG.*G14|GA40[0-9]"; then
        echo "g14"
        return 0
    fi

    # ASUS ROG Crosshair VIII Impact desktop
    if echo "$board_name" | grep -qiE "CROSSHAIR.*IMPACT|ROG.*IMPACT"; then
        echo "desktop"
        return 0
    fi

    # Fallback: generic
    echo "generic"
    return 0
}

# When sourced, export DOTFILES_PROFILE; when executed, print it
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_profile
else
    export DOTFILES_PROFILE=$(detect_profile)
fi
