#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"
ZPOOL_NAME="nordix"
SPECIAL_LAYOUT="$(cat "${CONFIG_DIR}/special-layout.conf")"
SPECIAL_DEVICES=${CONFIG_DIR}/selected-special-devices.conf
L2ARC_LAYOUT="$(cat "${CONFIG_DIR}/l2arc-layout.conf")"
L2ARC_DEVICES=${CONFIG_DIR}/selected-l2arc-devices.conf
SLOG_LAYOUT="$(cat "${CONFIG_DIR}/slog-layout.conf")"
SLOG_DEVICES=${CONFIG_DIR}/selected-slog-devices.conf

# if special layout is single or stripe

if [[ "${SPECIAL_LAYOUT}" == special-single || "${SPECIAL_LAYOUT}" == special-stripe || "${SPECIAL_LAYOUT}" == special-mirror ]]; then
  dev_args=()
  while IFS='=' read -r key val; do
    [[ $key =~ ^DRIVE_ ]] || continue
    dev_args+=("$val")
  done < "$SPECIAL_DEVICES"
  case "$SPECIAL_LAYOUT" in
    special-single)
      zpool add -f -o ashift=12 "$ZPOOL_NAME" special "${dev_args[0]}"
      ;;
    special-stripe)
      zpool add -f -o ashift=12 "$ZPOOL_NAME" special "${dev_args[@]}"
      ;;
    special-mirror)
      zpool add -f -o ashift=12 "$ZPOOL_NAME" special mirror "${dev_args[@]}"
      ;;
  esac
fi

if [[ "${L2ARC_LAYOUT}" == l2arc-single || "${L2ARC_LAYOUT}" == l2arc-stripe || "${L2ARC_LAYOUT}" == l2arc-mirror ]]; then
  dev_args=()
  while IFS='=' read -r key val; do
    [[ $key =~ ^DRIVE_ ]] || continue
    dev_args+=("$val")
  done < "$L2ARC_DEVICES"
  case "$L2ARC_LAYOUT" in
    l2arc-single)
      zpool add -f "$ZPOOL_NAME" cache "${dev_args[0]}"
      ;;
    l2arc-stripe)
      zpool add -f "$ZPOOL_NAME" cache "${dev_args[@]}"
      ;;
    l2arc-mirror)
      zpool add -f "$ZPOOL_NAME" cache mirror "${dev_args[@]}"
      ;;
  esac
fi

if [[ "${SLOG_LAYOUT}" == slog-single || "${SLOG_LAYOUT}" == slog-stripe || "${SLOG_LAYOUT}" == slog-mirror ]]; then
  dev_args=()
  while IFS='=' read -r key val; do
    [[ $key =~ ^DRIVE_ ]] || continue
    dev_args+=("$val")
  done < "$SLOG_DEVICES"
  case "$SLOG_LAYOUT" in
    slog-single)
      zpool add -f -o logbias=latency "$ZPOOL_NAME" log "${dev_args[0]}"
      ;;
    slog-stripe)
      zpool add -f -o logbias=latency "$ZPOOL_NAME" log "${dev_args[@]}"
      ;;
    slog-mirror)
      zpool add -f -o logbias=latency "$ZPOOL_NAME" log mirror "${dev_args[@]}"
      ;;
  esac
fi
