cmake_minimum_required(VERSION 3.22)

set_property(GLOBAL PROPERTY RULE_MESSAGES OFF)

# Setup compiler settings
set(CMAKE_TRY_COMPILE_TARGET_TYPE   "STATIC_LIBRARY")
set(CMAKE_C_STANDARD                11)
set(CMAKE_C_STANDARD_REQUIRED       ON)
set(CMAKE_C_EXTENSIONS              ON)
set(CMAKE_CXX_STANDARD              20)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            ON)

# Без явного выбора компилятора конфигурируем сборку под плату.
if(NOT CMAKE_TOOLCHAIN_FILE AND NOT CMAKE_C_COMPILER AND "$ENV{CC}" STREQUAL "")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/config/riscv-toolchain.cmake"
        CACHE FILEPATH "CMake toolchain file")
endif()

project(ch32v208_sandbox VERSION 0.1.0 LANGUAGES C CXX ASM)

include(config/common.cmake)
include(config/desktop.cmake)
include(config/mcu.cmake)
include(config/utils.cmake)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_subdirectory(config)

LOG_INFO("Version:.........." ${CMAKE_PROJECT_VERSION})
LOG_INFO("Host system:......" ${CMAKE_SYSTEM_NAME})
LOG_INFO("Build type:......." ${CMAKE_BUILD_TYPE})
LOG_INFO("Desktop target:..." ${DESKTOP_TARGET})
LOG_INFO("MCU target:......." ${CH32V208_TARGET})
LOG_INFO("CH32V20x SDK:....." ${CH32V20X_SDK_DIR} "(${CH32V20X_SDK_LAYOUT})")

# Как в ws407, список целей не зависит от выбранного компилятора.
# Host-цели собираются явно, чтобы сборка по умолчанию включала только MCU.
add_subdirectory(targets/ch32v208)
add_subdirectory(hwtest)
add_subdirectory(targets/desktop EXCLUDE_FROM_ALL)
enable_testing()
add_subdirectory(test)
