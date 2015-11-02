################################################################################
# Project:  external projects
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
# Copyright (C) 2015, Dmitry Baryshnikov <dmitry.baryshnikov@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

include(ExternalProject)

if(NOT DEFINED EP_BASE OR EP_BASE STREQUAL "")
    set(EP_BASE "${CMAKE_BINARY_DIR}/third-party")
endif()    
set_property(DIRECTORY PROPERTY "EP_BASE" ${EP_BASE})

if(NOT DEFINED EP_URL)
    set(EP_URL "https://github.com/nextgis-extra")
endif()

macro(set_libraries libs is_shared bld_dir release_name debug_name)
    if (MSVC)
        if(is_shared)
            set(${libs}
                    debug "${bld_dir}/Debug/${CMAKE_SHARED_LIBRARY_PREFIX}${debug_name}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                    optimized "${bld_dir}/Release/${CMAKE_SHARED_LIBRARY_PREFIX}${release_name}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                CACHE FILEPATH "lib file path")
        else()
            set(${libs}
                    debug"${bld_dir}/Debug/${CMAKE_STATIC_LIBRARY_PREFIX}${debug_name}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                    optimized "${bld_dir}/Release/${CMAKE_STATIC_LIBRARY_PREFIX}${release_name}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                CACHE FILEPATH "lib file path")
        endif()
    else()
        if(is_shared)
            set(${libs}
                "${bld_dir}/${CMAKE_SHARED_LIBRARY_PREFIX}${debug_name}${CMAKE_SHARED_LIBRARY_SUFFIX}"
            CACHE FILEPATH "lib file path")
        else()
            set(${libs}
                "${bld_dir}/${CMAKE_STATIC_LIBRARY_PREFIX}${release_name}${CMAKE_STATIC_LIBRARY_SUFFIX}"
            CACHE FILEPATH "lib file path")
        endif()            
    endif()    
    
    mark_as_advanced(${libs})
endmacro()    

macro(use_zlib USE_BY_DEFAULT)
#ZLIB_FOUND ZLIB_INCLUDE_DIRS ZLIB_LIBRARIES
    option(USE_ZLIB "Set to ON to enable zlib support" ${USE_BY_DEFAULT})
    if(USE_ZLIB)
        option(USE_ZLIB_INTERNAL "Set ON to use internal libz" OFF)
        if(USE_ZLIB_INTERNAL)     
            option(USE_ZLIB_INTERNAL_SHARED "Set ON to use shared libz" ON)    
            set (ZLIB_SRC_DIR ${EP_BASE}/Source/zlib)
            set (ZLIB_BLD_DIR ${EP_BASE}/Build/zlib)
            # external project
            
            ExternalProject_Add(zlib
                GIT_REPOSITORY ${EP_URL}/lib_z
                CMAKE_ARGS
                -DEP_BASE=${EP_BASE} 
                -DEP_URL=${EP_URL}
                -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
                INSTALL_COMMAND "" # no install
            )   

            TODO: get lib names from external project
            ExternalProject_Get_Property(zlib OUTPUT_NAME)
            
            set (ZLIB_INCLUDE_DIRS ${ZLIB_SRC_DIR} ${ZLIB_BLD_DIR} CACHE PATH "zlib include paths")  
            mark_as_advanced(ZLIB_INCLUDE_DIRS)

            message(STATUS "zlib targer ${LIBRARIES}")
            
            if (MSVC)
                set_libraries(ZLIB_LIBRARIES USE_ZLIB_INTERNAL_SHARED ${ZLIB_BLD_DIR} "zlib" "zlibd") 
            else()
                set_libraries(ZLIB_LIBRARIES USE_ZLIB_INTERNAL_SHARED ${ZLIB_BLD_DIR} "z" "z")         
            endif()
            
            set(ZLIB_FOUND ON CACHE BOOL "is zlib found")
            mark_as_advanced(ZLIB_FOUND) 
        else()
            find_package(ZLIB REQUIRED)
        endif() 
    endif()
endmacro()
