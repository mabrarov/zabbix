cmake_minimum_required(VERSION 3.0)
project(zabbix)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(cmake/utils.cmake)

add_subdirectory(zabbix_agentd)
