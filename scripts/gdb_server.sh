#!/usr/bin/env bash
#
# GDB-сервер OpenOCD для отладки из VS Code.
#
#   source scripts/env.sh
#   scripts/gdb_server.sh            # запустить сервер (или переиспользовать живой)
#   scripts/gdb_server.sh --stop     # остановить запущенный сервер
#
# Запускается фоновой задачей VS Code "OpenOCD: gdb server". Если порт GDB уже
# слушается (сервер остался после предыдущей сессии отладки), второй экземпляр
# не поднимается: скрипт сообщает о готовности и выходит с кодом 0, а VS Code
# подключается к живому серверу. Иначе OpenOCD падал бы с ошибкой
# "couldn't bind ... to socket", задача завершалась бы с ненулевым кодом и
# VS Code показывал бы "preLaunchTask terminated with exit code" с кнопкой
# "Debug Anyway".
#
set -euo pipefail

GDB_HOST="${GDB_HOST:-127.0.0.1}"
GDB_PORT="${GDB_PORT:-3333}"
OPENOCD_BIN="${OPENOCD:-${RISCV_WCH_OPENOCD:-openocd}}"
OPENOCD_CFG="${OPENOCD_CFG:-${RISCV_WCH_OPENOCD_CFG:-}}"

# Остановка сервера, запущенного этим репозиторием: ищем только процессы
# openocd, в командной строке которых есть наш конфиг (wch-riscv.cfg).
if [ "${1:-}" = "--stop" ]; then
    pids=""
    for pid in $(pgrep -x openocd || true); do
        cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
        case "$cmdline" in
            *wch-riscv.cfg*) pids="$pids $pid" ;;
        esac
    done

    if [ -z "$pids" ]; then
        echo "[gdb-server] запущенный OpenOCD не найден"
        exit 0
    fi

    # shellcheck disable=SC2086
    kill $pids 2>/dev/null || true
    echo "[gdb-server] остановлен OpenOCD:$pids"
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

port_open() {
    (exec 3<>"/dev/tcp/$GDB_HOST/$GDB_PORT") >/dev/null 2>&1
}

if port_open; then
    echo "[gdb-server] порт $GDB_PORT уже слушается: переиспользуем запущенный OpenOCD"
else
    echo "[gdb-server] $OPENOCD_BIN -f $OPENOCD_CFG"
    # exec: OpenOCD становится процессом задачи, лог идёт в терминал VS Code.
    exec "$OPENOCD_BIN" -f "$OPENOCD_CFG" -c init
fi

# Строка ниже нужна problemMatcher'у задачи: по ней VS Code понимает, что
# gdb-сервер готов принимать подключение.
echo "Listening on port $GDB_PORT for gdb connections"
