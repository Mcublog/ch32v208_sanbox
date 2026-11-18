#!/usr/bin/env bash
#
# Уменьшает размер сабмодуля SDK: оставляет только нужные каталоги.
# Уменьшает рабочую копию, но не размер уже скачанных Git-объектов.
#
# Вернуть полный checkout: git -C libs/third_party/wch/ch32v20x sparse-checkout disable
#
set -euo pipefail

SDK_DIR="${SDK_DIR:-libs/third_party/wch/ch32v20x}"

if [ ! -d "$SDK_DIR/.git" ] && [ ! -f "$SDK_DIR/.git" ]; then
    echo "error: $SDK_DIR не инициализирован. Выполните:" >&2
    echo "       git submodule update --init --recursive" >&2
    exit 1
fi

cd "$SDK_DIR"

git sparse-checkout init --cone
git sparse-checkout set \
    EVT/EXAM/SRC \
    EVT/EXAM/USB/USBD \
    EVT/EXAM/BLE/LIB \
    EVT/EXAM/BLE/HAL \
    EVT/EXAM/ETH/NetLib

echo "[sdk] sparse-checkout применён в $SDK_DIR"
du -sh .
