# ask the user if they want to use Slog, Special, L2ARC

extra_vdevs() {
OPTIONS=(
"Guide/Help - Extra Vdevs"
"Select Extra Vdevs"
""
"Continue without Extra Vdevs"
)

while true; do
    clear
    gum_box "Extra Vdevs: Special vdevs (Metadata/small files device) - SLOG (log) - L2ARC (cache)"
    #  show the list of choices with gum_choose
    CHOICE=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")

    # handling ESC/no choise
    if [[ -z "$CHOICE" ]]; then
        clear
        gum_box_sleep "Please select an option!" && true
        continue
    fi
    if [[ "$CHOICE" == "Guide/Help - Extra Vdevs" ]]; then
        clear
        gum_box_sleep "Guidens is on the way!" && true
        # source info/zfs-info-advanced"
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
