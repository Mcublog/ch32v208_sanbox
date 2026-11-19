# CH32V208 sandbox

CMake-песочница для платы **CH32V208WBU6-EVT-R0** по образцу `ws407_sandbox`.
Прошивки лежат в `targets/ch32v208/` и `hwtest/`, общий код — в `app/`.
По умолчанию CMake выбирает RISC-V тулчейн. Все цели объявляются в обоих
каталогах сборки, как в `ws407_sandbox`, но для desktop и unit-тестов
используется отдельный каталог с явно выбранным host GCC.

## Сборка прошивок (Linux)

Нужны Git, CMake 3.22+, MounRiver Studio Toolchain v240 (RISC-V Embedded GCC 15)
и, для прошивки, WCH-LinkE в режиме RISC-V. `scripts/env.sh` ищет тулчейн в
`~/.local/share/MRS_Toolchain_Linux_X64_V240`; если он установлен в другом
месте, задайте `MRS_TOOLCHAIN_ROOT` перед выполнением `source`.

```sh
git submodule update --init --recursive
source scripts/env.sh
cmake -S . -B build-riscv -DCMAKE_BUILD_TYPE=Debug
cmake --build build-riscv --parallel
```

| Цель | Что проверяет |
| --- | --- |
| `ch32v208_fw` | Базовый запуск: мигание LED и лог через USART1. |
| `hwtest_gpio_toggle` | Мигание LED от периодического прерывания SysTick, лог через USART1. |
| `hwtest_sdi_printf` | Экспериментальный лог через отладочный интерфейс WCH-LinkE, без UART. |

Файлы `.elf`, `.hex`, `.bin` и `.map` находятся в `build-riscv/output/`.
При каждой линковке MCU-цели выводятся занятый и полный объём Flash/RAM
и процент заполнения.
Линкер рассчитан на 128 КиБ Flash и 64 КиБ RAM; сборка не меняет
конфигурацию памяти микроконтроллера.

## Прошивка и логи

### Подключение WCH-LinkE

Проба подключается к разъёму `P6 LINK` (2×5) платы. Распиновка `P6`:

| Пин | Сигнал | Пин | Сигнал |
| --- | --- | --- | --- |
| 1 | `PA14` / SWCLK | 2 | `PA9` / USART1 TX |
| 3 | `PA13` / SWDIO | 4 | `PA10` / USART1 RX |
| 5 | `GND` | 6 | `GND` |
| 7 | `VDD` (3,3 В) | 8 | `VDD` (3,3 В) |
| 9 | `+5V` | 10 | `+5V` |

Минимальный набор для прошивки — три провода:

| WCH-LinkE | Контакт P6 | Пин MCU |
| --- | --- | --- |
| `SWCLK` (`TCK`) | 1 | `PA14` |
| `SWDIO` (`TMS`) | 3 | `PA13` |
| `GND` | 5 или 6 | `GND` |

Питание `3V3` с пробы на контакты 7/8 подавайте только тогда, когда плата не
получает питание из другого источника (USB или внешний блок питания), иначе
два источника будут работать друг против друга. Линия `NRST` на `P6` не
выведена и для прошивки не нужна: OpenOCD сбрасывает MCU программно.

Для мигания подключите LED1 к PA0 через гребёнку платы (PA0 — выбор проекта,
а не фиксированная разводка). Для UART-лога подключите PA9 (USART1 TX, контакт
2 разъёма `P6`) к RX адаптера USB–UART с логикой 3,3 В и соедините земли.
Параметры порта: **115200, 8N1**.

### Режим пробы и прошивка

`scripts/flash.sh` запускает OpenOCD из MounRiver с `wch-riscv.cfg`
(`adapter driver wlinke`, `transport select sdi`), поэтому WCH-LinkE должен
быть в режиме **RISC-V**, а не ARM/DAP. Режим виден по USB PID:

```sh
lsusb -d 1a86:8010        # режим RISC-V, всё в порядке
lsusb -d 1a86:8012        # режим DAP: OpenOCD его не увидит
```

Если проба в режиме DAP, OpenOCD выводит `Error: open failed` и
`Error: No Valid JTAG Interface Configured`. Переключите режим одним из
способов и проверьте `lsusb` снова:

- кнопка на корпусе WCH-LinkE — зажать её при подключении USB;
- WCH-LinkUtility (Windows): «Set WCH-Link Mode → RISC-V»;
- `wlink mode-switch --rv` — утилита [`wlink`](https://github.com/ch32-rs/wlink)
  для Linux, ставится через `cargo install --git https://github.com/ch32-rs/wlink`.

Пользователь должен иметь доступ к USB-устройству — через udev-правило или
группу `plugdev`. Проверить права можно командой `getfacl /dev/bus/usb/001/00N`.

```sh
scripts/flash.sh ch32v208_fw
# Или передайте .hex/.elf напрямую:
scripts/flash.sh build-riscv/output/hwtest_gpio_toggle.elf
```

Для другой установки OpenOCD можно задать `OPENOCD` и `OPENOCD_CFG`.

### Отладка в VS Code

Конфигурация `Debug: MCU (WCH-LinkE)` берёт GDB из переменной
`MRS_GCC_DEBUGGER`, которую выставляет `scripts/env.sh`, и цепляется к
gdb-серверу OpenOCD на `localhost:3333`. Перед запуском VS Code выполняет
фоновую задачу `OpenOCD: gdb server`, которая запускает
`scripts/gdb_server.sh`. Запустите VS Code из оболочки после
`source scripts/env.sh` и выберите конфигурацию.

Сервер можно поднять и вручную — с прошивкой цели или без неё:

```sh
scripts/gdb_server.sh                                        # только gdb-сервер
scripts/gdb_server.sh --flash build-riscv/hwtest/gpio_toggle/hwtest_gpio_toggle.openocd
scripts/gdb_server.sh --stop                                 # остановить сервер
```

Имя MCU-цели вручную не вводится: `Debug: MCU (WCH-LinkE)` и задача
`Flash: MCU target` берут путь из активной launch target CMake Tools
(`${command:cmake.launchTargetPath}`), как в `ws407_sandbox`. Поэтому в
статус-баре CMake Tools должен быть выбран build-каталог `build-riscv`
и нужная цель (например, `hwtest_gpio_toggle`). При активном host-каталоге
`build` эти конфигурации будут работать с host-целью, а не с прошивкой.

Перед отладкой плата прошивается автоматически той же целью, ELF которой
загрузит отладчик: задача `OpenOCD: gdb server` вызывает
`scripts/gdb_server.sh --flash ${command:cmake.launchTargetPath}.openocd`.
Скрипт останавливает ранее запущенный OpenOCD (WCH-LinkE доступен только
одному процессу, иначе прошивка падает с `claim interface failed`), прошивает
цель через `scripts/flash.sh` с `verify` и затем поднимает gdb-сервер. Поэтому
после пересборки или смены цели достаточно нажать Debug — прошивка в чипе
не разойдётся с загруженным ELF.

Отладчик сбрасывает MCU программно через SDI (`reset_config none separate`
в `wch-riscv.cfg`): `reset halt` выполняется самим OpenOCD при старте сервера,
поэтому PC гарантированно стоит на `_start`, а `cppdbg` со `stopAtEntry`
останавливается в `main`. Команда `monitor reset halt` в `launch.json`
оставлена как best effort: `setupCommands` выполняются до подключения к
удалённой цели и на этом этапе gdb отвечает `"monitor" command not supported`,
поэтому у неё стоит `ignoreFailures`. Линия `NRST` на `P6` не выведена и не
нужна, отдельный провод RST подключать не требуется.

`scripts/gdb_server.sh` не поднимает второй экземпляр OpenOCD, если порт 3333
уже слушается (сервер остался после предыдущей сессии отладки): в этом случае
он сообщает о готовности и завершается с кодом 0, а VS Code переиспользует
живой сервер. Без этой проверки OpenOCD падал бы с
`couldn't bind ... to socket`, а VS Code показывал бы
`The preLaunchTask 'OpenOCD: gdb server' terminated with exit code` с кнопкой
**Debug Anyway** — и отладка стартовала бы только после её нажатия.
Остановить оставшийся сервер вручную можно задачей `OpenOCD: stop gdb server`.

GDB из MRS GCC15 собран с поддержкой Python и требует `libpython3.8.so.1.0`,
которой нет в современных дистрибутивах (в Ubuntu 24.04+/26.04 её нет в
репозитории), поэтому отладка падает с
`error while loading shared libraries: libpython3.8.so.1.0`. `env.sh` выбирает
первый рабочий GDB в таком порядке:

1. системный `gdb-multiarch` (рекомендуется: `sudo apt install gdb-multiarch`);
2. `riscv32-wch-elf-gdb` из MRS GCC15;
3. `riscv-wch-elf-gdb` из MRS GCC12 (xPack GDB без Python).

Явно заданный `MRS_GCC_DEBUGGER` не перезаписывается — можно указать любой
другой GDB с поддержкой RISC-V. Проверить выбор и работу GDB:

```sh
source scripts/env.sh
echo "$MRS_GCC_DEBUGGER"
"$MRS_GCC_DEBUGGER" -batch -ex "info files" build-riscv/output/hwtest_gpio_toggle.elf
```

Предупреждение OpenOCD `Prefer GDB command "target extended-remote :3333"
instead of "target remote :3333"` безвредно: `cppdbg` подключается через
`target remote`, а прошивка выполняется задачей отладки через
`scripts/flash.sh` (при необходимости сервер можно поднять и без прошивки:
`scripts/gdb_server.sh`).

### Лог через SDI

`hwtest_sdi_printf` — аналог RTT по назначению: использует протокол WCH SDI
printf и передаёт лог по тому же двухпроводному интерфейсу, что и прошивка,
поэтому отдельный UART не нужен. Собирайте цель в `Debug`. Прошивка проверена,
а для приёма логов на Linux нужен SDI-совместимый приёмник, например `wlink`:

```sh
wlink flash --enable-sdi-print --watch-serial build-riscv/output/hwtest_sdi_printf.elf
```

Без активного приёмника логов реализация WCH может заблокировать `printf`,
поэтому не запускайте эту прошивку «в пустоту». В отладчике это выглядит как
«зависание» сразу после старта: `_write` крутится в
`while (*DEBUG_DATA0_ADDRESS != 0)`, PC стоит на месте, а LED не мигает.
Для проверки LED и SysTick используйте `hwtest_gpio_toggle` (лог через USART1),
а `hwtest_sdi_printf` отлаживайте только вместе с приёмником. SDI print
в `wlink` требует прошивку пробы 2.10+. См. также штатный пример
[`SDI_Printf`](https://github.com/openwch/ch32v20x/tree/main/EVT/EXAM/SDI_Printf)
и WCH-LinkUtility.

## SDK и справочные материалы

- **По умолчанию:** полный официальный [WCH CH32V20x EVT](https://github.com/openwch/ch32v20x)
  в `libs/third_party/wch/ch32v20x`, зафиксированный коммитом сабмодуля.
  Проект использует SPL и startup D8W из `EVT/EXAM/SRC`. Примеры BLE, Ethernet
  и USB в EVT доступны как справочный код и не входят в текущие прошивки.
- **Альтернатива:** [Community-PIO NoneOS SDK](https://github.com/Community-PIO-CH32V/framework-wch-noneos-sdk)
  — компактная перепаковка WCH SPL, не официальный полный EVT. При необходимости
  передайте `-DCH32V20X_SDK_DIR=/путь/к/sdk` при конфигурации отдельного build-каталога.
  PlatformIO для нашей сборки не нужен. CMake распознаёт обе раскладки.
- **Инструменты и документация:** [страница CH32V208 у WCH](https://www.wch-ic.com/products/CH32V208.html),
  [OpenOCD WCH](https://github.com/openwch/openocd_wch) и
  [платформа CH32V для PlatformIO](https://github.com/Community-PIO-CH32V/platform-ch32v).
  Перед распространением кода WCH проверьте условия в заголовках исходников.

Опционально `scripts/sdk_sparse.sh` сокращает рабочую копию сабмодуля,
но не объём уже скачанных Git-объектов.

## Desktop и тесты

```sh
git submodule update --init --recursive
cmake -S . -B build -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=Release
cmake --build build --target ch32v208_desktop common_types_test --parallel
ctest --test-dir build --output-on-failure
```

Desktop-программа: `build/targets/desktop/ch32v208_desktop`.
В host-каталоге всегда указывайте `--target`: обычная сборка попытается
собрать MCU-цели с RISC-V флагами. EVT нужен для конфигурации общего списка
целей, но не компилируется для desktop и тестов. GitHub Actions запускает
только host-тесты. Не переключайте компилятор в уже настроенном каталоге.
