# Zabbix CMake project 

Example of command line for generation of Visual Studio 2015 project taking:

1. PCRE (built with static C/C++ runtime using Visual C++ 2015) from `D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015` directory.
   PCRE is built and installed into `D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015` directory using its built-in CMake project.
   CMake command to generate Visual Studio 2015 project is:
   
   ```cmd
   cmake.exe -D PCRE_STATIC_RUNTIME=ON -D CMAKE_INSTALL_PREFIX=D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015 -G "Visual Studio 14 2015 Win64" ..\pcre-8.42
   ``` 

   After Visual Studio 2015 projet was generated I used Visual Studio to build solution and to build `INSTALL` project twice:
   * with `Debug` configuration,
   * with `Release` configuration. 
1. OpenSSL (static library built with static C/C++ runtime using Visual C++ 2015) from `D:\Users\Marat\Documents\work\cpp\openssl-1.1.0f-vs2015` directory. 
   OpenSSL is taken from [Precompiled OpenSSL - sigmoid](https://www.npcglib.org/~stathis/blog/precompiled-openssl/) - [openssl-1.1.0f-vs2015.7z](https://www.npcglib.org/~stathis/downloads/openssl-1.1.0f-vs2015.7z).
   To make `FindOpenSSL` CMake module able to find OpenSSL libraries I had to move & rename:
   * `lib64/libcryptoMT.lib` -> `lib/libcrypto64MT.lib`   
   * `lib64/libcryptoMTd.lib` -> `lib/libcrypto64MTd.lib`
   * `lib64/libsslMT.lib` -> `lib/libssl64MT.lib`
   * `lib64/libsslMTd.lib` -> `lib/libssl64MTd.lib`
1. `D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake` is the same directory where this `README.md` is located.
1. `CMAKE_USER_MAKE_RULES_OVERRIDE` and `CMAKE_USER_MAKE_RULES_OVERRIDE_CXX` are required to use static C/C++ runtime (which is used by Zabbix makefiles).

```cmd
cmake.exe -D CMAKE_USER_MAKE_RULES_OVERRIDE=D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake\cmake\static_c_runtime_overrides.cmake -D CMAKE_USER_MAKE_RULES_OVERRIDE_CXX=D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake\cmake\static_cxx_runtime_overrides.cmake -D PCRE_ROOT=D:\Users\Marat\Documents\work\cpp\pcre-8.42_msvc2015 -D OPENSSL_ROOT_DIR=D:\Users\Marat\Documents\work\cpp\openssl-1.1.0f-vs2015 -G "Visual Studio 14 2015 Win64" D:\Users\Marat\Documents\work\cpp\zabbix\build\cmake
```
