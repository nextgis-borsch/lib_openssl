################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015-2019, NextGIS <info@nextgis.com>
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

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(openssl)

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(NOT DEFINED PACKAGE_VENDOR)
    set(PACKAGE_VENDOR NextGIS)
endif()

if(NOT DEFINED PACKAGE_BUGREPORT)
    set(PACKAGE_BUGREPORT info@nextgis.com)
endif()

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_ENGINES_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/engines CACHE INTERNAL "Directory for engines" FORCE)
    set(INSTALL_SHARE_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/ssl CACHE INTERNAL "Directory for data" FORCE)
    set(INSTALL_PARENT_INC_DIR ${INSTALL_INC_DIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES OFF)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR}/ssl CACHE INTERNAL "Installation directory for share data" FORCE)
    set(INSTALL_PARENT_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

set(PACKAGE_NAME ${PROJECT_NAME})
string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

include(util)
include(configure)
enable_testing()

check_version(MAJOR_VER MINOR_VER REL_VER FIX_VER)
set(VERSION ${MAJOR_VER}.${MINOR_VER}.${REL_VER})
report_version(${PROJECT_NAME} ${VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${MAJOR_VER}")
else()
    set(INSTALL_ENGINES_DIR ${INSTALL_LIB_DIR}/engines-${MAJOR_VER}.${MINOR_VER} CACHE INTERNAL "Directory for engines" FORCE)
endif()

include(FindAnyProject)

if(WIN32)
    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} Ws2_32.lib Crypt32.lib)
endif()

if(NOT BUILD_STATIC_LIBS)
    find_anyproject(ZLIB DEFAULT OFF)
    if(ZLIB_FOUND)
        add_definitions(-DZLIB)
        add_definitions(-DZLIB_SHARED)
    else()
        set(OPENSSL_NO_ZIP ON)
        set(OPENSSL_NO_ZIP_DYNAMIC ON)
    endif()
else()
    set(OPENSSL_NO_ZIP ON)
    set(OPENSSL_NO_ZIP_DYNAMIC ON)
endif()

file(GLOB PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h)
set(PUBLIC_HDRS ${PUBLIC_HDRS} ${CMAKE_BINARY_DIR}/openssl/opensslconf.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set(LIB_NAME ${PROJECT_NAME})
set(TARGETS ${LIB_NAME})

add_subdirectory(crypto)
add_subdirectory(ssl)
add_subdirectory(engines)
add_subdirectory(apps)
if(BUILD_TESTING)
    add_subdirectory(test)
endif()

if(WIN32)
    add_subdirectory(util)
    set(RESOURCE_FILES ${CMAKE_BINARY_DIR}/util/openssl.def)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/version32.rc.cmake ${CMAKE_CURRENT_BINARY_DIR}/version32.rc IMMEDIATE @ONLY)
    set(RESOURCE_FILES ${RESOURCE_FILES} ${CMAKE_BINARY_DIR}/version32.rc)
endif()

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${TARGET_OBJECTS} ${PUBLIC_HDRS} ${RESOURCE_FILES})
    set_target_properties(${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        SOVERSION ${MAJOR_VER})
    if(MSVC)
        set_target_properties(${LIB_NAME} PROPERTIES SUFFIX "-${MAJOR_VER}_${MINOR_VER}.dll")
    endif()
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${TARGET_OBJECTS} ${PUBLIC_HDRS})
    set_property(SOURCE ${PUBLIC_HDRS} PROPERTY MACOSX_PACKAGE_LOCATION "Headers/openssl")

    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.openssl.libopenssl
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
#        PUBLIC_HEADER "${PUBLIC_HDRS}"
        VERSION ${VERSION}
        SOVERSION ${MAJOR_VER})

    # Add path to dynamic engines
    if(NOT OPENSSL_NO_DYNAMIC_ENGINE)
        set_target_properties(${LIB_NAME} PROPERTIES INSTALL_RPATH "@loader_path/Resources/engines")
    endif()
else()
    add_library(${LIB_NAME} STATIC ${TARGET_OBJECTS} ${PUBLIC_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES VERSION ${VERSION})
endif()

target_link_extlibraries(${LIB_NAME})

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    install(TARGETS ${TARGETS}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR} )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
    install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}/openssl" COMPONENT dev)
endif()

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# Export package ===============================================================

# Add path to includes to build-tree export
target_include_directories(${TARGETS} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

# Add all targets to the build-tree export set
export(TARGETS ${TARGETS}
    FILE ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Create the OPENSSLConfig.cmake file
configure_file(cmake/PackageConfig.cmake.in
    ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()

# Archiving ====================================================================
set(FULL_VERSION "${VERSION}.${FIX_VER}")
set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${FULL_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${FULL_VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include (CPack)

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    include(summary)
endif()
