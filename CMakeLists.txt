cmake_minimum_required(VERSION 3.0)

set(REQUIRED_QT_VERSION 5.8.0)

set(CMAKE_CXX_STANDARD 11)

set(MAUIKIT_VERSION 0.0.5)

set(CMAKE_AUTOMOC ON)
set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.maui)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

project(mauikit VERSION ${MAUIKIT_VERSION})

find_package(ECM 5.45.0 NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} 
${ECM_KDE_MODULE_DIR})

include(GenerateExportHeader)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(CMakePackageConfigHelpers)
include(ECMPoQmTools)
include(ECMQMLModules)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(ECMQtDeclareLoggingCategory)
include(ECMAddQch)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml 
Sql Core Quick Gui Svg QuickControls2)
ecm_find_qmlmodule(QtGraphicalEffects 1.0)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/src
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/tagging
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/fm
    ${CMAKE_CURRENT_BINARY_DIR}/src/fm

    ${CMAKE_CURRENT_SOURCE_DIR}/src/kde
    ${CMAKE_CURRENT_BINARY_DIR}/src/kde
    )

set(mauikit_SRCS
    src/mauikit.cpp   
    )
    
set(mauikit_HDRS
    src/mauikit.h
    src/utils.h  
    )
    
set(fm_SRCS
    src/fm/fm.cpp
    src/fm/fmdb.cpp
    )    
    
set(fm_HDRS
    src/fm/fm.h
    src/fm/fmh.h
    src/fm/fmdb.h
    )
    
set(tagging_SRCS
    src/utils/tagging/tagging.cpp
    src/utils/tagging/tagdb.cpp
    )
    
set(tagging_HDRS
    src/utils/tagging/tagging.h
    src/utils/tagging/tagdb.h
    src/utils/tagging/tag.h
    )

#use dbus on linux, bsd etc, but not andoid and apple stuff
if(ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras Xml)
    set(mauikit_Android Qt5::AndroidExtras)
    set(mauikit_Android_SRCS
        src/android/mauiandroid.h
        src/android/mauiandroid.cpp
        )
        
    qt5_add_resources(MauiAndroid_RESOURCES 
        ${CMAKE_CURRENT_SOURCE_DIR}/src/android/android.qrc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/android/icons.qrc
        )
    
    set(MAUIANDROID_LIBS
        Qt5::Xml
        Qt5::AndroidExtras
        )
else()
    find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications 
Config Service KIO ConfigWidgets)
    set(mauikit_KDE_SRCS
        src/kde/mauikde.cpp
        src/kde/kdeconnect.cpp
        )
        
    set(mauikit_KDE_HDRS
        src/kde/mauikde.h
        src/kde/kdeconnect.h
        )
     
    set(MAUIKDE_KF5LIBS 
        KF5::ConfigCore
        KF5::Notifications
        KF5::I18n KF5::Service
        KF5::KIOCore
        KF5::KIOWidgets
        KF5::KIOFileWidgets
        KF5::Service
        KF5::KIONTLM
        KF5::ConfigWidgets
        )        
        
    set(mauikit_KDE KF5::ConfigCore KF5::Notifications KF5::I18n KF5::Service 
KF5::KIOCore KF5::KIOWidgets KF5::KIOFileWidgets KF5::KIONTLM)
endif()
# set(CMAKE_AUTORCC ON)

qt5_add_resources(mauikit_ASSETS ${CMAKE_CURRENT_SOURCE_DIR}/assets.qrc)
qt5_add_resources(tagging_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging/tagging.qrc)
qt5_add_resources(fm_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/fm/fm.qrc)

# qt5_add_resources(mauikit_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/mauikit.qrc)

add_library(MauiKit 

${tagging_HDRS}
${tagging_SRCS}
${tagging_RESOURCES}

${fm_HDRS}
${fm_SRCS}
${fm_RESOURCES}

${mauikit_HDRS} 
${mauikit_SRCS} 
${mauikit_RESOURCES} 
${mauikit_ASSETS}

${mauikit_Android_SRCS}
${MauiAndroid_RESOURCES}

${mauikit_KDE_HDRS}
${mauikit_KDE_SRCS})

# add_library(FM ${fm_SRCS})
# add_library(Tagging ${tagging_SRCS})

# add_definitions(-DMAUI_APP)

target_link_libraries(MauiKit
#     PRIVATE
#     ${mauikit_RESOURCES}
#     ${tagging_RESOURCES}
   
    PUBLIC
    Qt5::Core
    Qt5::Sql
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Gui
    ${MAUIKDE_KF5LIBS}
    ${MAUIANDROID_LIBS}
    )
    
generate_export_header(MauiKit BASE_NAME MauiKit)
install(TARGETS MauiKit EXPORT MauiKitTargets ${INSTALL_TARGETS_DEFAULT_ARGS})

target_include_directories(MauiKit 
INTERFACE "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/MauiKit>")

add_custom_target(copy)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin/org/kde/mauikit)
add_custom_command(TARGET copy PRE_BUILD COMMAND ${CMAKE_COMMAND} 
-E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/src/controls 
${CMAKE_BINARY_DIR}/bin/org/kde/mauikit/)

add_dependencies(MauiKit copy)

message(STATUS "Instralling controls to : " ${KDE_INSTALL_QMLDIR})
install(DIRECTORY src/controls/ DESTINATION 
${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

message(STATUS ${KDE_INSTALL_QMLDIR})
install(TARGETS MauiKit DESTINATION 
${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

message(STATUS ${KDE_INSTALL_INCLUDEDIR})
install(FILES
            ${mauikit_HDRS} 
            ${mauikit_KDE_HDRS}
            ${tagging_HDRS}
            ${fm_HDRS}
            ${CMAKE_CURRENT_BINARY_DIR}/mauikit_export.h
        DESTINATION ${KDE_INSTALL_INCLUDEDIR}/MauiKit
        COMPONENT Devel)
        
##INSTALL MAUI STYLE
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/maui-style DESTINATION ${KDE_INSTALL_QMLDIR}/QtQuick/Controls.2)   
   
##CMAKE PARTS   
   
set(CMAKECONFIG_INSTALL_DIR "${KDE_INSTALL_CMAKEPACKAGEDIR}/MauiKit")

ecm_setup_version(${MAUIKIT_VERSION}
    VARIABLE_PREFIX MAUIKIT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/mauikit_version.h"
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/MauiKitConfigVersion.cmake"
    SOVERSION 5
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/MauiKitConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MauiKitConfig.cmake"
    INSTALL_DESTINATION  ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS  KF5_INCLUDE_INSTALL_DIR CMAKE_INSTALL_PREFIX
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MauiKitConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MauiKitConfigVersion.cmake"
    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
    COMPONENT Devel
)

install(EXPORT MauiKitTargets
    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
    FILE MauiKitTargets.cmake
)

        
