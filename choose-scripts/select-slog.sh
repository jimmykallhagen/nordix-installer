#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
MASTER_LIST="${CONFIG_DIR}/drives.conf"
OUTPUT_FILE="$CONFIG_DIR/selected-slog-drives.conf"
OUTPUT_FILE_LAYOUT="${CONFIG_DIR}/slog-layout.conf"

source $SCRIPT_DIR/../gum-lib/gum.conf
source $CONFIG_DIR/drives.conf

clear
echo -ne "\e]10;${G_BASE_COLOR}\a"

gum_box 'ZFS SLOG - Separate Intent Log'

if gum_confirm 'Do you want to add a SLOG vdev to your zpool?'; then

gum_spin_timer "Proceeding with SLOG setup"

# Build list of already used drive by-ids
USED_IDS_FILE=$(mktemp)
cat "${CONFIG_DIR}/selected_boot_drive.conf" \
    "${CONFIG_DIR}/selected_drives.conf" \
    "${CONFIG_DIR}/selected-special-drives.conf" \
    "${CONFIG_DIR}/selected-l2arc-drives.conf" 2>/dev/null > "$USED_IDS_FILE"
USED_BYIDS=$(cut -d'=' -f2 "$USED_IDS_FILE" | cut -d' ' -f1 | grep -v '^$' | sort -u)

# Build available drives map excluding used ones
declare -A drive_map
options=()
count=1
while true; do
    var_name="DRIVE_${count}"
    drive_value="${!var_name}"
    [[ -z "$drive_value" ]] && break
    by_id="${drive_value%% *}"
    human_readable="${drive_value#* }"
    if echo "$USED_BYIDS" | grep -Fxq "$by_id"; then
        ((count++))
        continue
    fi
    drive_map["$human_readable"]="$by_id"
    options+=("$human_readable")
    ((count++))
done
rm -f "$USED_IDS_FILE"

if [[ ${#options[@]} -eq 0 ]]; then
    gum_box_sleep "No free drives left for SLOG"
    exit 1
fi

OPTIONS=(
"SLOG - Single    : 1 drive, no redundancy"
"SLOG - Stripe    : 2+ drives, maximum speed, no redundancy"
"SLOG - Mirror    : 2 drives, fault tolerant"
"Exit without SLOG"
)

gum_box "Choose Layout For SLOG"
while true; do
    clear
    gum_box "Choose Layout For SLOG"
    _SLOG=$(printf "%s\n" "${OPTIONS[@]}" | gum_choose "Press Enter to choose")
    [[ -z "$_SLOG" ]] && { gum_box_sleep "Please select a layout!" ; continue; }
    [[ "$_SLOG" == "Exit without SLOG" ]] && exit 0

    case "$_SLOG" in
        "SLOG - Single    : 1 drive, no redundancy") _SLOG="slog-single" ;;
        "SLOG - Stripe    : 2+ drives, maximum speed, no redundancy") _SLOG="slog-stripe" ;;
        "SLOG - Mirror    : 2 drives, fault tolerant") _SLOG="slog-mirror" ;;
    esac

    if gum_confirm "Confirm SLOG layout: ${_SLOG}?"; then
        echo "$_SLOG" > "${OUTPUT_FILE_LAYOUT}"
        break
    fi
done

get_min_max_drives() {
    case "$_SLOG" in
        "slog-single") echo "1 1" ;;
        "slog-stripe") echo "2 999" ;;
        "slog-mirror") echo "2 2" ;;
    esac
}
read MIN_DRIVES MAX_DRIVES <<< $(get_min_max_drives)
echo "Layout: $_SLOG requires minimum $MIN_DRIVES and maximum $MAX_DRIVES drives"

selected_slog_drives=""
while true; do
    clear
    gum_box "$_SLOG (requires $MIN_DRIVES-$MAX_DRIVES drives)"
    if [[ -z "$selected_slog_drives" ]]; then
        selected_slog_drives=$(printf "%s\n" "${options[@]}" | gum_choose_no_limit "Select Drives for SLOG")
    fi
    [[ -z "$selected_slog_drives" ]] && { gum_box_sleep "Please select at least one drive!"; continue; }

    drive_count=0
    while IFS= read -r line; do [[ -n "$line" ]] && ((drive_count++)); done <<< "$selected_slog_drives"

    if [[ $drive_count -lt $MIN_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG requires at least $MIN_DRIVES drives (you selected $drive_count)"
        selected_slog_drives=""
        continue
    fi
    if [[ $MAX_DRIVES != "999" && $drive_count -gt $MAX_DRIVES ]]; then
        gum_box_sleep "Error: $_SLOG allows maximum $MAX_DRIVES drives (you selected $drive_count)"
        selected_slog_drives=""
        continue
    fi

    if gum_confirm "Confirm selected $drive_count drives for SLOG?"; then
        break
    fi
    selected_slog_drives=""
done

> "${OUTPUT_FILE}"
disk_count=1
while IFS= read -r choice; do
    echo "DRIVE_${disk_count}=${drive_map[$choice]}" >> "$OUTPUT_FILE"
    ((disk_count++))
done <<< "$selected_slog_drives"

# Update remaining drives list for any further steps
grep -v -Ff <(cut -d'=' -f2 "${OUTPUT_FILE}") "${MASTER_LIST}" | \
awk -F'=' 'BEGIN { i=1 } { printf "DRIVE_%d=%s\n", i, $2; i++ }' > "${CONFIG_DIR}/device_list_slog.conf"

clear
gum_spin_timer 'SLOG configuration complete'
exit 0

else
clear
gum_spin_timer "SLOG can be added later"
exit 1
fi
