# ask the user if they want to use Slog, Special, L2ARC

extra_vdevs() {
    BACKTITLE="Nordix Installer"
    OPTIONS=(
    "Guide/Help - Extra Vdevs"
    "Select Extra Vdevs"
    ""
    "Continue without Extra Vdevs"
    )

    while true; do
        dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "Extra Vdevs" \
            --msgbox "Extra Vdevs: Special vdevs (Metadata/small files device) - SLOG (log) - L2ARC (cache)" 8 70

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            [[ -z "$opt" ]] && continue
            menu_args+=("$i" "$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear --backtitle "$BACKTITLE" --title "Extra Vdevs" \
            --stdout --menu "Press Enter to choose" 15 60 3 "${menu_args[@]}")
        ret=$?
        if [ $ret -ne 0 ] || [ -z "$choice_idx" ]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Extra Vdevs" --msgbox "Please select an option!" 6 50
            continue
        fi

        # Map index back to option text
        opt_index=0
        CHOICE=""
        for opt in "${OPTIONS[@]}"; do
            [[ -z "$opt" ]] && continue
            ((opt_index++))
            if [ "$opt_index" -eq "$choice_idx" ]; then
                CHOICE="$opt"
                break
            fi
        done

        if [[ "$CHOICE" == "Guide/Help - Extra Vdevs" ]]; then
            dialog --clear --backtitle "$BACKTITLE" --title "Help" --msgbox "Guidens is on the way!" 6 50
            # advance_zfs_info
            # source info/zfs-info-advanced
            advance_zfs_info
            continue
        fi

        if [[ "$CHOICE" == "Select Extra Vdevs" ]]; then
            EXTRA_VDEVS=yes
            break
        else
            EXTRA_VDEVS=no
            break
        fi
    done
}
