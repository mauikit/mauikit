#.rst:
# FindGradle
# ----------
#
# Provides the ability to build Android AAR libraries using Gradle.
#
# This relies on the Qt provided Gradle, so a Qt for Android installation
# is required.
#
#   gradle_add_aar(<target>
#                  BUIDLFILE build.gradle
#                  NAME <aar-name>)
#
# This builds an Android AAR library using the given ``build.gradle`` file.
#
#   gradle_install_aar(<target>
#                      DESTINATION <dest>)
#
# Installs a Android AAR library that has been created with ``gradle_add_aar``.

#=============================================================================
# Copyright (c) 2019 Volker Krause <vkrause@kde.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

include(CMakeParseArguments)
include(FindPackageHandleStandardArgs)

find_package(Qt5Core REQUIRED)

if (NOT WIN32)
    set(Gradle_EXECUTABLE ${CMAKE_BINARY_DIR}/gradle/gradlew)
else()
    set(Gradle_EXECUTABLE ${CMAKE_BINARY_DIR}/gradle/gradlew.bat)
endif()

get_target_property(_qt_core_location Qt5::Core LOCATION)
get_filename_component(_qt_install_root ${_qt_core_location} DIRECTORY)
get_filename_component(_qt_install_root ${_qt_install_root}/../ ABSOLUTE)

set(_gradle_template_dir ${CMAKE_CURRENT_LIST_DIR})

add_custom_command(OUTPUT ${Gradle_EXECUTABLE}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/gradle
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${_qt_install_root}/src/3rdparty/gradle ${CMAKE_BINARY_DIR}/gradle
)
add_custom_target(gradle DEPENDS ${Gradle_EXECUTABLE})

find_package_handle_standard_args(Gradle DEFAULT_MSG Gradle_EXECUTABLE)

function(gradle_add_aar target)
    cmake_parse_arguments(ARG "" "BUILDFILE;NAME" "" ${ARGN})

    set(_build_root ${CMAKE_CURRENT_BINARY_DIR}/gradle_build/${ARG_NAME})
    configure_file(${_gradle_template_dir}/local.properties.in ${_build_root}/local.properties)
    configure_file(${_gradle_template_dir}/settings.gradle.in ${_build_root}/settings.gradle)
    message(Foo ${ARG_BUILDFILE} ${_build_root})
    configure_file(${ARG_BUILDFILE} ${_build_root}/build.gradle)

    if (CMAKE_BUILD_TYPE MATCHES "[Dd][Ee][Bb][Uu][Gg]")
        set(_aar_suffix "-debug")
        set(_aar_gradleCmd "assembleDebug")
    else()
        set(_aar_suffix "-release")
        set(_aar_gradleCmd "assembleRelease")
    endif()

    if (NOT Qt5Core_VERSION VERSION_LESS 5.14.0) # behavior change in Gradle shipped with Qt 5.14
        set(_aar_suffix "")
    endif()

    file(GLOB_RECURSE _src_files CONFIGURE_DEPENDS "*")
    add_custom_command(
        OUTPUT ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar
        COMMAND ${Gradle_EXECUTABLE} ${_aar_gradleCmd}
        DEPENDS ${Gradle_EXECUTABLE} ${_src_files}
        DEPENDS gradle
        WORKING_DIRECTORY ${_build_root}
    )
    add_custom_target(${target} ALL DEPENDS ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar)
    set_target_properties(${target} PROPERTIES LOCATION ${_build_root}/build/outputs/aar/${ARG_NAME}${_aar_suffix}.aar)
    set_target_properties(${target} PROPERTIES OUTPUT_NAME ${ARG_NAME})
endfunction()

function(gradle_install_aar target)
    cmake_parse_arguments(ARG "" "DESTINATION" "" ${ARGN})
    get_target_property(_loc ${target} LOCATION)
    get_target_property(_name ${target} OUTPUT_NAME)
    install(FILES ${_loc} DESTINATION ${ARG_DESTINATION} RENAME ${_name}.aar)
endfunction()
