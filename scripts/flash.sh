#!/usr/bin/env bash
#
# Прошивка через WCH-LinkE (MRS OpenOCD + wch-riscv.cfg).
#
#   source scripts/env.sh
#   scripts/flash.sh ch32v208_fw                  # цель из build-riscv
#   scripts/flash.sh hwtest_gpio_toggle
#   scripts/flash.sh build-riscv/output/ch32v208_fw.hex
#   BUILD_DIR=build scripts/flash.sh ch32v208_fw
#
set -euo pipefail

BUILD_DIR="${BUILD_DIR:-build-riscv}"
OPENOCD_BIN="${OPENOCD:-${RISCV_WCH_OPENOCD:-openocd}}"
OPENOCD_CFG="${OPENOCD_CFG:-${RISCV_WCH_OPENOCD_CFG:-}}"

usage() {
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

# Если конфиг OpenOCD не задан явно - ищем рядом с бинарником (MRS-раскладка)
if [ -z "$OPENOCD_CFG" ]; then
    openocd_path="$(command -v "$OPENOCD_BIN" || true)"
    if [ -n "$openocd_path" ]; then
        candidate="$(dirname "$(readlink -f "$openocd_path")")/wch-riscv.cfg"
        if [ -f "$candidate" ]; then
            OPENOCD_CFG="$candidate"
        fi
    fi
fi

if [ -z "$OPENOCD_CFG" ] || [ ! -f "$OPENOCD_CFG" ]; then
    echo "error: не найден wch-riscv.cfg." >&2
    echo "       выполните 'source scripts/env.sh' или задайте OPENOCD_CFG=<path>" >&2
    exit 1
fi

arg="$1"

case "$arg" in
    *.openocd)
        [ -f "$arg" ] || { echo "error: нет файла $arg" >&2; exit 1; }
        echo "[flash] $arg"
        exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" -f "$arg"
        ;;
    *.hex|*.elf)
        [ -f "$arg" ] || { echo "error: нет файла $arg" >&2; exit 1; }
        echo "[flash] $arg"
        exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" \
            -c "program {$arg} verify reset exit"
        ;;
    *)
        script="$BUILD_DIR/$arg.openocd"
        hex="$BUILD_DIR/output/$arg.hex"
        if [ -f "$script" ] && [ -f "$hex" ]; then
            echo "[flash] $script"
            exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" -f "$script"
        elif [ -f "$hex" ]; then
            echo "[flash] $hex"
            exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" \
                -c "program {$hex} verify reset exit"
        else
            echo "error: не найдено '$script' или '$hex'." >&2
            echo "       соберите цель: cmake --build $BUILD_DIR --target $arg" >&2
            exit 1
        fi
        ;;
esac
