#.rst:
# FindPCRE
# -------
#
# Find the PCRE libraries.
#
# This module supports multiple components.
# Components can include any of: ``pcre``, ``pcreposix`` and ``pcrecpp``.
#
# This module reports information about the PCRE installation in
# several variables.  General variables::
#
#   PCRE_VERSION - PCRE release version
#   PCRE_FOUND - true if the main programs and libraries were found
#   PCRE_LIBRARIES - component libraries to be linked
#   PCRE_INCLUDE_DIRS - the directories containing the PCRE headers
#
# Imported targets::
#
#   PCRE::<C>
#
# Where ``<C>`` is the name of an PCRE component, for example
# ``PCRE::pcre``.
#
# PCRE programs are reported in::
#
#   PCRE_PCREGREP
#   PCRE_PCRETEST
#   PCRE_PCRECPP_UNITTEST
#   PCRE_PCRE_STRINGPIECE_UNITTEST
#   PCRE_PCRE_SCANNER_UNITTEST
#
# PCRE component libraries are reported in::
#
#   PCRE_<C>_FOUND - ON if component was found
#   PCRE_<C>_LIBRARIES - libraries for component
#
# Note that ``<C>`` is the uppercased name of the component.
#
# This module reads hints about search results from::
#
#   PCRE_ROOT - the root of the PCRE installation
#   PCRE_STATIC_RUNTIME - if PCRE is built with static C/C++ runtime
#
# The environment variable ``PCRE_ROOT`` may also be used; the
# PCRE_ROOT variable takes precedence.
#
# The following cache variables may also be set::
#
#   PCRE_<P>_EXECUTABLE - the path to executable <P>
#   PCRE_INCLUDE_DIR - the directory containing the PCRE headers
#   PCRE_<C>_LIBRARY - the library for component <C>
#
# .. note::
#
#   In most cases none of the above variables will require setting,
#   unless multiple PCRE versions are available and a specific version
#   is required.
#
# Other variables one may set to control this module are::
#
#   PCRE_DEBUG - Set to ON to enable debug output from FindPCRE.

cmake_minimum_required(VERSION 3.7)

find_package(PkgConfig QUIET)

set(PCRE_programs
    pcregrep
    pcretest
    pcrecpp_unittest
    pcre_stringpiece_unittest
    pcre_scanner_unittest)

# The PCRE checks are contained in a function due to the large number
# of temporary variables needed.
function(_PCRE_FIND)
    # Set up search paths, taking compiler into account.  Search PCRE_ROOT,
    # with PCRE_ROOT in the environment as a fallback if unset.
    if(PCRE_ROOT)
        list(APPEND PCRE_roots "${PCRE_ROOT}")
    else()
        if(NOT "$ENV{PCRE_ROOT}" STREQUAL "")
            file(TO_CMAKE_PATH "$ENV{PCRE_ROOT}" NATIVE_PATH)
            list(APPEND PCRE_roots "${NATIVE_PATH}")
            set(PCRE_ROOT "${NATIVE_PATH}"
                CACHE PATH "Location of the PCRE installation" FORCE)
        endif()
    endif()

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        # 64-bit binary directory
        set(_bin64 "bin64")
        # 64-bit library directory
        set(_lib64 "lib64")
    endif()

    list(APPEND PCRE_include_suffixes "include")
    # Generic 64-bit and 32-bit directories
    list(APPEND PCRE_binary_suffixes "${_bin64}" "bin")
    list(APPEND PCRE_library_suffixes "${_lib64}" "lib")

    # Find all PCRE programs
    foreach(program ${PCRE_programs})
        string(TOUPPER "${program}" program_upcase)
        set(cache_var "PCRE_${program_upcase}_EXECUTABLE")
        set(program_var "PCRE_${program_upcase}_EXECUTABLE")
        find_program("${cache_var}" "${program}"
            HINTS ${PCRE_roots}
            PATH_SUFFIXES ${PCRE_binary_suffixes}
            DOC "PCRE ${program} executable")
        mark_as_advanced(cache_var)
        set("${program_var}" "${${cache_var}}" PARENT_SCOPE)
    endforeach()

    # Find include directory
    find_path(PCRE_INCLUDE_DIR
        NAMES "pcre.h"
        HINTS ${PCRE_roots}
        PATH_SUFFIXES ${PCRE_include_suffixes}
        DOC "PCRE include directory")
    set(PCRE_INCLUDE_DIR "${PCRE_INCLUDE_DIR}" PARENT_SCOPE)

    # Get version
    if(PCRE_INCLUDE_DIR AND EXISTS "${PCRE_INCLUDE_DIR}/pcre.h")
        file(STRINGS "${PCRE_INCLUDE_DIR}/pcre.h" PCRE_major_header_str
            REGEX "^#define[\t ]+PCRE_MAJOR[\t ]+[0-9]+.*")
        file(STRINGS "${PCRE_INCLUDE_DIR}/pcre.h" PCRE_minor_header_str
            REGEX "^#define[\t ]+PCRE_MINOR[\t ]+[0-9]+.*")
        string(REGEX REPLACE "^#define[\t ]+PCRE_MAJOR[\t ]+([^ \\n]*).*"
            "\\1" PCRE_major_version_string "${PCRE_major_header_str}")
        string(REGEX REPLACE "^#define[\t ]+PCRE_MINOR[\t ]+([^ \\n]*).*"
            "\\1" PCRE_minor_version_string "${PCRE_minor_header_str}")
        set(PCRE_VERSION "${PCRE_major_version_string}.${PCRE_minor_version_string}" PARENT_SCOPE)
        unset(PCRE_major_header_str)
        unset(PCRE_minor_header_str)
        unset(PCRE_major_version_string)
        unset(PCRE_minor_version_string)
    endif()

    # Find all PCRE libraries
    set(PCRE_REQUIRED_LIBS_FOUND ON)
    foreach(component ${PCRE_FIND_COMPONENTS})
        string(TOUPPER "${component}" component_upcase)
        set(component_cache "PCRE_${component_upcase}_LIBRARY")
        set(component_cache_release "${component_cache}_RELEASE")
        set(component_cache_debug "${component_cache}_DEBUG")
        set(component_found "${component_upcase}_FOUND")
        set(component_libnames "${component}")
        set(component_debug_libnames "${component}d")

        find_library("${component_cache_release}" ${component_libnames}
            HINTS ${PCRE_roots}
            PATH_SUFFIXES ${PCRE_library_suffixes}
            DOC "PCRE ${component} library (release)")
        find_library("${component_cache_debug}" ${component_debug_libnames}
            HINTS ${PCRE_roots}
            PATH_SUFFIXES ${PCRE_library_suffixes}
            DOC "PCRE ${component} library (debug)")
        include(SelectLibraryConfigurations)
        select_library_configurations(PCRE_${component_upcase})
        mark_as_advanced("${component_cache_release}" "${component_cache_debug}")
        if(${component_cache})
            set("${component_found}" ON)
            list(APPEND PCRE_LIBRARY "${${component_cache}}")
        endif()
        mark_as_advanced("${component_found}")
        set("${component_cache}" "${${component_cache}}" PARENT_SCOPE)
        set("${component_found}" "${${component_found}}" PARENT_SCOPE)
        if(${component_found})
            if (PCRE_FIND_REQUIRED_${component})
                list(APPEND PCRE_LIBS_FOUND "${component} (required)")
            else()
                list(APPEND PCRE_LIBS_FOUND "${component} (optional)")
            endif()
        else()
            if (PCRE_FIND_REQUIRED_${component})
                set(PCRE_REQUIRED_LIBS_FOUND OFF)
                list(APPEND PCRE_LIBS_NOTFOUND "${component} (required)")
            else()
                list(APPEND PCRE_LIBS_NOTFOUND "${component} (optional)")
            endif()
        endif()
    endforeach()
    set(_PCRE_REQUIRED_LIBS_FOUND "${PCRE_REQUIRED_LIBS_FOUND}" PARENT_SCOPE)
    set(PCRE_LIBRARY "${PCRE_LIBRARY}" PARENT_SCOPE)

    if(NOT PCRE_FIND_QUIETLY)
        if(PCRE_LIBS_FOUND)
            message(STATUS "Found the following PCRE libraries:")
            foreach(found ${PCRE_LIBS_FOUND})
                message(STATUS "  ${found}")
            endforeach()
        endif()
        if(PCRE_LIBS_NOTFOUND)
            message(STATUS "The following PCRE libraries were not found:")
            foreach(notfound ${PCRE_LIBS_NOTFOUND})
                message(STATUS "  ${notfound}")
            endforeach()
        endif()
    endif()

    if(PCRE_DEBUG)
        message(STATUS "--------FindPCRE.cmake search debug--------")
        message(STATUS "PCRE binary path search order: ${PCRE_roots}")
        message(STATUS "PCRE include path search order: ${PCRE_roots}")
        message(STATUS "PCRE library path search order: ${PCRE_roots}")
        message(STATUS "----------------")
    endif()
endfunction()

_PCRE_FIND()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PCRE
    FOUND_VAR PCRE_FOUND
    REQUIRED_VARS PCRE_INCLUDE_DIR
    PCRE_LIBRARY
    _PCRE_REQUIRED_LIBS_FOUND
    VERSION_VAR PCRE_VERSION
    FAIL_MESSAGE "Failed to find all PCRE components")

unset(_PCRE_REQUIRED_LIBS_FOUND)

if(PCRE_FOUND)
    set(PCRE_INCLUDE_DIRS "${PCRE_INCLUDE_DIR}")
    set(PCRE_LIBRARIES "${PCRE_LIBRARY}")
    foreach(_PCRE_component ${PCRE_FIND_COMPONENTS})
        string(TOUPPER "${_PCRE_component}" _PCRE_component_upcase)
        set(_PCRE_component_cache "PCRE_${_PCRE_component_upcase}_LIBRARY")
        set(_PCRE_component_cache_release "PCRE_${_PCRE_component_upcase}_LIBRARY_RELEASE")
        set(_PCRE_component_cache_debug "PCRE_${_PCRE_component_upcase}_LIBRARY_DEBUG")
        set(_PCRE_component_lib "PCRE_${_PCRE_component_upcase}_LIBRARIES")
        set(_PCRE_component_found "${_PCRE_component_upcase}_FOUND")
        set(_PCRE_imported_target "PCRE::${_PCRE_component}")
        set(_PCRE_component_lang "C")
        if(_PCRE_component_upcase EQUAL "PCRECPP")
            set(_PCRE_component_lang "CXX")
        endif()
        if(${_PCRE_component_found})
            set("${_PCRE_component_lib}" "${${_PCRE_component_cache}}")
            if(NOT TARGET ${_PCRE_imported_target})
                add_library(${_PCRE_imported_target} STATIC IMPORTED)
                if(PCRE_INCLUDE_DIR)
                    set_target_properties(${_PCRE_imported_target} PROPERTIES
                        INTERFACE_INCLUDE_DIRECTORIES "${PCRE_INCLUDE_DIR}")
                endif()
                if(PCRE_STATIC_RUNTIME)
                    set_target_properties(${_PCRE_imported_target} PROPERTIES
                        INTERFACE_COMPILE_DEFINITIONS "PCRE_STATIC")
                endif()
                if(EXISTS "${${_PCRE_component_cache}}")
                    set_target_properties(${_PCRE_imported_target} PROPERTIES
                        IMPORTED_LINK_INTERFACE_LANGUAGES "${_PCRE_component_lang}"
                        IMPORTED_LOCATION "${${_PCRE_component_cache}}")
                endif()
                if(EXISTS "${${_PCRE_component_cache_release}}")
                    set_property(TARGET ${_PCRE_imported_target} APPEND PROPERTY
                        IMPORTED_CONFIGURATIONS RELEASE)
                    set_target_properties(${_PCRE_imported_target} PROPERTIES
                        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "${_PCRE_component_lang}"
                        IMPORTED_LOCATION_RELEASE "${${_PCRE_component_cache_release}}")
                endif()
                if(EXISTS "${${_PCRE_component_cache_debug}}")
                    set_property(TARGET ${_PCRE_imported_target} APPEND PROPERTY
                        IMPORTED_CONFIGURATIONS DEBUG)
                    set_target_properties(${_PCRE_imported_target} PROPERTIES
                        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "${_PCRE_component_lang}"
                        IMPORTED_LOCATION_DEBUG "${${_PCRE_component_cache_debug}}")
                endif()
            endif()
        endif()
        unset(_PCRE_component_upcase)
        unset(_PCRE_component_cache)
        unset(_PCRE_component_lib)
        unset(_PCRE_component_found)
        unset(_PCRE_imported_target)
        unset(_PCRE_component_lang)
    endforeach()
endif()

if(PCRE_DEBUG)
    message(STATUS "--------FindPCRE.cmake results debug--------")
    message(STATUS "PCRE found: ${PCRE_FOUND}")
    message(STATUS "PCRE_VERSION number: ${PCRE_VERSION}")
    message(STATUS "PCRE_ROOT directory: ${PCRE_ROOT}")
    message(STATUS "PCRE_INCLUDE_DIR directory: ${PCRE_INCLUDE_DIR}")
    message(STATUS "PCRE_LIBRARIES: ${PCRE_LIBRARIES}")

    foreach(program IN LISTS PCRE_programs)
        string(TOUPPER "${program}" program_upcase)
        set(program_lib "PCRE_${program_upcase}_EXECUTABLE")
        message(STATUS "${program} program: ${${program_lib}}")
        unset(program_upcase)
        unset(program_lib)
    endforeach()

    foreach(component IN LISTS PCRE_FIND_COMPONENTS)
        string(TOUPPER "${component}" component_upcase)
        set(component_lib "PCRE_${component_upcase}_LIBRARIES")
        set(component_found "${component_upcase}_FOUND")
        message(STATUS "${component} library found: ${${component_found}}")
        message(STATUS "${component} library: ${${component_lib}}")
        unset(component_upcase)
        unset(component_lib)
        unset(component_found)
    endforeach()
    message(STATUS "----------------")
endif()

unset(PCRE_programs)
