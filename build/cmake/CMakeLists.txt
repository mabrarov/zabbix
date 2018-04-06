cmake_minimum_required(VERSION 3.0)
project(zabbix)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(cmake/utils.cmake)

# Get full list of build configurations
set(configuration_types ${CMAKE_CONFIGURATION_TYPES})
if(NOT configuration_types AND DEFINED CMAKE_BUILD_TYPE)
    list(APPEND configuration_types ${CMAKE_BUILD_TYPE})
endif()

# Common target properties (CMAKE_CXX_FLAGS)
zbx_change_default_compile_options("${CMAKE_CXX_FLAGS}" CMAKE_CXX_FLAGS)
foreach(configuration_type IN LISTS configuration_types)
    string(TOUPPER ${configuration_type} configuration_type_upper_case)
    set(configuration_cxx_flags CMAKE_CXX_FLAGS_${configuration_type_upper_case})
    zbx_change_default_compile_options("${${configuration_cxx_flags}}" ${configuration_cxx_flags})
endforeach(configuration_type)

# Common target properties (CMAKE_EXE_LINKER_FLAGS)
zbx_change_default_link_options("${CMAKE_EXE_LINKER_FLAGS}" CMAKE_EXE_LINKER_FLAGS)
foreach(configuration_type IN LISTS configuration_types)
    string(TOUPPER ${configuration_type} configuration_type_upper_case)
    set(configuration_cxx_flags CMAKE_EXE_LINKER_FLAGS_${configuration_type_upper_case})
    zbx_change_default_link_options("${${configuration_cxx_flags}}" ${configuration_cxx_flags})
endforeach(configuration_type)

add_subdirectory(zabbix_agentd)
