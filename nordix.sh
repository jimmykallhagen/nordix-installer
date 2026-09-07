#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/gum-lib/gum.conf

INSTALL_ZFS_ARCHISO="$SCRIPT_DIR/info/zfs-module.sh"
# Set base color
echo -ne "\e]10;${G_BASE_COLOR}\a"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
source $SCRIPT_DIR/../info/zfs-intro
# Set base color
echo -ne "\e]10;${G_BASE_COLOR}\a"

# show intro
zfs_intro
