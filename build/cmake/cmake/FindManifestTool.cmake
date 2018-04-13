cmake_minimum_required(VERSION 3.0)

find_package(PkgConfig QUIET)

function(_manifest_tool_find)
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
    find_program(CMAKE_MANIFEST_TOOL "mt"
        HINTS ${win_sdk_roots}
        PATH_SUFFIXES ${win_sdk_binary_suffixes}
        DOC "path to Microsoft Manifest Tool")
    mark_as_advanced(CMAKE_MANIFEST_TOOL)
    set(CMAKE_MANIFEST_TOOL "${CMAKE_MANIFEST_TOOL}" PARENT_SCOPE)
endfunction()

_manifest_tool_find()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ManifestTool
    FOUND_VAR ManifestTool_FOUND
    REQUIRED_VARS CMAKE_MANIFEST_TOOL
    FAIL_MESSAGE "Failed to find Microsoft Message Compiler")

if(ManifestTool_DEBUG)
    message(STATUS "--------FindManifestTool.cmake results debug--------")
    message(STATUS "Microsoft Message Compiler found: ${ManifestTool_FOUND}")
    message(STATUS "Microsoft Message Compiler: ${CMAKE_MANIFEST_TOOL}")
    message(STATUS "----------------")
endif()

