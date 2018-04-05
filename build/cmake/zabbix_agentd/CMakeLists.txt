cmake_minimum_required(VERSION 3.0)
project(zabbix_agentd)

set(zbx_home_dir "${PROJECT_SOURCE_DIR}/../../..")

if(zbx_platform EQUAL 64)
    set(zbx_output_dir "${zbx_home_dir}/bin/win64")
else()
    set(zbx_output_dir "${zbx_home_dir}/bin/win32")
endif()

set(zbx_project_dir        "${zbx_home_dir}/src/zabbix_agent")
set(zbx_makefile_dir       "${zbx_home_dir}/build/win32/project")
set(zbx_config_include_dir "${zbx_home_dir}/build/win32/include")
set(zbx_include_dir        "${zbx_home_dir}/include")
set(zbx_src_dir            "${zbx_home_dir}/src")

set(common_compile_definitions )
set(common_compile_options )
set(c_compile_definitions )
set(c_compile_options )
set(cpp_compile_definitions )
set(cpp_compile_options )
set(c_sources )
set(cpp_sources )
set(link_options )
set(libraries )

list(APPEND common_compile_definitions
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

list(APPEND common_compile_options
    "/Zi"
    "/nologo"
    "/O2"
    "/Ob1"
    "/GF"
    "/FD"
    "/EHsc"
    "/MT"
    "/Gy"
    "/W3"
    "/c")

list(APPEND c_compile_definitions
    ${common_compile_definitions})

list(APPEND c_compile_options
    ${common_compile_options}
    "/TC")

list(APPEND cpp_compile_definitions
    ${common_compile_definitions})

list(APPEND cpp_compile_options
    ${common_compile_options}
    "/TP")

set(manifest_file "/MANIFESTFILE:\"${PROJECT_NAME}.exe.manifest\"")

list(APPEND link_options
    "/DEBUG"
    "/OPT:REF"
    "/DELAYLOAD:wevtapi.dll"
    "/NOLOGO"
    "/INCREMENTAL:NO"
    "/MANIFEST"
    ${manifest_file}
    "/MANIFESTUAC:\"level='asInvoker' uiAccess='false'\""
    "/SUBSYSTEM:CONSOLE "
    "/DYNAMICBASE:NO")

set(libraries
    "ws2_32"
    "psapi"
    "pdh"
    "Wldap32"
    "advapi32"
    "uuid"
    "Iphlpapi"
    "delayimp"
    "wevtapi")

list(APPEND c_sources
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

list(APPEND cpp_sources
    "${zbx_src_dir}/libs/zbxsysinfo/win32/wmi.cpp")

set(c_and_cpp_sources ${c_sources} ${cpp_sources})

set_source_files_properties(${c_sources} PROPERTIES COMPILE_DEFINITIONS "${c_compile_definitions}")
set_source_files_properties(${c_sources} PROPERTIES COMPILE_FLAGS "${c_compile_options}")

set_source_files_properties(${cpp_sources} PROPERTIES COMPILE_DEFINITIONS "${cpp_compile_definitions}")
set_source_files_properties(${cpp_sources} PROPERTIES COMPILE_FLAGS "${cpp_compile_options}")

zbx_list_to_comma_separated_string(${link_options} link_options_str)

add_executable(${PROJECT_NAME}
    ${c_sources}
    ${cpp_sources})
target_compile_options(${PROJECT_NAME}
    PRIVATE
    ${common_compile_options})
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
    ${common_compile_definitions})
target_include_directories(${PROJECT_NAME}
    PUBLIC
    ${zbx_project_dir}
    ${zbx_makefile_dir}
    ${zbx_config_include_dir}
    ${zbx_include_dir})
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    "${link_options_str}"
    ${libraries})

if(NOT zbx_no_cmake_dir_source_group)
    # Group files according to file path
    zbx_dir_source_group("Source Files" "${zbx_src_dir}" "${c_and_cpp_sources}")
endif()
