cmake_minimum_required(VERSION 3.0)
project(zabbix)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(cmake/utils.cmake)

set(zbx_home_dir "${CMAKE_CURRENT_SOURCE_DIR}/../..")
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(zbx_output_dir "${zbx_home_dir}/bin/win64")
else()
    set(zbx_output_dir "${zbx_home_dir}/bin/win32")
endif()
set(zbx_makefile_dir       "${zbx_home_dir}/build/win32/project")
set(zbx_config_include_dir "${zbx_home_dir}/build/win32/include")
set(zbx_include_dir        "${zbx_home_dir}/include")
set(zbx_src_dir            "${zbx_home_dir}/src")

find_package(MessageCompiler REQUIRED)
find_package(ManifestTool REQUIRED)

add_subdirectory(zabbix_agent)
add_subdirectory(zabbix_get)
add_subdirectory(zabbix_sender)
add_subdirectory(zabbix_sender_dll)
