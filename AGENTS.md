# Как работать с песочницей

- `app/` — платформонезависимый код. Реализации платформенных интерфейсов
  находятся в `targets/ch32v208/src/` и `targets/desktop/mocks/`.
- `targets/ch32v208/board/main.c` инициализирует плату и вызывает `application()`.
  `ch32v208_fw` использует `app/application.c`; у каждого `hwtest_*` своя реализация.
- Для нового hwtest добавьте каталог в `hwtest/CMakeLists.txt` и вызовите
  `ch32v208_hwtest_app_v1(...)` по образцу `hwtest/gpio_toggle/`. После добавления
  исходников повторите CMake configure: списки файлов собираются через `GLOB_RECURSE`.
- Не редактируйте код в сабмодуле EVT. Параметры платы, обработчики прерываний и
  линкер относятся к `targets/ch32v208/`.
- `version.h` генерируется в build-каталоге из версии корневого `project()`.
- `Delay_Ms` из WCH SDK использует тот же SysTick, что `timer_irq_enable()`.
  Не вызывайте `delay_ms()` при активном периодическом SysTick.
- Для логирования задайте `LOG_MODULE_NAME` и `LOG_MODULE_LEVEL` перед включением
  `log_libs.h`. В SDI-цели лог может блокироваться без активного приёмника.
- MCU: `cmake -S . -B build-riscv` после `source scripts/env.sh`; WCH GCC
  выбирается по умолчанию. Host: `cmake -S . -B build -DCMAKE_C_COMPILER=gcc`,
  затем `cmake --build build --target ch32v208_desktop common_types_test` и
  `ctest --test-dir build`. Список целей общий, поэтому host-сборке нужен EVT
  на этапе configure, а `--target` ограничивает сборку host-целями.
