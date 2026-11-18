# Общая сборка прошивки CH32V208: board-слой + app + SDK + startup.
#
# Функция используется как базовой прошивкой (targets/ch32v208), так и
# hwtest-примерами (hwtest/build.cmake).
#
# Аргументы:
#   target   - имя цели (ch32v208_fw, hwtest_gpio_toggle, ...)
#   includes - дополнительные include-пути цели
#   sources  - дополнительные исходники цели
#   defines  - дополнительные defines цели
#
include(${PROJECT_SOURCE_DIR}/config/common.cmake)
include(${PROJECT_SOURCE_DIR}/config/mcu.cmake)

function(ch32v208_app_v1 target includes sources defines)

    file(GLOB_RECURSE BOARD_SOURCES
        ${CH32V208_TARGET_PATH}/board/*.c
        ${CH32V208_TARGET_PATH}/src/*.c
    )

    file(GLOB_RECURSE APP_SOURCES ${APP_DIR}/*.c)

    # Базовая прошивка использует app/application.c, hwtest-примеры
    # предоставляют свою реализацию application().
    if(NOT "${target}" STREQUAL "${CH32V208_TARGET}")
        list(REMOVE_ITEM APP_SOURCES ${APP_DIR}/application.c)
    endif()

    # Build
    add_executable(${target}
        ${BOARD_SOURCES}
        ${APP_SOURCES}
        ${SDK_SOURCES}
        ${SDK_STARTUP_SOURCE}
        ${sources}
    )

    # Include paths
    target_include_directories(${target}
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${PROJECT_SOURCE_DIR}
        ${HAL_INCLUDE_DIRS}
        ${APP_DIRS}
        ${includes}
    )

    # Project symbols
    target_compile_definitions(${target} PRIVATE ${symbols_SYMB} ${defines})

    # Compiler options
    target_compile_options(${target} PRIVATE ${RISCV_WCH_ELF_FLAGS})

    # Linker options
    target_link_options(${target} PRIVATE ${CH32V208_LINKER_OPTION}
        "-Wl,-Map=${CMAKE_BINARY_DIR}/output/${target}.map")
    set_target_properties(${target} PROPERTIES LINK_DEPENDS "${CH32V208_LINKER_SCRIPT}")

    ch32v208_post_build(${target})
endfunction()
