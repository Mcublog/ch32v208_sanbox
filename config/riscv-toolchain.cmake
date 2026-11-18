# Кросс-тулчейн для CH32V208 (RISC-V, WCH).
#
# Используется MounRiver Studio Toolchain (GCC15):
#   <MRS>/Toolchain/RISC-V Embedded GCC15/bin/riscv32-wch-elf-*
# Перед конфигурацией выполните: source scripts/env.sh
#
# Корневой CMakeLists.txt выбирает этот файл по умолчанию.
#   cmake -S . -B build-riscv -DCMAKE_BUILD_TYPE=Debug
#
set(CMAKE_SYSTEM_NAME      Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

set(RISCV_TOOLCHAIN_PREFIX "riscv32-wch-elf-" CACHE STRING
    "Prefix of the RISC-V toolchain (riscv32-wch-elf-, riscv-none-elf-, ...)")

set(CMAKE_C_COMPILER   ${RISCV_TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${RISCV_TOOLCHAIN_PREFIX}g++)
set(CMAKE_ASM_COMPILER ${RISCV_TOOLCHAIN_PREFIX}gcc)
set(CMAKE_OBJCOPY      ${RISCV_TOOLCHAIN_PREFIX}objcopy CACHE FILEPATH "")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Не искать host-библиотеки/заголовки в sysroot тулчейна
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
