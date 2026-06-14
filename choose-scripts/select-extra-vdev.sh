#!/bin/bash

EXTRA_VDEVS=$(gum choose --no-limit \
  "Special vdev (metadata/small blocks)" \
  "SLOG – Separate Intent Log" \
  "L2ARC – Level 2 Cache" \
  "None")