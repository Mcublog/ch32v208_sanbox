include(${PROJECT_SOURCE_DIR}/config/common.cmake)
include(${PROJECT_SOURCE_DIR}/config/desktop.cmake)

# Desktop-цель собирается host-компилятором (gcc), поэтому конфигурируется
# отдельным build-деревом:
#   cmake -S . -B build -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=Release

include_directories(${DESKTOP_INCLUDE_DIR})

file(GLOB_RECURSE DESKTOP_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
    ${APP_DIR}/*.c)

add_executable(${DESKTOP_TARGET} ${DESKTOP_SOURCES})
# Host GCC: не проверяем pthread кросс-компилятором при configure.
target_compile_options(${DESKTOP_TARGET} PRIVATE -pthread)
target_link_options(${DESKTOP_TARGET} PRIVATE -pthread)

target_include_directories(${DESKTOP_TARGET} PRIVATE
    ${APP_DIR}
)
