set(APP     app)
set(APP_FW  app_fw)

# region GLOBAL PROPERTIES
set(DESKTOP_TARGET_PATH             ${PROJECT_SOURCE_DIR}/targets/desktop)
set(CH32V208_TARGET_PATH            ${PROJECT_SOURCE_DIR}/targets/ch32v208)

set(APP_DIR     ${PROJECT_SOURCE_DIR}/app)
set(DEBUG_DIR   ${APP_DIR}/debug)
set(UTILS_DIR   ${APP_DIR}/utils)
set(IO_DIR      ${APP_DIR}/io)
set(LIBS_DIR    ${PROJECT_SOURCE_DIR}/libs)

set(APP_DIRS
    ${PROJECT_BINARY_DIR}/config
    ${APP_DIR}
    ${DEBUG_DIR}
    ${UTILS_DIR}
    ${IO_DIR}
)

set(COMMON_TYPES_TARGET common_types_test)
set(TEST_DIR            ${PROJECT_SOURCE_DIR}/test)

set(GCC_EMBEDDED    riscv32-wch-elf-gcc)
set(GCC_DESKTOP     gcc)
