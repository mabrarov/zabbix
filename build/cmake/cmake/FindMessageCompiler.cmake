cmake_minimum_required(VERSION 3.0)

find_package(PkgConfig QUIET)

function(_message_compiler_find)
    if(WIN_SDK_ROOT)
        list(APPEND win_sdk_roots "${WIN_SDK_ROOT}")
    else()
        set(win_sdk_root_found FALSE)
        set(found_win_sdk_root )
        if(NOT "$ENV{WIN_SDK_ROOT}" STREQUAL "")
            # Fallback to WIN_SDK_ROOT enviornment variable
            set(found_win_sdk_root "$ENV{WIN_SDK_ROOT}")
            set(win_sdk_root_found TRUE)
        else()
            # Try to find location of the latest Windows SDK in Windows Registry
            get_filename_component(found_win_sdk_root
                "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]"
                REALPATH)
            if(NOT "${found_win_sdk_root}" STREQUAL "")
                set(win_sdk_root_found TRUE)
            endif()
        endif()
        if(win_sdk_root_found)
            file(TO_CMAKE_PATH "${found_win_sdk_root}" cmake_path)
            list(APPEND win_sdk_roots "${cmake_path}")
            set(WIN_SDK_ROOT "${cmake_path}"
                CACHE PATH "Location of the Windows SDK" FORCE)
        endif()
    endif()

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        # 64-bit binary directory
        set(_bit_bin "bin/x64")
    else()
        # 32-bit binary directory
        set(_bit_bin "bin/x86")
    endif()

    # Generic 64-bit and 32-bit directories
    list(APPEND win_sdk_binary_suffixes "${_bit_bin}" "bin")

    # Find executable
    find_program(CMAKE_MC_COMPILER "mc"
        HINTS ${win_sdk_roots}
        PATH_SUFFIXES ${win_sdk_binary_suffixes}
        DOC "path to Microsoft Message Compiler")
    mark_as_advanced(CMAKE_MC_COMPILER)
    set(CMAKE_MC_COMPILER "${CMAKE_MC_COMPILER}" PARENT_SCOPE)
endfunction()

_message_compiler_find()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(MessageCompiler
    FOUND_VAR MessageCompiler_FOUND
    REQUIRED_VARS CMAKE_MC_COMPILER
    FAIL_MESSAGE "Failed to find Microsoft Message Compiler")

if(MessageCompiler_DEBUG)
    message(STATUS "--------FindMessageCompiler.cmake results debug--------")
    message(STATUS "Microsoft Message Compiler found: ${MessageCompiler_FOUND}")
    message(STATUS "Microsoft Message Compiler: ${CMAKE_MC_COMPILER}")
    message(STATUS "----------------")
endif()
