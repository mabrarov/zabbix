cmake_minimum_required(VERSION 3.0)

find_package(PkgConfig QUIET)

get_filename_component(win_sdk_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH)
if(CMAKE_C_SIZEOF_DATA_PTR EQUAL 8)
    list(APPEND win_sdk_binary_suffixes "bin/x64" "bin")
else()
    list(APPEND win_sdk_binary_suffixes "bin/x86" "bin")
endif()

find_program(CMAKE_MANIFEST_TOOL "mt"
    HINTS ${win_sdk_dir}
    PATH_SUFFIXES ${win_sdk_binary_suffixes}
    DOC "path to Microsoft Manifest Tool")

mark_as_advanced(CMAKE_MANIFEST_TOOL)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ManifestTool
    FOUND_VAR ManifestTool_FOUND
    REQUIRED_VARS CMAKE_MANIFEST_TOOL
    FAIL_MESSAGE "Failed to find Microsoft Manifest Tool")

if(ManifestTool_DEBUG)
    message(STATUS "--------FindManifestTool.cmake results debug--------")
    message(STATUS "Microsoft Manifest Tool found: ${ManifestTool_FOUND}")
    message(STATUS "Microsoft Manifest Tool: ${CMAKE_MANIFEST_TOOL}")
    message(STATUS "----------------")
endif()
