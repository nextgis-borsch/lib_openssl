################################################################################
# Project:  openssl
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
################################################################################
# Copyright (C) 2015, 2017, NextGIS <info@nextgis.com>
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

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

include(util)
check_version(MAJOR_VER MINOR_VER REL_VER FIX_VER)
set(VERSION ${MAJOR_VER}.${MINOR_VER}.${REL_VER})
report_version(${PROJECT_NAME} ${VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${MAJOR_VER}")
endif()

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/Applications" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  set(INSTALL_INC_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers CACHE INTERNAL "Installation directory for headers" FORCE)
  set(INSTALL_ENGINES_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/engines CACHE INTERNAL "Directory for engines" FORCE)
  set(INSTALL_SHARE_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/ssl CACHE INTERNAL "Directory for data" FORCE)
  set(INSTALL_PARENT_INC_DIR ${INSTALL_INC_DIR} CACHE INTERNAL "Installation directory for headers" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_EXECUTABLES ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_FULL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_FULL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_FULL_INCLUDEDIR}/openssl CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_FULL_DATADIR}/ssl CACHE INTERNAL "Installation directory for share data" FORCE)
    set(INSTALL_ENGINES_DIR ${INSTALL_LIB_DIR}/engines-${MAJOR_VER}.${MINOR_VER} CACHE INTERNAL "Directory for engines" FORCE)
    set(INSTALL_PARENT_INC_DIR ${CMAKE_INSTALL_FULL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
endif()

include(configure)

include(FindAnyProject)

if(WIN32)
    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} Ws2_32.lib Crypt32.lib) # WS2_32.LIB, GDI32.LIB, ADVAPI32.LIB, CRYPT32.LIB and USER32.LIB
endif()

find_anyproject(ZLIB DEFAULT OFF)
if(ZLIB_FOUND)
    add_definitions(-DZLIB)
    if(BUILD_SHARED_LIBS)
        add_definitions(-DZLIB_SHARED)
    endif()
else()
    set(OPENSSL_NO_ZIP ON)
    set(OPENSSL_NO_ZIP_DYNAMIC ON)
endif()

if(CYGWIN)
    set(LIB_CRYPTO_NAME_OUT "cygcrypto-${MAJOR_VER}.${MINOR_VER}")
    set(LIB_SSL_NAME_OUT "cygssl-${MAJOR_VER}.${MINOR_VER}")
elseif(MINGW)
    set(LIB_CRYPTO_NAME_OUT "libcrypto-${MAJOR_VER}_${MINOR_VER}")
    set(LIB_SSL_NAME_OUT "libssl-${MAJOR_VER}_${MINOR_VER}")
elseif(MSVC)
    set(LIB_CRYPTO_NAME_OUT "libcrypto-${MAJOR_VER}_${MINOR_VER}")
    set(LIB_SSL_NAME_OUT "libssl-${MAJOR_VER}_${MINOR_VER}")
endif()

file(GLOB PUBLIC_HDRS ${CMAKE_CURRENT_SOURCE_DIR}/include/openssl/*.h)
set(PUBLIC_HDRS ${PUBLIC_HDRS} ${CMAKE_BINARY_DIR}/openssl/opensslconf.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

set(LIB_NAME ${PROJECT_NAME})

# $config{dirs} = [ "crypto", "ssl", "engines", "apps", "test", "util", "tools", "fuzz" ];

add_subdirectory(crypto)
add_subdirectory(ssl)
add_subdirectory(engines)
add_subdirectory(apps)

if(WIN32)
    add_subdirectory(util)
    set(RESOURCE_FILES ${CMAKE_BINARY_DIR}/util/openssl.def)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/version32.rc.cmake ${CMAKE_CURRENT_BINARY_DIR}/version32.rc IMMEDIATE @ONLY)
    set(RESOURCE_FILES ${RESOURCE_FILES} ${CMAKE_BINARY_DIR}/version32.rc)
endif()

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${TARGET_OBJECTS} ${PUBLIC_HDRS} ${RESOURCE_FILES})
    set_target_properties(${LIB_NAME} PROPERTIES
        SOVERSION ${MAJOR_VER}
        PUBLIC_HEADER "${PUBLIC_HDRS}")
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${TARGET_OBJECTS} ${PUBLIC_HDRS})
    set_property(SOURCE ${PUBLIC_HDRS} PROPERTY MACOSX_PACKAGE_LOCATION "Headers/openssl")

    set_target_properties(${LIB_NAME} PROPERTIES
        SOVERSION ${MAJOR_VER}
        VERSION ${VERSION}
        FRAMEWORK TRUE
        FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.openssl.libopenssl
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath")

    # Add path to dynamic engines
    if(NOT OPENSSL_NO_DYNAMIC_ENGINE)
        set_target_properties(${LIB_NAME} PROPERTIES INSTALL_RPATH "@loader_path/Resources/engines")
    endif()
else()
    add_library(${LIB_NAME} STATIC ${TARGET_OBJECTS} ${PUBLIC_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES
        SOVERSION ${MAJOR_VER}
        PUBLIC_HEADER "${PUBLIC_HDRS}")
endif()

target_link_extlibraries(${LIB_NAME})

if (REGISTER_PACKAGE)
    export(TARGETS ${LIB_NAME} FILE ${PROJECT_NAME}-exports.cmake)

    set(EXPORT_PACKAGE_NAME OpenSSL)
    set(EXPORT_PACKAGE_NAME_UPPER OPENSSL)
    set(EXPORT_PACKAGE_LIB_NAME ${PROJECT_NAME})
    set(EXPORT_PACKAGE_LIB_NAMES ssl crypto)

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${LIB_NAME} FILE ${PROJECT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME}
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
        FRAMEWORK DESTINATION "${INSTALL_LIB_DIR}"
        PUBLIC_HEADER DESTINATION "${INSTALL_INC_DIR}"
    )
endif()

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    include(summary)
endif()
