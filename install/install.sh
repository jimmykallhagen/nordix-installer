#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf

source $SCRIPT_DIR/../info/zfs-intro

zfs_intro


sleep 3
echo "test ok"
