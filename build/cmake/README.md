# Zabbix CMake project

This directory contains CMake project which is created based on official makefiles provided with Zabbix sources. The only intention of this CMake project is to make it easier to build Zabbix Agent for Windows from [source code of Zabbix](https://www.zabbix.com/download_sources).

## Prerequisites

Because of Windows Zabbix Agent is built using static C/C++ runtime (refer to `/MT` option in "[build/win32/project/Makefile_common.inc](../win32/project/Makefile_common.inc#L15)") all libraries which are statically linked with Zabbix Agent (`zabbix_agentd.exe`) should be built with static C/C++ runtime too.

1. [CMake](https://cmake.org/)

    This CMake project was tested with [CMake 3.7.2](https://cmake.org/files/v3.7/cmake-3.7.2-win32-x86.zip). 

1. [PCRE](https://www.pcre.org/)

    This CMake project was tested with [PCRE 8.42](https://ftp.pcre.org/pub/pcre/pcre-8.42.zip).

    Use `PCRE_STATIC_RUNTIME` option of CMake project provided by PCRE to built static PCRE library with static C/C++ runtime.
    Below commands can be used to build PCRE with Visual Studio 2015 (it is assumed that current directory is some temporary location used for generated Visual Studio project):

    ```cmd
    cmake.exe -D PCRE_STATIC_RUNTIME=ON -D CMAKE_INSTALL_PREFIX=<path-to-directory-for-the-built-PCRE> -G "Visual Studio 14 2015 Win64" <path-to-directory-with-unpacked-sources-of-PCRE>
    cmake --build . --config Debug --target install
    cmake --build . --config Release --target install
    ```

1. [OpenSSL](https://www.openssl.org/) (optional, but is required if support of TLS is needed).

    Though Zabbix makefiles additionally support (refer to "[build/win32/project/Makefile_tls.inc](../win32/project/Makefile_tls.inc)") [mbed TLS](https://tls.mbed.org/) (PolarSSL) and [GnuTLS](https://www.gnutls.org/) this CMake project doesn't support them yet.

    This CMake project was tested with [precompiled OpenSSL 1.1.0f for Visual C++ 2015](https://www.npcglib.org/~stathis/downloads/openssl-1.1.0f-vs2015.7z) taken from "[Precompiled OpenSSL - sigmoid](https://www.npcglib.org/~stathis/blog/precompiled-openssl/)".

    To make `FindOpenSSL` CMake module (used by this CMake project) able to find OpenSSL libraries some changes are required after precompiled OpenSSL is unpacked - move & rename files:

    * `lib64/libcryptoMT.lib` -> `lib/libcrypto64MT.lib`   
    * `lib64/libcryptoMTd.lib` -> `lib/libcrypto64MTd.lib`
    * `lib64/libsslMT.lib` -> `lib/libssl64MT.lib`
    * `lib64/libsslMTd.lib` -> `lib/libssl64MTd.lib`

## Building

**Note** that on Windows CMake should be executed with Windows SDK environment set up (even if `Visual Studio` generator is used) - this helps to find some tools like Microsoft Message Compiler and Microsoft Manifest Tool. It can be achieved with below command for x64 build environment when using Visual Studio 2015 (it's assumed that Visual Studio 2015 is installed into `C:\Program Files (x86)\Microsoft Visual Studio 14.0` directory):

```cmd
"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
```

The same command is executed by "VS2015 x64 Native Tools Command Prompt" shortcut (it can be found in Windows Start menu when Visual Studio 2015 is installed) - so that shortcut can be used instead to open and prepare Windows command prompt for using CMake. 

## Build options

It's assumed that `<zabbix_root>` is the directory where this git repository is cloned into.

1. `CMAKE_USER_MAKE_RULES_OVERRIDE` option should point to `<zabbix_root>/build/cmake/cmake/static_c_runtime_overrides.cmake`.
1. `CMAKE_USER_MAKE_RULES_OVERRIDE_CXX` option should point to `<zabbix_root>/build/cmake/cmake/static_cxx_runtime_overrides.cmake`.
1. `PCRE_ROOT` can be used as a hint for searching for PCRE. It should point to the directory where built PCRE is installed (refer to `<path-to-directory-for-the-built-PCRE>` in "[Prerequisites](#prerequisites)" section). 

    Refer to header of FindPCRE CMake module (located in `<zabbix_root>/build/cmake/cmake/FindPCRE.cmake`) for details.

1. `OPENSSL_ROOT_DIR` can be used as a hint for searching for OpenSSL. It should point to the directory where built OpenSSL is located (is unpacked). 

    Refer to [FindOpenSSL](https://cmake.org/cmake/help/v3.0/module/FindOpenSSL.html) CMake module documentation for details.

## Example for generation of project

Example of command line for generation of Visual Studio 2015 project with below parameters:

1. `D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake` is the same directory where this `README.md` is located.
1. `CMAKE_USER_MAKE_RULES_OVERRIDE` and `CMAKE_USER_MAKE_RULES_OVERRIDE_CXX` are required to use static C/C++ runtime.
1. `D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015` is the directory where PCRE is installed.
1. `D:\Users\Marat\Documents\work\cpp\openssl-1.1.0f-vs2015` is the directory where OpenSSL is installed (unpacked).

Current directory is the directory where generated Visual Studio 2015 project will be placed. 

```cmd
cmake.exe -D CMAKE_USER_MAKE_RULES_OVERRIDE=D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake\cmake\static_c_runtime_overrides.cmake -D CMAKE_USER_MAKE_RULES_OVERRIDE_CXX=D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake\cmake\static_cxx_runtime_overrides.cmake -D PCRE_ROOT=D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015 -D OPENSSL_ROOT_DIR=D:\Users\Marat\Documents\work\cpp\openssl-1.1.0f-vs2015 -G "Visual Studio 14 2015 Win64" D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake
```

## Example for building of generated Visual Studio 2015 project

Example of command line for building release version of generated Visual Studio 2015 project (current directory is the directory where generated Visual Studio 2015 project is located):

```cmd
cmake --build . --config Release
```

`zabbix_agentd/Release/zabbix_agentd.exe` file is created if build is successful.