cmake_minimum_required(VERSION 3.0)

# Builds list of sub-directories (relative paths).
# Parameters:
#   files    - files or directories to scan (list).
#   base_dir - directory being considered as a base if file name is relative.
#   results  - name of variable to store list of sub-directories.
function(zbx_list_subdirs files base_dir results)
    get_filename_component(cmake_base_dir "${base_dir}" ABSOLUTE)
    file(TO_CMAKE_PATH "${cmake_base_dir}" cmake_base_dir)

    set("${cmake_base_dir}" case_normalized_base_dir)
    if(CMAKE_HOST_WIN32)
        string(TOUPPER "${cmake_base_dir}" case_normalized_base_dir)
    endif()

    set(subdirs )
    set(subdir_found FALSE)
    foreach(file IN LISTS files)
        get_filename_component(file_path "${file}" PATH)        
        if(NOT IS_ABSOLUTE "${file_path}")
            file(TO_CMAKE_PATH "${file_path}" file_path)
            set("${cmake_base_dir}/${file_path}" file_path)
        endif()
        get_filename_component(file_path "${file_path}" ABSOLUTE)
        file(TO_CMAKE_PATH "${file_path}" file_path)

        set("${file_path}" case_normalized_file_path)
        if(CMAKE_HOST_WIN32)
            string(TOUPPER "${file_path}" case_normalized_file_path)
        endif()        

        string(FIND "${case_normalized_file_path}" "${case_normalized_base_dir}" start_pos)
        if(start_pos EQUAL 0)
            file(RELATIVE_PATH subdir "${cmake_base_dir}" "${file_path}")
            list(APPEND subdirs "${subdir}")
            set(subdir_found TRUE)
        endif()
    endforeach()        
    if(${subdir_found})
        list(REMOVE_DUPLICATES subdirs)
    endif()

    set(${results} "${subdirs}" PARENT_SCOPE)
endfunction()

# Filters list of files (or directories) by specified location (directory). 
# Only files located directly in specified location are returned.
# Parameters:
#   files      - files or directories to filter (list).
#   base_dir   - directory being considered as a base for files (directories) 
#                which name is not absolute.
#   filter_dir - directory which is used to filter souce list. 
#                Only files located directly in this directory are returned.
#   results    - name of variable to store filtered list.
function(zbx_filter_files files base_dir filter_dir results)
    get_filename_component(cmake_base_dir "${base_dir}" ABSOLUTE)
    get_filename_component(cmake_filter_dir "${filter_dir}" ABSOLUTE)
    file(TO_CMAKE_PATH "${cmake_base_dir}"   cmake_base_dir)
    file(TO_CMAKE_PATH "${cmake_filter_dir}" cmake_filter_dir)
    if(CMAKE_HOST_WIN32)
        string(TOUPPER "${cmake_filter_dir}" cmake_filter_dir)
    endif()

    set(filtered_files )
    foreach(file IN LISTS files)
        get_filename_component(file_path "${file}" PATH)
        if(NOT IS_ABSOLUTE "${file_path}")
            file(TO_CMAKE_PATH "${file_path}" file_path)
            set("${cmake_base_dir}/${file_path}" file_path)
        endif()
        get_filename_component(file_path "${file_path}" ABSOLUTE)
        file(TO_CMAKE_PATH "${file_path}" file_path)
        if(CMAKE_HOST_WIN32)
            string(TOUPPER "${file_path}" file_path)
        endif()        
        if("${file_path}" STREQUAL "${cmake_filter_dir}")
            list(APPEND filtered_files "${file}")
        endif()
    endforeach()

    set(${results} "${filtered_files}" PARENT_SCOPE)
endfunction()

# Builds source groups based on relative location of files.
# Files located out of base directroy are not included into any source group.
# Parameters:
#   base_group_name - base source group name for base directory (refer to base_dir parameter).
#   base_dir        - base directory being considered as a base for files and correlating 
#                     with base source group name. 
#   files           - files (list) to associate with source groups built according to relative 
#                     (comparing with base_dir) paths.
function(zbx_dir_source_group base_group_name base_dir files)
    zbx_list_subdirs("${files}" "${base_dir}" subdirs)
    foreach(subdir IN LISTS subdirs)
        string(REPLACE "/" "\\" subdir_group_name "${base_group_name}/${subdir}")
        zbx_filter_files("${files}" "${CMAKE_CURRENT_BINARY_DIR}" "${base_dir}/${subdir}" subdir_files)
        source_group("${subdir_group_name}" FILES ${subdir_files})
    endforeach()
endfunction()

# Sets output directory for specified target and all build configurations.
# Parameters:
#   target_name - name of the target to specify output directory.
#   output_dir  - output directory to specify.
function(zbx_set_target_output_dir target_name output_dir)
    set(configuration_types ${CMAKE_CONFIGURATION_TYPES})
    if(NOT configuration_types AND DEFINED CMAKE_BUILD_TYPE)
        list(APPEND configuration_types ${CMAKE_BUILD_TYPE})
    endif()
    foreach(configuration_type IN LISTS configuration_types)
        string(TOUPPER ${configuration_type} configuration_type_upper_case)
        set_target_properties(${target_name} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY_${configuration_type_upper_case} "${output_dir}"
            LIBRARY_OUTPUT_DIRECTORY_${configuration_type_upper_case} "${output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_${configuration_type_upper_case} "${output_dir}")
    endforeach()
endfunction()

function(zbx_list_to_string list separator result)
    set(str )
    set(first_item TRUE)
    foreach(item IN LISTS list)
        if(first_item)
            set(str "${item}")
            set(first_item FALSE)
        else()
            set(str "${str}${separator}${item}")
        endif()
    endforeach()
    set(${result} "${str}" PARENT_SCOPE)
endfunction()
