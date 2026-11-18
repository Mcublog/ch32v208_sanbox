include(${PROJECT_SOURCE_DIR}/hwtest/build.cmake)

file(GLOB_RECURSE CURRENT_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)

set(CURRENT_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# SDI printf включается для всей цели, чтобы debug.c собрался с нужным режимом.
# Требуется WCH-LinkE; смотреть вывод в MRS Studio / WCH-LinkUtility.
set(CURRENT_DEFINES
    "SDI_PRINT=SDI_PR_OPEN"
)

ch32v208_hwtest_app_v1("hwtest_sdi_printf" "${CURRENT_INCLUDES}" "${CURRENT_SOURCES}" "${CURRENT_DEFINES}")
