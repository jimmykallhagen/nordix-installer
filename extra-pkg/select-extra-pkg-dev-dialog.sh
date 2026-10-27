#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../gum-lib/gum.conf"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-dev.conf"
unset CHOICE

echo -ne "\e]10;${G_BASE_COLOR}\a"

BACKTITLE="Nordix Installer"

dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Looking for some development packages..." 6 50

OPTIONS=(
    "Zed Editor - Featureful and powerful agent driven text editor, good alternative to VSCode"
    "Bluefish - Editor aimed at web developers, supporting various programming languages."
    "Emacs - Classic, extensible editor with a built-in development environment"
    "Neovim - Powerful terminal-based text, editor fork of Vim"
    "Helix - Vim like terminal-based text editor"
    "Sublime text 4 - Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials"
    "Exit"
)

while true; do
    dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Extra package selection: Development" 6 50
    dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" --msgbox "Default editor - Visual: GNOME Text Editor. Terminal: Nano with syntax highlighting" 6 70

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear --backtitle "$BACKTITLE" --title "Extra Packages" \
        --stdout --checklist "Press SPACE to choose - Enter to confirm" 20 100 7 "${menu_args[@]}")
    ret=$?
    if [ $ret -ne 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    # Build option list without empties
    opt_list=()
    for o in "${OPTIONS[@]}"; do
        [[ -z "$o" ]] && continue
        opt_list+=("$o")
    done

    selected_opts=()
    exit_selected=false
    for tag in $selected_tags; do
        opt="${opt_list[$((tag-1))]}"
        if [[ "$opt" == "Exit" ]]; then
            exit_selected=true
        else
            selected_opts+=("$opt")
        fi
    done

    if $exit_selected || [ ${#selected_opts[@]} -eq 0 ]; then
        dialog --clear --backtitle "$BACKTITLE" --title "Info" --msgbox "Maybe next time" 6 40
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}" | head -c 200)
    if dialog --clear --backtitle "$BACKTITLE" --title "Confirm" --yesno "Confirm package(s):\n$confirm_text" 15 70 2>&1 >/dev/tty; then
        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Zed Editor - Featureful and powerful agent driven text editor, good alternative to VSCode") echo "PKG-W1=zed" >> "${OUTPUT_FILE}" ;;
                "Bluefish - Editor aimed at web developers, supporting various programming languages.") echo "PKG-W2=bluefish" >> "${OUTPUT_FILE}" ;;
                "Emacs - Classic, extensible editor with a built-in development environment") echo "PKG-W3=emacs" >> "${OUTPUT_FILE}" ;;
                "Neovim - Powerful terminal-based text, editor fork of Vim") echo "PKG-W4=neovim" >> "${OUTPUT_FILE}" ;;
                "Helix - Vim like terminal-based text editor") echo "PKG-W5=helix" >> "${OUTPUT_FILE}" ;;
                "Sublime text 4 - Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials") echo "PKG-W6=sublime" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
