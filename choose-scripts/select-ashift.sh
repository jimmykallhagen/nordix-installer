#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
INSTALL_DIR="$SCRIPT_DIR/../install"
unset ASHIFT_SIZE



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
"ashift - 12"
"ashift - 13"
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
            --header "Choose the correct ashift size - ashift 12 is 4k sectors, ashift 13 is 8k sectors, if you are unsure of what sectors you have on your drives then set 12 ")


    case "$CHOICE" in
        "ashift - 12")  ASHIFT_SIZE="12" ;;
        "ashift - 13")  ASHIFT_SIZE="13" ;;

    esac
    

# Confirm drivers to be installed
    gum_confirm "Is this the Correct ashift: $ASHIFT_SIZE?" && break

done
echo "ASHIFT_SIZE=\"$ASHIFT_SIZE\"" >> "$INSTALL_DIR/install.conf"

# Set no color for the installer
echo -ne '\033[0m'