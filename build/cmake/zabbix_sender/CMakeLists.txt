cmake_minimum_required(VERSION 3.0)
project(zabbix_sender)

find_package(PCRE REQUIRED COMPONENTS pcre pcreposix)
find_package(OpenSSL)

set(target_name "${PROJECT_NAME}")
set(generate_messages_target_name "${target_name}_generate_messages")
set(output_name "zabbix_sender")

set(zbx_libs_dir "${zbx_src_dir}/libs")
set(zbx_project_dir "${zbx_src_dir}/${PROJECT_NAME}")
set(message_compiler_output_dir "${CMAKE_CURRENT_BINARY_DIR}")

set(cxx_compile_definitions )
set(cxx_compile_options )
set(resource_compile_definitions )
set(resource_compile_options )
set(cxx_sources )
set(message_source )
set(resource_headers )
set(resource_sources )
set(link_options )
set(libraries )

list(APPEND cxx_compile_definitions
    "_WINDOWS"
    "_WIN32_WINNT=0x0501"
    "_CONSOLE"
    "UNICODE"
    "_UNICODE"
    "HAVE_WINLDAP_H"
    "HAVE_ASSERT_H"
    "ZABBIX_SERVICE"
    "_VC80_UPGRADE=0x0600"
    "HAVE_IPV6")

if(OPENSSL_FOUND)
    list(APPEND cxx_compile_definitions
        "HAVE_OPENSSL")
endif()

if(MSVC)
    list(APPEND cxx_compile_options
        "$<$<NOT:$<CONFIG:DEBUG>>:/Ob1>"
        "/GF"
        "/FD"
        "/Gy"
        "/W3")
endif()

list(APPEND resource_compile_definitions
    "ZABBIX_SENDER")

if(MSVC)
    list(APPEND resource_compile_options
        "/l 0x419")
endif()

if(MSVC)
    list(APPEND link_options
        "/INCREMENTAL:NO"
        "/DYNAMICBASE:NO")
endif()

list(APPEND libraries
    PCRE::pcre
    PCRE::pcreposix
    "ws2_32"
    "psapi"
    "pdh"
    "Wldap32"
    "advapi32"
    "uuid"
    "Iphlpapi")

if(OPENSSL_FOUND)
    list(APPEND libraries
        OpenSSL::SSL
        OpenSSL::Crypto)
    if(OPENSSL_USE_STATIC_LIBS)
        list(APPEND libraries
            "crypt32")
    endif()
endif()

list(APPEND cxx_sources
    "${zbx_libs_dir}/zbxcommon/comms.c"
    "${zbx_libs_dir}/zbxcommon/iprange.c"
    "${zbx_libs_dir}/zbxcommon/misc.c"
    "${zbx_libs_dir}/zbxcommon/str.c"
    "${zbx_libs_dir}/zbxcommon/xml.c"
    "${zbx_libs_dir}/zbxcommon/zbxgetopt.c"
    "${zbx_libs_dir}/zbxcomms/comms.c"
    "${zbx_libs_dir}/zbxconf/cfg.c"
    "${zbx_libs_dir}/zbxcrypto/base64.c"
    "${zbx_libs_dir}/zbxjson/json.c"
    "${zbx_libs_dir}/zbxjson/json_parser.c"
    "${zbx_libs_dir}/zbxlog/log.c"
    "${zbx_libs_dir}/zbxsys/mutexs.c"
    "${zbx_libs_dir}/zbxsys/symbols.c"
    "${zbx_libs_dir}/zbxsys/threads.c"
    "${zbx_libs_dir}/zbxwin32/fatal.c"
    "${zbx_project_dir}/zabbix_sender.c")

if(OPENSSL_FOUND)
    list(APPEND cxx_sources
        "${zbx_libs_dir}/zbxcrypto/tls.c")
endif()

set(message_source "${zbx_makefile_dir}/messages.mc")

# These 2 files are genereated by Message Compiler
set(message_header "${message_compiler_output_dir}/messages.h")
set(message_binary "${message_compiler_output_dir}/Msg00001.bin")
# Command to generate
add_custom_command(OUTPUT "${message_header}" "${message_binary}"
    COMMAND "${CMAKE_MC_COMPILER}"
    ARGS -U -h "${message_compiler_output_dir}" -r "${message_compiler_output_dir}" "${message_source}"
    DEPENDS "${message_source}"
    VERBATIM)
add_custom_target(${generate_messages_target_name}
    DEPENDS "${message_header}" "${message_binary}")

list(APPEND resource_headers
    "${zbx_makefile_dir}/resource.h"
    "${zbx_makefile_dir}/zabbix_sender_desc.h")

list(APPEND resource_sources
    "${zbx_makefile_dir}/resource.rc")

set(resource_files
    ${resource_headers}
    ${resource_sources}
    "${message_source}")

set_property(SOURCE ${resource_sources} APPEND PROPERTY COMPILE_DEFINITIONS ${resource_compile_definitions})
set_property(SOURCE ${resource_sources} APPEND PROPERTY COMPILE_FLAGS ${resource_compile_options})

add_executable(${target_name}
    ${cxx_sources}
    ${resource_headers}
    ${resource_sources})
target_compile_options(${target_name}
    PRIVATE
    ${cxx_compile_options})
target_compile_definitions(${target_name}
    PRIVATE
    ${cxx_compile_definitions})
target_include_directories(${target_name}
    PUBLIC
    ${zbx_project_dir}
    ${message_compiler_output_dir}
    ${zbx_makefile_dir}
    ${zbx_config_include_dir}
    ${zbx_include_dir})

set(link_option_str "")
if(NOT MSVC)
    # This should work for most of CMake generators except Visual Studio
    zbx_list_to_string("${link_options}" "," link_option_str)
endif()

target_link_libraries(${target_name}
    PRIVATE
    "${link_option_str}"
    ${libraries})

if(MSVC)
    foreach(link_option IN LISTS link_options)
        # This is the only way I found to pass linker options using Visual Studio CMake generator
        set_property(TARGET ${target_name} APPEND_STRING PROPERTY LINK_FLAGS " ${link_option}")
    endforeach()
endif()

add_dependencies(${target_name} ${generate_messages_target_name})

# Do not put results of build to the same place as makefiles do
# because "CMake style" prefers out-of-source tree builds.
#zbx_set_target_output_dir(${target_name} "${zbx_output_dir}")
set_target_properties(${target_name} PROPERTIES OUTPUT_NAME "${output_name}")

if(NOT zbx_no_cmake_dir_source_group)
    # Group files according to file path
    zbx_dir_source_group("Source Files" "${zbx_src_dir}" "${cxx_sources}")
    zbx_dir_source_group("Resource Files" "${zbx_home_dir}" "${resource_files}")
endif()
