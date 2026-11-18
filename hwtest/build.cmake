include(${PROJECT_SOURCE_DIR}/targets/ch32v208/build.cmake)
include(${PROJECT_SOURCE_DIR}/config/utils.cmake)
include(${PROJECT_SOURCE_DIR}/libs/hw/list.cmake)
include(${PROJECT_SOURCE_DIR}/libs/third_party/hw/list.cmake)

#
# Прошивка-пример: hwtest_<name>
#
# Аргументы: target includes sources defines
# Пример использования - hwtest/gpio_toggle/CMakeLists.txt.
#
function(ch32v208_hwtest_app_v1 target includes sources defines)
    ch32v208_app_v1(${target} "${includes}" "${sources}" "${defines}")
endfunction()
