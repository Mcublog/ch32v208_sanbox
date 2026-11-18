function(_log_prefix text rest)
    string(JOIN " " _joined ${rest})
    message("${text}${_joined}")
endfunction()

function(LOG_INFO)
    _log_prefix("[INFO] " "${ARGV}")
endfunction()

function(LOG_DEBUG)
    _log_prefix("[DEBUG] " "${ARGV}")
endfunction()

function(LOG_WARN)
    _log_prefix("[WARN] " "${ARGV}")
endfunction()

#
# Пост-обработка прошивки: hex/bin + копия в build/output + скрипт прошивки.
#
function(ch32v208_post_build target)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/output")
    add_custom_command(TARGET ${target}
        POST_BUILD
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${target}>
        COMMAND ${CMAKE_OBJCOPY} ARGS -O ihex $<TARGET_FILE:${target}> ${target}.hex
        COMMAND ${CMAKE_OBJCOPY} ARGS -O binary $<TARGET_FILE:${target}> ${target}.bin
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/output
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE_DIR:${target}>/${target}.hex ${CMAKE_BINARY_DIR}/output/${target}.hex
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE_DIR:${target}>/${target}.bin ${CMAKE_BINARY_DIR}/output/${target}.bin
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:${target}> ${CMAKE_BINARY_DIR}/output/${target}.elf
        COMMENT "[${target}] Generate firmware artifacts"
        VERBATIM)

    configure_file(${PROJECT_SOURCE_DIR}/config/burn.openocd.in
        ${CMAKE_BINARY_DIR}/${target}.openocd
        @ONLY)
endfunction()

function(get_git_hash hash_value)
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if(GIT_HASH STREQUAL "")
        set(GIT_HASH "unknown")
    endif()
    set(${hash_value} ${GIT_HASH} PARENT_SCOPE)
endfunction()
