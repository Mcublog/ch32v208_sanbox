#!/usr/bin/env bash
#
# GDB-сервер OpenOCD для отладки из VS Code.
#
#   source scripts/env.sh
#   scripts/gdb_server.sh                       # запустить сервер (или переиспользовать живой)
#   scripts/gdb_server.sh --stop                # остановить запущенный сервер
#   scripts/gdb_server.sh --flash <path.openocd>  # стоп -> прошивка -> сервер
#
# Запускается фоновой задачей VS Code "OpenOCD: gdb server". Если порт GDB уже
# слушается (сервер остался после предыдущей сессии отладки), второй экземпляр
# не поднимается: скрипт сообщает о готовности и выходит с кодом 0, а VS Code
# подключается к живому серверу. Иначе OpenOCD падал бы с ошибкой
# "couldn't bind ... to socket", задача завершалась бы с ненулевым кодом и
# VS Code показывал бы "preLaunchTask terminated with exit code" с кнопкой
# "Debug Anyway".
#
# --flash <path.openocd> используется задачей отладки: WCH-LinkE доступен
# только одному процессу, поэтому сначала останавливается уже запущенный
# OpenOCD, затем скрипт прошивки (с verify) заливает ту же цель, что и
# отлаживаемый ELF, и только после этого поднимается gdb-сервер. Так прошивка
# в чипе не может разойтись с ELF, который загружает отладчик.
#
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

GDB_HOST="${GDB_HOST:-127.0.0.1}"
GDB_PORT="${GDB_PORT:-3333}"
OPENOCD_BIN="${OPENOCD:-${RISCV_WCH_OPENOCD:-openocd}}"
OPENOCD_CFG="${OPENOCD_CFG:-${RISCV_WCH_OPENOCD_CFG:-}}"

FLASH_SCRIPT=""
STOP_ONLY=0

usage() {
    sed -n '3,8p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        --stop)
            STOP_ONLY=1
            shift
            ;;
        --flash)
            if [ $# -lt 2 ] || [ -z "$2" ]; then
                echo "error: --flash требует путь к *.openocd" >&2
                usage >&2
                exit 1
            fi
            FLASH_SCRIPT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "error: неизвестный аргумент '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# Остановка сервера, запущенного этим репозиторием: ищем только процессы
# openocd, в командной строке которых есть наш конфиг (wch-riscv.cfg).
stop_server() {
    local pids=""
    local pid
    local cmdline
    local alive

    for pid in $(pgrep -x openocd || true); do
        cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
        case "$cmdline" in
            *wch-riscv.cfg*) pids="$pids $pid" ;;
        esac
    done

    if [ -z "$pids" ]; then
        echo "[gdb-server] запущенный OpenOCD не найден"
        return 0
    fi

    # shellcheck disable=SC2086
    kill $pids 2>/dev/null || true

    # Ждём завершения, иначе WCH-LinkE ещё занят и прошивка упадёт с
    # "claim interface failed".
    for _ in $(seq 1 50); do
        alive=0
        for pid in $pids; do
            if kill -0 "$pid" 2>/dev/null; then
                alive=1
            fi
        done
        if [ "$alive" -eq 0 ]; then
            break
        fi
        sleep 0.1
    done

    echo "[gdb-server] остановлен OpenOCD:$pids"
}

if [ "$STOP_ONLY" -eq 1 ]; then
    stop_server
    exit 0
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

if [ -n "$FLASH_SCRIPT" ]; then
    if [ ! -f "$FLASH_SCRIPT" ]; then
        echo "error: нет файла '$FLASH_SCRIPT'." >&2
        echo "       соберите MCU-цель: cmake --build build-riscv --target <target>" >&2
        exit 1
    fi

    # Прошивка занимает WCH-LinkE эксклюзивно - сервер должен быть остановлен.
    stop_server
    echo "[gdb-server] прошивка: $FLASH_SCRIPT"
    OPENOCD="$OPENOCD_BIN" OPENOCD_CFG="$OPENOCD_CFG" \
        "$SCRIPT_DIR/flash.sh" "$FLASH_SCRIPT"
fi

port_open() {
    (exec 3<>"/dev/tcp/$GDB_HOST/$GDB_PORT") >/dev/null 2>&1
}

if port_open; then
    echo "[gdb-server] порт $GDB_PORT уже слушается: переиспользуем запущенный OpenOCD"
else
    echo "[gdb-server] $OPENOCD_BIN -f $OPENOCD_CFG -c init -c 'reset halt'"
    # reset halt до подключения GDB: cppdbg выполняет setupCommands раньше,
    # чем соединяется с удалённой целью, поэтому monitor reset halt из
    # launch.json там не работает. Так цель гарантированно стартует с _start.
    # exec: OpenOCD становится процессом задачи, лог идёт в терминал VS Code.
    exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" -c init -c "reset halt"
fi

# Строка ниже нужна problemMatcher'у задачи: по ней VS Code понимает, что
# gdb-сервер готов принимать подключение.
echo "Listening on port $GDB_PORT for gdb connections"
