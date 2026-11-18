include(${PROJECT_SOURCE_DIR}/hwtest/build.cmake)

file(GLOB_RECURSE CURRENT_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
)

set(CURRENT_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}
)

ch32v208_hwtest_app_v1("hwtest_gpio_toggle" "${CURRENT_INCLUDES}" "${CURRENT_SOURCES}" "")
