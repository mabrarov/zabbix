cmake_minimum_required(VERSION 3.0)

find_package(PkgConfig QUIET)

get_filename_component(win_sdk_dir "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH)
if(CMAKE_C_SIZEOF_DATA_PTR EQUAL 8)
    list(APPEND win_sdk_binary_suffixes "bin/x64" "bin")
else()
    list(APPEND win_sdk_binary_suffixes "bin/x86" "bin")
endif()

find_program(CMAKE_MC_COMPILER "mc"
    HINTS ${win_sdk_dir}
    PATH_SUFFIXES ${win_sdk_binary_suffixes}
    DOC "path to Microsoft Message Compiler")

mark_as_advanced(CMAKE_MC_COMPILER)

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
