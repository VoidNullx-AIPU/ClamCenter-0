#!/bin/bash

# =====================================================================
# ClamCenter Security - Main Installer Router (Debian & Arch)
# =====================================================================

if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run this installer with sudo: sudo ./install.sh"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "    🛡️ ClamCenter Security Installer      "
echo "=========================================="

OS_TYPE=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian|pop|mint|linuxmint)
            OS_TYPE="debian"
            ;;
        arch|manjaro|endeavouros|garuda)
            OS_TYPE="arch"
            ;;
        *)
            if [[ "$ID_LIKE" =~ (ubuntu|debian) ]]; then
                OS_TYPE="debian"
            elif [[ "$ID_LIKE" =~ (arch) ]]; then
                OS_TYPE="arch"
            fi
            ;;
    esac
fi

if [ -z "$OS_TYPE" ]; then
    echo "⚠️ Could not automatically detect a supported Debian or Arch distribution."
    echo "Select your distribution manually:"
    echo "1) Debian / Ubuntu / Mint / Pop!_OS"
    echo "2) Arch Linux / Manjaro / EndeavourOS"
    read -r -p "Choice [1-2]: " CHOICE
    case "$CHOICE" in
        1) OS_TYPE="debian" ;;
        2) OS_TYPE="arch" ;;
        *) echo "[-] Invalid selection. Exiting."; exit 1 ;;
    esac
fi

TARGET_SCRIPT="$SCRIPT_DIR/scripts/install-${OS_TYPE}.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
    echo "❌ [ERROR] Missing installer module: $TARGET_SCRIPT"
    exit 1
fi

chmod +x "$TARGET_SCRIPT"
echo "[+] Routing installation to module: scripts/install-${OS_TYPE}.sh"
echo "------------------------------------------"
exec "$TARGET_SCRIPT" "$SCRIPT_DIR"