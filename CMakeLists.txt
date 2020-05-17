cmake_minimum_required(VERSION 3.10)

set(REQUIRED_QT_VERSION 5.10.0)
set(REQUIRED_KF5_VERSION 5.60.0)

set(CMAKE_CXX_STANDARD 17)

set(MAUIKIT_VERSION 1.1.1)

set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.maui)

project(mauikit VERSION ${MAUIKIT_VERSION})

find_package(ECM 5.45.0 NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} 
    ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

#DEFAULT COMPONENTS DEFINITIONS
option(COMPONENT_EDITOR "Build editor component" ON)
option(COMPONENT_FM "Build filemanager component" ON)
option(COMPONENT_ACCOUNTS "Build accounts component" ON)
option(COMPONENT_TERMINAL "Build terminal component" ON)
option(COMPONENT_STORE "Build store component" ON)
option(COMPONENT_TAGGING "Build tagging component" ON)
option(COMPONENT_SYNCING "Build syncing component" ON)

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
    Sql Core Quick Gui Svg QuickControls2 Network DBus Xml)
    
ecm_find_qmlmodule(QtGraphicalEffects 1.0)
ecm_find_qmlmodule(QtQuick.Shapes 1.0)

if(ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)
    find_package(Gradle REQUIRED)
endif()

find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config Service KIO ConfigWidgets)

add_subdirectory(src)

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
