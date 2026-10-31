extra_vdevs() {

    BACKTITLE="Nordix Installer"
    OPTIONS=(
    "Guide/Help - Extra Vdevs"
    "Select Extra Vdevs"
    "Continue without Extra Vdevs"
    )



handle_interrupt() {
dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "Cannot Exit" \
    --msgbox "You cant exit here" 5 25
    exec "${BASH_SOURCE[0]}" "$@"
}
trap handle_interrupt INT TERM QUIT HUP

    while true; do

        menu_args=()
        i=1
        for opt in "${OPTIONS[@]}"; do
            [[ -z "$opt" ]] && continue
            menu_args+=("$i" "$opt")
            ((i++))
        done

        choice_idx=$(dialog --clear \
            --backtitle "$BACKTITLE" \
            --title "🐧Extra Vdevs🐧" \
            --no-cancel \
            --menu "Special Vdev:\n(Device for metadata and small files)\n SLOG:\n(Fast log device)\n L2ARC:\n(Extra cache device)" 15 60 3 "${menu_args[@]}" 2>&1 > /dev/tty)
        ret=$?


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
           # advance_zfs_info
            # source info/zfs-info-advanced
            #
            INFO_ADVANCED=$(cat "$SCRIPT_DIR/../info/zfs-info-advanced")
            dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "ZFS Info - Advanced" \
                --msgbox  "${INFO_ADVANCED}" 40 110
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
