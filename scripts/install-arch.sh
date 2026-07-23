#!/bin/bash
# =====================================================================
# ClamCenter Installer Module - Arch Linux / Manjaro / EndeavourOS
# =====================================================================

SCRIPT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

handle_error() {
    echo ""
    echo "❌ [ERROR DEBUG] $1"
    read -r -p "⚠️ Do you want to ignore this error and continue? [y/N]: " RESP
    RESP_CLEAN=$(echo "$RESP" | tr '[:upper:]' '[:lower:]' | xargs)
    if [[ "$RESP_CLEAN" != "y" && "$RESP_CLEAN" != "yes" ]]; then
        echo "[-] Installation aborted."
        exit 1
    fi
}

echo "[+] Step 1: Package Dependencies (pacman)"
pacman -Sy --needed clamav inotify-tools zip unzip libnotify || handle_error "Failed package installation via pacman"

echo "[+] Step 2: System User Check"
getent group clamav >/dev/null 2>&1 || groupadd -r clamav
id -u clamav >/dev/null 2>&1 || useradd -r -g clamav -s /bin/false clamav

echo "[+] Step 3: Installing Configuration File"
mkdir -p /etc/clamav
if [ -f "$SCRIPT_DIR/configs/clamd.conf" ]; then
    cp -f "$SCRIPT_DIR/configs/clamd.conf" /etc/clamav/clamd.conf
    chmod 644 /etc/clamav/clamd.conf
    echo "[✔] Installed /etc/clamav/clamd.conf"
fi

echo "[+] Step 4: Directory & Permission Setup"
DIRS=("/var/lib/clamav" "/var/log/clamav" "/run/clamav" "/var/log/clamav/quarantine" "/tmp/quarantine" "/tmp/quarantine_vault")
for d in "${DIRS[@]}"; do
    mkdir -p "$d"
    chmod 775 "$d" 2>/dev/null || true
    chown -R clamav:clamav "$d" 2>/dev/null || true
done
chmod 750 /var/log/clamav/quarantine /tmp/quarantine /tmp/quarantine_vault 2>/dev/null || true

echo "[+] Step 5: Binaries & Desktop Launcher"
mkdir -p /usr/local/bin /usr/share/applications
[ -f "$SCRIPT_DIR/bin/defender" ] && cp -f "$SCRIPT_DIR/bin/defender" /usr/local/bin/ && chmod +x /usr/local/bin/defender
[ -f "$SCRIPT_DIR/bin/quarantine-notifier" ] && cp -f "$SCRIPT_DIR/bin/quarantine-notifier" /usr/local/bin/ && chmod +x /usr/local/bin/quarantine-notifier
[ -f "$SCRIPT_DIR/desktop/defender.desktop" ] && cp -f "$SCRIPT_DIR/desktop/defender.desktop" /usr/share/applications/ && chmod +x /usr/share/applications/defender.desktop
command -v update-desktop-database &>/dev/null && update-desktop-database /usr/share/applications 2>/dev/null || true

echo "[+] Step 6: Systemd Unit Generation"
ARCH_DAEMON="clamd.service"
if systemctl list-unit-files | grep -q "^clamd@.service"; then
    ARCH_DAEMON="clamd@scan.service"
elif systemctl list-unit-files | grep -q "^clamav-daemon.service"; then
    ARCH_DAEMON="clamav-daemon.service"
fi

CLAMONACC_BIN=$(command -v clamonacc || echo "/usr/bin/clamonacc")
cat <<EOF > /etc/systemd/system/clamav-clamonacc.service
[Unit]
Description=ClamAV On-Access Scanner
Wants=$ARCH_DAEMON
After=$ARCH_DAEMON network.target

[Service]
Type=simple
ExecStart=
ExecStart=$CLAMONACC_BIN -F --fdpass --log=/var/log/clamav/clamonacc.log --move=/var/log/clamav/quarantine
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

[ -f "$SCRIPT_DIR/systemd/clamav-quarantine-notifier.service" ] && cp -f "$SCRIPT_DIR/systemd/clamav-quarantine-notifier.service" /etc/systemd/system/

echo "[+] Step 7: Inotify & Virus DB Setup"
sysctl -w fs.inotify.max_user_watches=524288 >/dev/null 2>&1 || true
echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/99-clamcenter.conf

if [ -f /etc/clamav/freshclam.conf ]; then
    sed -i 's/^Example/#Example/' /etc/clamav/freshclam.conf 2>/dev/null || true
fi

if ! ls /var/lib/clamav/*.c[vl]d >/dev/null 2>&1; then
    echo "[!] Downloading initial virus definitions..."
    freshclam || handle_error "freshclam failed to download database"
    chown -R clamav:clamav /var/lib/clamav 2>/dev/null || true
fi

echo "[+] Step 8: Systemd Service Execution"
systemctl daemon-reload
read -r -p "Do you want to enable and start all ClamAV services now? [Y/n]: " START_SRVS
START_SRVS_CLEAN=$(echo "${START_SRVS:-Y}" | tr '[:upper:]' '[:lower:]' | xargs)

if [[ "$START_SRVS_CLEAN" == "y" || "$START_SRVS_CLEAN" == "yes" ]]; then
    for srv in clamav-freshclam.service "$ARCH_DAEMON" clamav-clamonacc.service clamav-quarantine-notifier.service; do
        systemctl list-unit-files | grep -q "^${srv}" || continue
        systemctl enable "$srv" 2>/dev/null || true
        systemctl restart "$srv" || {
            echo "⚠️ [LOGS FOR $srv]"
            journalctl -u "$srv" -n 15 --no-pager
            handle_error "Failed to start $srv"
        }
    done
fi

echo "[+] Step 9: Optional Deep Scanners"
read -r -p "Do you want to install optional deep scanners (rkhunter & lynis)? [y/N]: " DEEP
DEEP_CLEAN=$(echo "${DEEP:-N}" | tr '[:upper:]' '[:lower:]' | xargs)
if [[ "$DEEP_CLEAN" == "y" || "$DEEP_CLEAN" == "yes" ]]; then
    pacman -S --needed rkhunter lynis
    rkhunter --propupd >/dev/null 2>&1 || true
fi

echo "=========================================="
echo " [✔] Arch Linux installation complete!"
echo "=========================================="