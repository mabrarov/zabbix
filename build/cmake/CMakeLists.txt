cmake_minimum_required(VERSION 3.0)
project(zabbix)

include(cmake_modules/utils.cmake)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(zbx_platform 64)
else()
    set(zbx_platform 32)
endif()

add_subdirectory(zabbix_agentd)
