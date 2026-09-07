
zfs_module() {
# Run download of correct kernel module
clear
gum_box "ZFS kernel module from ArchZFS - Searching for correct ZFS modules"

# Get current kernel version
KERNEL="$(uname -r)"

# Find matching module in archzfs repo
KERNEL_MODULE=$(curl -s https://archzfs.com/archzfs/x86_64/ \
    | grep -F "$KERNEL" \
    | grep -o 'href="[^"]*\.pkg\.tar\.zst"' \
    | head -n1 \
    | sed 's/href="//;s/"//')

# If no module found, set fallback flag
if [[ -z "$KERNEL_MODULE" ]]; then
    gum_box "No prebuilt module found for kernel $KERNEL – will use DKMS fallback"
    FALLBACK=1
else
    # Download and install the prebuilt module
    wget "https://archzfs.com/archzfs/x86_64/$KERNEL_MODULE" -O /tmp/zfs.pkg.tar.zst
    pacman -U /tmp/zfs.pkg.tar.zst --noconfirm
    INSTALL_STATUS=$?

    # Verify installation (with one retry after 2 seconds)
    if [[ $INSTALL_STATUS -eq 0 ]] && modinfo zfs &>/dev/null; then
        gum_box "ZFS module installed from prebuilt package"
        FALLBACK=0
    else
        gum_box "ZFS module not found immediately – waiting 2 seconds and retrying..."
        sleep 2
        if modinfo zfs &>/dev/null; then
            gum_box "ZFS module found after retry"
            FALLBACK=0
        else
            gum_box "ZFS module still not found – will use DKMS fallback"
            FALLBACK=1
        fi
    fi
fi

# If prebuilt failed, install zfs-dkms
if [[ $FALLBACK -eq 1 ]]; then
    clear
    gum_box "Installing zfs-dkms (fallback)"
    gum_spin "Building DKMS, this can take some time.." pacman -S --noconfirm zfs-dkms
    sleep 3
    gum_spin "Loading ZFS kernel module" modprobe zfs
    sleep 1

    if ! modinfo zfs &>/dev/null; then
        gum_box_sleep "CRITICAL ERROR: ZFS module could not be loaded.
Attempted: prebuilt zfs module, zfs-dkms.
Please contact Nordix or follow arch linux zfs guide to manually install zfs support in the ISO
"
        # press enter action
        echo ""
        clear
        gum_box "Do you want to reboot and try again?"
        if gum_confirm "Yes - reboot | No - poweroff"; then
            reboot
        else
            poweroff
        fi
    fi
fi

# Load the ZFS module (with one retry if first attempt fails)
gum_box "Loading ZFS module..."
if modprobe zfs 2>/dev/null; then
    gum_spin_sleep "ZFS module loaded successfully"
else
    gum_box_sleep "ZFS module failed to load – waiting 2 seconds and retrying..."

    if modprobe zfs 2>/dev/null; then
        gum_spin_sleep "ZFS module loaded successfully on second attempt"
    else
        gum_spin_sleep "WARNING: ZFS module could not be loaded even after retry."
        gum_box_sleep "Please contact Nordix or follow arch linux zfs guide
        to
        manually install zfs support in the ISO"
        # press enter action
        echo ""
        clear
        gum_box "Do you want to reboot and try again?"
        if gum_confirm "Yes - reboot | No - poweroff"; then
            reboot
        else
            poweroff
        fi
    fi
fi

gum_box_sleep "ZFS setup complete. Proceeding with Nordix installation..."
}
