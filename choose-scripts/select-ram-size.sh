#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
INSTALL_DIR="$SCRIPT_DIR/../install"
unset ZPOOL RAM_SIZE DRIVER

MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_GB=$(( (MEM_KB + 1024 * 1024 / 2) / (1024 * 1024) ))

# Set base color for the installer
echo -ne '\e]10;${G_BASE_COLOR}\a'

# Confirm yes/no
gum_confirm() {
    local message="$1"
    gum confirm --padding="$G_PADDING" \
\
      --selected.align="$G_ALIGN" \
      --selected.border="$G_BOX_STYLE" \
      --selected.bold \
      --selected.background="$G_SELECTED_BACKGROUND_COLOR" \
      --selected.foreground="$GUM_SELECTED_TEXT_COLOR" \
\
      --unselected.align="$G_ALIGN" \
      --unselected.border="$G_BOX_STYLE" \
      --unselected.background="$G_UNSELECTED_BACKGROUND_COLOR" \
      --unselected.foreground="$LIGHT1_GRAY" \
      --unselected.faint \
\
      --prompt.padding="$G_BOX_PADDING" \
      --prompt.align="$BOX_ALIGN" \
      --prompt.border="$G_BOX_STYLE" \
      --prompt.foreground="$GUM_CONFIRMBOX_TEXT_COLOR" "$message"
}

# Choose Driver
OPTIONS=(
"RAM Size - 8GB"
"RAM Size - 16GB"
"RAM Size - 32GB"
"RAM Size - 64GB"
"RAM Size - 128GB"
)

while true; do
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum choose \
            --header.border="$G_BOX_STYLE" \
            --header.align="center" \
            --item.align="center" \
            --header.width=$HEADAER_WIDHT \
            --header.height=$HEADER_HEIGHT \
            --header.border-foreground="${G_BASE_COLOR}" \
            --header.foreground="$GUM_CONFIRMBOX_TEXT_COLOR" \
            --header.bold \
            --item.foreground="$LIGHT1_GRAY" \
            --cursor.foreground="$TEXT_COLOR_1" \
            --cursor.bold \
            --cursor="     ••❯ " \
            --header "Choose Your RAM Size - To Get The Correct RAM Configuration, Nordix detected: ${MEM_GB}GB RAM")


    case "$CHOICE" in
        "RAM Size - 8GB")    RAM_SIZE="8GB" ;;
        "RAM Size - 16GB")   RAM_SIZE="16GB" ;;
        "RAM Size - 32GB")   RAM_SIZE="32GB" ;;
        "RAM Size - 64GB")   RAM_SIZE="64GB" ;;
        "RAM Size - 128GB")  RAM_SIZE="128GB" ;;
    esac
    

# Confirm drivers to be installed
    gum_confirm "Is This The Correct RAM Size: $RAM_SIZE?" && break

done
echo "RAM_SIZE=\"$RAM_SIZE\"" >> "$INSTALL_DIR/install.conf"

# Set no color for the installer
echo -ne '\033[0m'