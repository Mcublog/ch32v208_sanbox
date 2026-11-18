include(${PROJECT_SOURCE_DIR}/config/common.cmake)
include(${PROJECT_SOURCE_DIR}/config/desktop.cmake)

add_executable(${COMMON_TYPES_TARGET} EXCLUDE_FROM_ALL
    common_types_test.c
    ${APP_DIR}/common_type.c
)

# Include paths
target_include_directories(${COMMON_TYPES_TARGET} PRIVATE ${APP_DIRS})

# Added test
add_test(NAME ${COMMON_TYPES_TARGET}
         COMMAND ${COMMON_TYPES_TARGET})
