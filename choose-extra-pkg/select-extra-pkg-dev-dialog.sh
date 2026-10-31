#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../config/extra-pkg-dev.conf"

clear

BACKTITLE="Nordix Installer"

handle_interrupt() {
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\Zb\Z1Cannot Exit" \
        --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

OPTIONS=(
    "Zed Editor - Featureful and powerful agent driven text editor, good alternative to VSCode."
    "Emacs - Classic, extensible editor with a built-in development environment."
    "Neovim - Powerful terminal-based text editor fork of Vim."
    "Helix - Vim like terminal-based text editor."
    "Sublime Text 4 - Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials."
)

while true; do
    dialog --clear \
        --backtitle "$BACKTITLE" \
        --colors --color-mode 2 \
        --title "\ZbExtra Packages" \
        --msgbox "Extra package selection: Development" 5 40

    menu_args=()
    i=1
    for opt in "${OPTIONS[@]}"; do
        [[ -z "$opt" ]] && continue
        menu_args+=("$i" "\Zb\Z1$opt" "OFF")
        ((i++))
    done

    selected_tags=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "\Zb\Z0Extra Packages" \
        --colors --color-mode 2 \
        --stdout --checklist "┌
\Zb\Z4 Visual editors and terminal-based editors" 0 125 5 "${menu_args[@]}")
    ret=$?

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
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Info" \
            --msgbox "Maybe next time" 5 40
        break
    fi

    confirm_text=$(printf "%s\n" "${selected_opts[@]}")
    if dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "\ZbConfirm Packages" \
            --yes-label "I want PKG" \
            --yesno "Confirm package(s):\n$confirm_text" 12 90 2>&1 >/dev/tty; then

        > "${OUTPUT_FILE}"
        for line in "${selected_opts[@]}"; do
            case "$line" in
                "Zed Editor - Featureful and powerful agent driven text editor, good alternative to VSCode.")                    echo "zed"     >> "${OUTPUT_FILE}" ;;
                "Emacs - Classic, extensible editor with a built-in development environment.")                                   echo "emacs"   >> "${OUTPUT_FILE}" ;;
                "Neovim - Powerful terminal-based text editor fork of Vim.")                                                     echo "neovim"  >> "${OUTPUT_FILE}" ;;
                "Helix - Vim like terminal-based text editor.")                                                                  echo "helix"   >> "${OUTPUT_FILE}" ;;
                "Sublime Text 4- Powerful text editor with a focus on speed and efficiency, proprietary offer unlimited free trials.") echo "sublime-text-4" >> "${OUTPUT_FILE}" ;;
            esac
        done
        break
    fi
done
