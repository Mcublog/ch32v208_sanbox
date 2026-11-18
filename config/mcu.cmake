# region MCU GLOBAL PROPERTY
set(CH32V208_TARGET                 ch32v208_fw)

# region CH32V20x SDK
# SDK не хранится в этом репозитории как код, он подключён сабмодулем
# libs/third_party/wch/ch32v20x (официальный EVT WCH). Путь можно
# переопределить через -DCH32V20X_SDK_DIR=..., например на лёгкую сборку
# Community-PIO-CH32V/framework-wch-noneos-sdk (см. README).
set(CH32V20X_SDK_DIR
    "${PROJECT_SOURCE_DIR}/libs/third_party/wch/ch32v20x"
    CACHE PATH "Path to CH32V20x SDK (official EVT or NoneOS SDK)")

if(EXISTS ${CH32V20X_SDK_DIR}/EVT/EXAM/SRC/Peripheral/inc/ch32v20x.h)
    set(CH32V20X_SDK_LAYOUT "wch-evt")
    set(CH32V20X_SDK_SRC    ${CH32V20X_SDK_DIR}/EVT/EXAM/SRC)
    set(SDK_CORE_DIR        ${CH32V20X_SDK_SRC}/Core)
    set(SDK_DEBUG_DIR       ${CH32V20X_SDK_SRC}/Debug)
    set(SDK_PERIPH_INC_DIR  ${CH32V20X_SDK_SRC}/Peripheral/inc)
    set(SDK_PERIPH_SRC_DIR  ${CH32V20X_SDK_SRC}/Peripheral/src)
    set(SDK_STARTUP_FILE    ${CH32V20X_SDK_SRC}/Startup/startup_ch32v20x_D8W.S)
elseif(EXISTS ${CH32V20X_SDK_DIR}/Peripheral/ch32v20x/inc/ch32v20x.h)
    set(CH32V20X_SDK_LAYOUT "noneos-sdk")
    set(SDK_CORE_DIR        ${CH32V20X_SDK_DIR}/Core/ch32v20x)
    set(SDK_DEBUG_DIR       ${CH32V20X_SDK_DIR}/Debug/ch32v20x)
    set(SDK_PERIPH_INC_DIR  ${CH32V20X_SDK_DIR}/Peripheral/ch32v20x/inc)
    set(SDK_PERIPH_SRC_DIR  ${CH32V20X_SDK_DIR}/Peripheral/ch32v20x/src)
    set(SDK_STARTUP_FILE    ${CH32V20X_SDK_DIR}/Startup/startup_ch32v20x_D8W.S)
else()
    message(FATAL_ERROR
        "CH32V20x SDK not found in: ${CH32V20X_SDK_DIR}\n"
        "Инициализируйте сабмодуль:\n"
        "  git submodule update --init --recursive\n"
        "или укажите путь к SDK через -DCH32V20X_SDK_DIR=<path>.\n"
        "Варианты SDK:\n"
        "  * официальный EVT: https://github.com/openwch/ch32v20x\n"
        "  * лёгкий NoneOS SDK: https://github.com/Community-PIO-CH32V/framework-wch-noneos-sdk")
endif()

file(GLOB_RECURSE SDK_SOURCES
    ${SDK_CORE_DIR}/*.c
    ${SDK_DEBUG_DIR}/*.c
    ${SDK_PERIPH_SRC_DIR}/*.c
)

set(SDK_STARTUP_SOURCE ${SDK_STARTUP_FILE})

set(HAL_INCLUDE_DIRS
    ${SDK_CORE_DIR}
    ${SDK_DEBUG_DIR}
    ${SDK_PERIPH_INC_DIR}
    ${CH32V208_TARGET_PATH}/board
)
# endregion

# Put here your symbols (preprocessor defines), one in each line
# Encapsulate them with double quotes for safety purpose
set(symbols_SYMB
    "CH32V20x_D8W"              # CH32V208 (BLE 5.3, ETH 10M, 128K/64K)
    "CH32V208WBU6"              # CH32V208WBU6-EVT-R0
    "SYSCLK_FREQ_144MHz_HSE=144000000" # HSE 32 МГц -> 144 МГц
    "HSE_VALUE=32000000"
    "DEBUG=DEBUG_UART1"         # debug.c: printf -> USART1 (PA9/PA10)
    # SDI_PRINT задаётся конкретной целью (по умолчанию debug.h подставляет
    # SDI_PR_CLOSE); hwtest/sdi_printf переопределяет на SDI_PR_OPEN.
)

set(CPU_PARAMETERS
    -march=rv32imac_zicsr
    -mabi=ilp32
    -msmall-data-limit=8
    -mno-save-restore
    -mcmodel=medany)

set(RISCV_WCH_ELF_FLAGS
    ${CPU_PARAMETERS}
    -Wall
    -Wextra
    -Wno-unused-parameter
    -fdata-sections
    -ffunction-sections
    -fdiagnostics-color=always
    # Full debug configuration
    "$<$<CONFIG:Debug>:-Og;-g3>"
    # Release
    "$<$<CONFIG:Release>:-Os;-g>"
    # Release with DEBUG
    "$<$<CONFIG:RelWithDebInfo>:-Os;-g3>"
)

# Set linker script
set(CH32V208_LINKER_SCRIPT ${CH32V208_TARGET_PATH}/ld/ch32v208.ld)

set(CH32V208_LINKER_OPTION
    -T${CH32V208_LINKER_SCRIPT}
    ${CPU_PARAMETERS}
    -nostartfiles
    -specs=nano.specs
    -specs=nosys.specs
    # STDIO float formatting support (плюс к nano.specs)
    -u _printf_float
    -Wl,--start-group
    -lc
    -lm
    -Wl,--end-group
    -Wl,--gc-sections
    # Занятый и полный объём Flash/RAM, а также процент заполнения из linker script.
    -Wl,--print-memory-usage
)
# endregion
