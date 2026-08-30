#!/bin/bash
CHOICE="SSH
Exit
Docker - ZFS drivers"
CHOICE_FILTERED=$(printf "%s\n" "$CHOICE" | grep -vx "Exit" || true)
printf "%s\n" "$CHOICE_FILTERED"
