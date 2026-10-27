#!/bin/bash

BACKTITLE="Min Distro - GPU-val"

choose_gpu() {
    local OPTIONS=(
        'AMD - amdgpu'
        'Intel - i915'
        'NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)'
        'Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)'
        'Laptop: NVIDIA - nvidia-open (Turing/Ampere/Ada/Blackwell: 16xx,20xx,30xx,40xx,50xx)'
        'Laptop: Legacy NVIDIA - nvidia-580xx (Maxwell/Pascal/Volta: GTX900,10xx,Titan)'
    )

    local args=()
    local i
    for i in "${!OPTIONS[@]}"; do
        args+=("$((i+1))" "${OPTIONS[$i]}")
    done

    CHOICE=$(dialog --clear \
        --backtitle "$BACKTITLE" \
        --title "GPU-driver" \
        --menu "Välj GPU-driver:" 20 80 6 \
        "${args[@]}" \
        2>&1 > /dev/tty)

    if [ $? -ne 0 ]; then
        echo "Avbrutet." >&2
        return 1
    fi

    echo "Du valde nummer: $CHOICE"
    # Hämta själva texten:
    # echo "Text: ${OPTIONS[$((CHOICE-1))]}"
}

choose_gpu
