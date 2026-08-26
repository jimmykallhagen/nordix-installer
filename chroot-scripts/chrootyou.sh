#!/bin/bash
# Mighthy arch-chroot - (of topic) the best way to run your containers with zfs clones
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
SSH_Y_N="$(cat "${CONFIG_DIR}/ssh_yn.conf")"
VM_Y_N="$(cat "${CONFIG_DIR}/vm_yn.conf")"
MOUNT_POINT="/mnt"
PREEMADE_DIR="${SCRIPT_DIR}/../preemade-configs"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
source "${CONFIG_DIR}/gpu.conf"

# Auto find timezone
TIMEZONE=$(curl http://ip-api.com/line | grep /)
# Wait for a valid timezone
while true; do
    [[ -n "$TIMEZONE" ]] && break
    sleep 1
done
# Set the correct timezone
arch-chroot "$MOUNT_POINT" ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime

# Services
services=(
        "NetworkManager.service"
        "bluetooth.service"
        "ufw.service"
        "irqbalance.service"
        "systemd-timesyncd.service"
        "ananicy-cpp.service"
        "smartd.service"
    )
    # Enable services
for service in "${services[@]}"; do
    arch-chroot "${MOUNT_POINT}" systemctl enable "$service" 2>/dev/null || true
done

if [[ $VM_Y_N == "yes" ]]; then
vm_services=(
    "virtqemud.socket"
    "virtnetworkd.socket"
    "virtstoraged.socket"
    "virtnodedevd.socket"
    "virtsecretd.socket"
    "virtproxyd.socket"
    "virtlogd.socket"
    )
    # Enable VM services
for service in "${vm_services[@]}"; do
    arch-chroot "${MOUNT_POINT}" systemctl enable "$service" 2>/dev/null || true
done
fi

# Activate some user service global instead so that they is ready to use
users_services=(
        "dbus-broker.service"
        "pipewire.socket"
        "pipewire-pulse.socket"
        "wireplumber.service"
        "pipewire.service"
        "systemd-timesyncd.service"
    )
    # Enable user services globally
for service in "${users_services[@]}"; do
    arch-chroot "${MOUNT_POINT}" systemctl --global enable "$users_services" 2>/dev/null || true
done

# Let us sync the time so the user know what the clock is
arch-chroot "${MOUNT_POINT}" systemctl enable systemd-timesyncd.service 2>/dev/null || true

# Set default policies for the firewall
arch-chroot "${MOUNT_POINT}" ufw default deny incoming
arch-chroot "${MOUNT_POINT}" ufw default allow outgoing
# Allow SSH (optional)
if [[ SSH_Y_N == "yes" ]]; then
    arch-chroot "$MOUNT_POINT" ufw allow ssh
    arch-chroot "$MOUNT_POINT" systemctl enable sshd.service
fi
# Enable UFW
arch-chroot "${MOUNT_POINT}" ufw --force enable

# Setup NVIDIA if the user has a NVIDIA GPU
if [[ $GPU == "LEGACY-NVIDIA" || $GPU == "NVIDIA" ]]; then
    # Add nvidia modules to mkinit.conf
    arch-chroot "${MOUNT_POINT}" sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' "${MKINITCPIO_CONF}"
    # Enable NVIDIA power management
    arch-chroot "${MOUNT_POINT}" systemctl enable nvidia-suspend.service 2>/dev/null || true
    arch-chroot "${MOUNT_POINT}" systemctl enable nvidia-hibernate.service 2>/dev/null || true
    arch-chroot "${MOUNT_POINT}" systemctl enable nvidia-resume.service 2>/dev/null || true
    # Apply NVIDIA GPU config
    cp ${CONFIG_DIR}/nvidia-gpu.conf ${MOUNT_POINT}/etc/modprobe.d/nvidia.conf

fi

# Create S.M.A.R.T check on boot
arch-chroot "${MOUNT_POINT}" echo "DEVICESCAN -a" >> /etc/smartd.conf
arch-chroot "${MOUNT_POINT}" cat > /usr/share/smartmontools/smartd_warning.d/smartdnotify << 'EOF'
#!/bin/sh
for users in $(loginctl list-users --json short | jq -r '.[].user') ; do
        systemd-run --machine="$users"@.host --user notify-send "S.M.A.R.T Error ($SMARTD_FAILTYPE)" "$SMARTD_MESSAGE">
done
EOF
arch-chroot "${MOUNT_POINT}" chmod +x /usr/share/smartmontools/smartd_warning.d/smartdnotify

# Fonts
arch-chroot "${MOUNT_POINT}" ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
arch-chroot "${MOUNT_POINT}" ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
arch-chroot "${MOUNT_POINT}" ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
arch-chroot "${MOUNT_POINT}" fc-cache -fv
