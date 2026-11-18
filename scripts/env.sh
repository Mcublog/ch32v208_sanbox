#!/usr/bin/env bash
#
# Окружение для сборки и отладки под CH32V208.
# Использование: source scripts/env.sh
#
# Тулчейн MounRiver Studio (GCC15: riscv32-wch-elf-*) + их OpenOCD (wlinke).
#
# GDB для отладки выбирается отдельно: riscv32-wch-elf-gdb из MRS GCC15 собран
# с поддержкой Python и требует libpython3.8.so.1.0, которой нет в современных
# дистрибутивах. Поэтому приоритет у системного gdb-multiarch (пакет
# gdb-multiarch), а GDB из MRS используется только как резерв.
#

MRS_TOOLCHAIN_ROOT="${MRS_TOOLCHAIN_ROOT:-$HOME/.local/share/MRS_Toolchain_Linux_X64_V240}"
MRS_GCC_DIR="$MRS_TOOLCHAIN_ROOT/Toolchain/RISC-V Embedded GCC15/bin"
MRS_GCC12_DIR="$MRS_TOOLCHAIN_ROOT/Toolchain/RISC-V Embedded GCC12/bin"
MRS_OPENOCD_DIR="$MRS_TOOLCHAIN_ROOT/OpenOCD/OpenOCD/bin"

# Возвращает первый GDB из списка кандидатов, который действительно запускается.
# Проверяем запуск, а не только наличие файла: бинарник может не найти
# разделяемые библиотеки (см. libpython3.8 у MRS GCC15).
_ch32v208_pick_gdb() {
    local candidate
    for candidate in "$@"; do
        [ -n "$candidate" ] && [ -x "$candidate" ] || continue
        if "$candidate" --version >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

if [ -d "$MRS_GCC_DIR" ]; then
    case ":$PATH:" in
        *":$MRS_GCC_DIR:"*) ;;
        *) export PATH="$MRS_GCC_DIR:$PATH" ;;
    esac
    export RISCV_WCH_OPENOCD="$MRS_OPENOCD_DIR/openocd"
    export RISCV_WCH_OPENOCD_CFG="$MRS_OPENOCD_DIR/wch-riscv.cfg"
else
    echo "[warn] MRS GCC15 не найден: $MRS_GCC_DIR" >&2
    echo "[warn] задайте MRS_TOOLCHAIN_ROOT или добавьте riscv32-wch-elf-gcc в PATH" >&2
fi

# Отладочный GDB: явно заданный MRS_GCC_DEBUGGER не перезаписываем.
if [ -z "${MRS_GCC_DEBUGGER:-}" ]; then
    MRS_GCC_DEBUGGER="$(_ch32v208_pick_gdb \
        "$(command -v gdb-multiarch || true)" \
        "$MRS_GCC_DIR/riscv32-wch-elf-gdb" \
        "$MRS_GCC12_DIR/riscv32-wch-elf-gdb" || true)"
    if [ -n "$MRS_GCC_DEBUGGER" ]; then
        export MRS_GCC_DEBUGGER
    else
        echo "[warn] GDB для отладки не найден: установите gdb-multiarch" >&2
    fi
fi

if [ -n "${RISCV_WCH_OPENOCD:-}" ] && [ -x "${RISCV_WCH_OPENOCD:-}" ]; then
    export OPENOCD="$RISCV_WCH_OPENOCD"
    export OPENOCD_CFG="$RISCV_WCH_OPENOCD_CFG"
fi

echo "[env] riscv32-wch-elf-gcc: $(command -v riscv32-wch-elf-gcc || echo 'not found')"
echo "[env] gdb:                 ${MRS_GCC_DEBUGGER:-not found}"
echo "[env] openocd:             $(command -v "${OPENOCD:-openocd}" || echo 'not found')"
echo "[env] wch-riscv.cfg:       ${OPENOCD_CFG:-not set}"
