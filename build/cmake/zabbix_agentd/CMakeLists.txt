cmake_minimum_required(VERSION 3.0)
project(zabbix_agentd)

find_package(MessageCompiler REQUIRED)
find_package(PCRE REQUIRED COMPONENTS pcre pcreposix)
find_package(OpenSSL)

set(zbx_home_dir "${PROJECT_SOURCE_DIR}/../../..")

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(zbx_output_dir "${zbx_home_dir}/bin/win64")
else()
    set(zbx_output_dir "${zbx_home_dir}/bin/win32")
endif()

set(zbx_project_dir        "${zbx_home_dir}/src/zabbix_agent")
set(zbx_makefile_dir       "${zbx_home_dir}/build/win32/project")
set(zbx_config_include_dir "${zbx_home_dir}/build/win32/include")
set(zbx_include_dir        "${zbx_home_dir}/include")
set(zbx_src_dir            "${zbx_home_dir}/src")

set(message_compiler_output_dir "${CMAKE_CURRENT_BINARY_DIR}")

set(cxx_compile_definitions )
set(cxx_compile_options )
set(cxx_sources )
set(message_source )
set(resource_headers )
set(resource_sources )
set(link_options )
set(libraries )

list(APPEND cxx_compile_definitions
    ZABBIX_AGENT
    WITH_AGENT_METRICS
    WITH_COMMON_METRICS
    WITH_SPECIFIC_METRICS
    WITH_HOSTNAME_METRIC
    WITH_SIMPLE_METRICS
    _WINDOWS
    _WIN32_WINNT=0x0501
    _CONSOLE
    UNICODE
    _UNICODE
    HAVE_WINLDAP_H
    HAVE_ASSERT_H
    ZABBIX_SERVICE
    _VC80_UPGRADE=0x0600
    HAVE_IPV6)

if(OPENSSL_FOUND)
    list(APPEND cxx_compile_definitions
        HAVE_OPENSSL)
endif()

list(APPEND cxx_compile_options
    "/GF"
    "/Gy")

list(APPEND link_options
    "/DELAYLOAD:wevtapi.dll")

list(APPEND libraries
    PCRE::pcre
    PCRE::pcreposix
    "ws2_32"
    "psapi"
    "pdh"
    "Wldap32"
    "advapi32"
    "uuid"
    "Iphlpapi"
    "delayimp"
    "wevtapi")

if(OPENSSL_FOUND)
    list(APPEND libraries
        OpenSSL::SSL
        OpenSSL::Crypto)
    if(OPENSSL_USE_STATIC_LIBS)
        list(APPEND libraries crypt32)
    endif()
endif()

list(APPEND cxx_sources
    "${zbx_src_dir}/libs/zbxalgo/algodefs.c"
    "${zbx_src_dir}/libs/zbxalgo/vector.c"
    "${zbx_src_dir}/libs/zbxcommon/alias.c"
    "${zbx_src_dir}/libs/zbxcommon/comms.c"
    "${zbx_src_dir}/libs/zbxcommon/iprange.c"
    "${zbx_src_dir}/libs/zbxcommon/misc.c"
    "${zbx_src_dir}/libs/zbxcommon/str.c"
    "${zbx_src_dir}/libs/zbxcommon/xml.c"
    "${zbx_src_dir}/libs/zbxcommon/zbxgetopt.c"
    "${zbx_src_dir}/libs/zbxcommon/file.c"
    "${zbx_src_dir}/libs/zbxcomms/comms.c"
    "${zbx_src_dir}/libs/zbxcomms/telnet.c"
    "${zbx_src_dir}/libs/zbxconf/cfg.c"
    "${zbx_src_dir}/libs/zbxcrypto/base64.c"
    "${zbx_src_dir}/libs/zbxcrypto/md5.c"
    "${zbx_src_dir}/libs/zbxjson/json.c"
    "${zbx_src_dir}/libs/zbxjson/json_parser.c"
    "${zbx_src_dir}/libs/zbxlog/log.c"
    "${zbx_src_dir}/libs/zbxsys/mutexs.c"
    "${zbx_src_dir}/libs/zbxsys/symbols.c"
    "${zbx_src_dir}/libs/zbxsys/threads.c"
    "${zbx_src_dir}/libs/zbxexec/execute.c"
    "${zbx_src_dir}/libs/zbxsysinfo/agent/agent.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/common.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/cpu.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/dir.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/file.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/http.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/net.c"
    "${zbx_src_dir}/libs/zbxsysinfo/common/system.c"
    "${zbx_src_dir}/libs/zbxsysinfo/simple/ntp.c"
    "${zbx_src_dir}/libs/zbxsysinfo/simple/simple.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/cpu.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/diskio.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/diskspace.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/memory.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/net.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/pdhmon.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/proc.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/services.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/swap.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/uptime.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/win32.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/wmi.cpp"
    "${zbx_src_dir}/libs/zbxsysinfo/sysinfo.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/software.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/system.c"
    "${zbx_src_dir}/libs/zbxsysinfo/win32/hostname.c"
    "${zbx_src_dir}/libs/zbxwin32/perfmon.c"
    "${zbx_src_dir}/libs/zbxwin32/service.c"
    "${zbx_src_dir}/libs/zbxself/selfmon.c"
    "${zbx_src_dir}/zabbix_agent/active.c"
    "${zbx_src_dir}/zabbix_agent/cpustat.c"
    "${zbx_src_dir}/zabbix_agent/eventlog.c"
    "${zbx_src_dir}/zabbix_agent/listener.c"
    "${zbx_src_dir}/zabbix_agent/logfiles.c"
    "${zbx_src_dir}/zabbix_agent/perfstat.c"
    "${zbx_src_dir}/zabbix_agent/stats.c"
    "${zbx_src_dir}/zabbix_agent/zabbix_agentd.c"
    "${zbx_src_dir}/zabbix_agent/zbxconf.c"
    "${zbx_src_dir}/libs/zbxregexp/zbxregexp.c"
    "${zbx_src_dir}/libs/zbxwin32/fatal.c"
    "${zbx_src_dir}/libs/zbxwin32/disk.c")

if(OPENSSL_FOUND)
    list(APPEND cxx_sources
        "${zbx_src_dir}/libs/zbxcrypto/tls.c")
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

list(APPEND resource_headers
    "${zbx_makefile_dir}/resource.h"
    "${zbx_makefile_dir}/zabbix_agent_desc.h")

list(APPEND resource_sources
    "${zbx_makefile_dir}/resource.rc")

zbx_list_to_comma_separated_string(${link_options} link_options_str)

set(resource_files
    ${resource_headers}
    ${resource_sources}
    "${message_source}"
    "${message_header}"
    "${message_binary}")

add_executable(${PROJECT_NAME}
    ${cxx_sources}
    "${message_header}"
    "${message_binary}"
    ${resource_headers}
    ${resource_sources})
target_compile_options(${PROJECT_NAME}
    PRIVATE
    ${cxx_compile_options})
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
    ${cxx_compile_definitions})
target_include_directories(${PROJECT_NAME}
    PUBLIC
    ${zbx_project_dir}
    ${message_compiler_output_dir}
    ${zbx_makefile_dir}
    ${zbx_config_include_dir}
    ${zbx_include_dir})
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    "${link_options_str}"
    ${libraries})

# Do not put results of build to the same place as makefiles do
# because "CMake style" prefers out-of-source tree builds.
#zbx_set_target_output_dir(${PROJECT_NAME} "${zbx_output_dir}")

if(NOT zbx_no_cmake_dir_source_group)
    # Group files according to file path
    zbx_dir_source_group("Source Files" "${zbx_src_dir}" "${cxx_sources}")
    zbx_dir_source_group("Resource Files" "${zbx_home_dir}" "${resource_files}")
endif()
