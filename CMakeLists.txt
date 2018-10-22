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
Sql Core Quick Gui Svg QuickControls2 Network DBus)
ecm_find_qmlmodule(QtGraphicalEffects 1.0)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/src
        
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/tagging 
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/editor
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/editor
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/syncing
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/syncing
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/fm
    ${CMAKE_CURRENT_BINARY_DIR}/src/fm

    ${CMAKE_CURRENT_SOURCE_DIR}/src/kde
    ${CMAKE_CURRENT_BINARY_DIR}/src/kde
    )

set(mauikit_SRCS
    src/mauikit.cpp  
    src/utils/handy.cpp
    )
    
set(mauikit_HDRS
    src/mauikit.h
    src/utils.h
    src/utils/handy.h
    )
    
set(editor_SRCS
    src/utils/editor/documenthandler.cpp
    )    
    
set(editor_HDRS
    src/utils/editor/documenthandler.cpp
    )
    
set(fm_SRCS
    src/fm/fm.cpp
    src/fm/fmdb.cpp
    src/fm/fmmodel.cpp
    src/fm/fmlist.cpp
    )    
    
set(fm_HDRS
    src/fm/fmh.h
    src/fm/fm.h
    src/fm/fmdb.h
    src/fm/fmmodel.h
    src/fm/fmlist.h
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

    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras Xml WebView)
    qt5_add_resources(MauiAndroid_RESOURCES src/android/android.qrc src/android/icons.qrc)
    
    set(MAUIANDROID_LIBS
        Qt5::Xml
        Qt5::AndroidExtras
        Qt5::WebView
        )

    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/src/android/icons/luv-icon-theme/.git)
        find_package(Git REQUIRED)
        execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 https://github.com/Nitrux/luv-icon-theme.git ${CMAKE_SOURCE_DIR}/src/android/icons/luv-icon-theme)
    endif()
    set(mauikit_Android_SRCS
        src/android/mauiandroid.cpp
        ${MauiAndroid_RESOURCES}
        ${MauiAndroid_icons_RESOURCES}
        )
else()
	find_package(Qt5 REQUIRED COMPONENTS WebEngine)
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
        Qt5::WebEngine
        )          
endif()
# set(CMAKE_AUTORCC ON)

qt5_add_resources(mauikit_ASSETS ${CMAKE_CURRENT_SOURCE_DIR}/assets.qrc)
qt5_add_resources(tagging_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging/tagging.qrc)
qt5_add_resources(fm_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/fm/fm.qrc)

# qt5_add_resources(mauikit_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/mauikit.qrc)

add_library(MauiKit 

${fm_HDRS}
${fm_SRCS}
${fm_RESOURCES}

${editor_HDRS}
${editor_SRCS}

${tagging_HDRS}
${tagging_SRCS}
${tagging_RESOURCES}

${mauikit_HDRS} 
${mauikit_SRCS} 
${mauikit_RESOURCES} 
${mauikit_ASSETS}

${mauikit_Android_SRCS}

${mauikit_KDE_HDRS}
${mauikit_KDE_SRCS}
)

target_link_libraries(MauiKit
    PUBLIC
    Qt5::Core
    Qt5::Sql
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Gui
    Qt5::Network
    ${MAUIKDE_KF5LIBS}
    ${MAUIANDROID_LIBS}
    )

if (ANDROID)
    kde_enable_exceptions(MauiKit PRIVATE)
    target_include_directories(MauiKit PRIVATE src/android)
    install(FILES src/android/mauiandroid.h DESTINATION ${KDE_INSTALL_INCLUDEDIR}/MauiKit COMPONENT Devel)

    install(DIRECTORY src/android/ DESTINATION ${KDE_INSTALL_DATAROOTDIR}/MauiKitAndroid COMPONENT Devel)
endif()

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

install(DIRECTORY src/controls/ DESTINATION 
${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

install(TARGETS MauiKit DESTINATION 
${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

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
