#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/../gum-lib/gum.conf
OUTPUT_FILE="$SCRIPT_DIR/../config/extra-pkg-dev.conf"
unset CHOICE

# Set base color for the installer
echo -ne "\e]10;${G_BASE_COLOR}\a"

clear
gum_sin_sleep "Looking for some development packages..."

while true; do
    clear
    gum_box "Extra package selection: Development"
    gum_box "Default editor - Visual: GNOME Text Editor. Terminal: Nano with syntax highlighting"
# Choose package
OPTIONS=(
    "Zed Editor - Featureful and powerful agent driven text editor, good alternative to VSCode"
    "Bluefish - Editor aimed at web developers, supporting various programming languages."
    "Emacs - Classic, extensible editor with a built-in development environment"
    "Vim - Terminal-based text editor with powerful features"
    "Neovim - Powerful terminal-based text, editor fork of Vim"
    "Helix - Vim like terminal-based text editor"
    "Kate - Editor from KDE"
    "Sublime text 4 - Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials"
    ""
    'Exit'
)

    # show the list of packages with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose_no_limit "Press Space to choose - Enter to confirm")

    # handling ESC/no choice
    if [[ -z "$CHOICE" ]]; then
        gum_box_sleep "Please select an option with Space!" && true
        continue
    fi

    # Filter out Exit from selection
    CHOICE_FILTERED=$(printf "%s\n" "$CHOICE" | grep -vx "Exit" || true)

    # If user only selected Exit or nothing remains after filtering
    if [[ -z "$CHOICE_FILTERED" ]]; then
        gum_box_sleep "Maybe next time"
        break
    fi

    # Confirm the selected package(s)
    if gum_confirm "Confirm package(s): ${CHOICE_FILTERED}?"; then
        # Clear output file before writing - overwrite each run
        > "${OUTPUT_FILE}"
        # Process each selected choice line by line
        while IFS= read -r line; do
            case "$line" in
                "Zed Editor - Featureful and high-performance agent driven text editor, strong alternative to VSCode")   echo "PKG-W1=zed" >> "${OUTPUT_FILE}"  ;;
                "Bluefish - Editor aimed at web developers, supporting various programming languages.")   echo "PKG-W2=bluefish" >> "${OUTPUT_FILE}"  ;;
                "Emacs - Classic, extensible editor with a built-in development environment")   echo "PKG-W3=emacs" >> "${OUTPUT_FILE}"  ;;
                "Vim - Terminal-based text editor with powerful features")   echo "PKG-W4=vim" >> "${OUTPUT_FILE}"  ;;
                "Neovim - Powerful terminal-based text, editor fork of Vim")   echo "PKG-W5=neovim" >> "${OUTPUT_FILE}"  ;;
                "Helix - Vim like terminal-based text editor")   echo "PKG-W6=helix" >> "${OUTPUT_FILE}"  ;;
                "Kate - Editor from KDE")   echo "PKG-W7=kate" >> "${OUTPUT_FILE}"  ;;
                "Sublime text 4 - Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials")   echo "PKG-W8=sublime" >> "${OUTPUT_FILE}"  ;;
          esac
        done <<< "$CHOICE_FILTERED"
        break
    fi
done
