#!/bin/bash
# Import and install ZFS module

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKTITLE="Nordix Installer"

# Download ZFS module
ZFS_MODULE_URL="https://github.com/jimmykallhagen/nordix-installer/releases/download/zfs-module-6.18.59-1/zfs-module-arch-linux-lts-6.18.59-1.tar.zst"
SHA256SUMS_URL="https://github.com/jimmykallhagen/nordix-installer/releases/download/zfs-module-6.18.59-1/SHA256SUMS"


curl -L "$ZFS_MODULE_URL" -o zfs-module-arch-linux-lts-6.18.59-1.tar.zst
curl -L "$SHA256SUMS_URL" -o SHA256SUMS

mkdir -p /usr/lib/modules


# Verify checksum
sha256sum -c SHA256SUMS
if [ $? != 0 ]; then
    rm -f zfs-module-arch-linux-lts-6.18.59-1.tar.zst SHA256SUMS
    curl -L "$ZFS_MODULE_URL" -o zfs-module-arch-linux-lts-6.18.59-1.tar.zst
    curl -L "$SHA256SUMS_URL" -o SHA256SUMS
    sleep 3
    sha256sum -c SHA256SUMS

    if [ $? != 0 ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Checksum Verification Failed twice" \
            --msgbox "ZFS Module error, rebooting" 5 40
        reboot
    fi
fi

# Extract ZFS module
tar -xf zfs-module-arch-linux-lts-6.18.59-1.tar.zst -C /usr/lib/modules

# Update module dependencies
depmod -a 6.18.59-1-lts

# Load ZFS module
modprobe -f zfs


if [ $? != 0 ]; then
    sleep 3
    modprobe -f zfs

    if [ $? != 0 ]; then
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "ZFS Module Load Failed twice" \
            --msgbox "ZFS Module error, rebooting" 5 40
        reboot
    fi
fi

dialog --clear \
--backtitle "$BACKTITLE" \
--title "Armed and ready!" \
--msgbox "ZFS Module loaded successfully" 5 35

# Clean up
rm -f zfs-module-arch-linux-lts-6.18.59-1.tar.zst SHA256SUMS
