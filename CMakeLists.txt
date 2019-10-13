cmake_minimum_required(VERSION 3.12)

set(REQUIRED_QT_VERSION 5.10.0)
set(REQUIRED_KF5_VERSION 5.60.0)

set(CMAKE_CXX_STANDARD 17)

set(MAUIKIT_VERSION 1.0.0)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(AUTOMOC_MOC_OPTIONS -Muri=org.kde.maui)

project(mauikit VERSION ${MAUIKIT_VERSION})

find_package(ECM 5.45.0 NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} 
    ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

#DEFAULT COMPONENTS DEFINITIONS
add_compile_definitions(
    COMPONENT_EDITOR=ON
    COMPONENT_FM=ON
	COMPONENT_ACCOUNTS=ON
    COMPONENT_TERMINAL=ON
    COMPONENT_STORE=ON
    COMPONENT_TAGGING=ON
    COMPONENT_SYNCING=ON
    )
    
get_directory_property(MYDEFS COMPILE_DEFINITIONS)    
    MESSAGE( STATUS "Compile defs contain: " ${MYDEFS} )

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

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/src
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/models
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/models
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/model_template
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils/model_template
    
    ${CMAKE_CURRENT_SOURCE_DIR}/src/kde
    ${CMAKE_CURRENT_BINARY_DIR}/src/kde
    )

set(mauikit_SRCS
    src/mauikit.cpp
    src/utils/fmstatic.cpp
    src/utils/mauiapp.cpp
    src/utils/handy.cpp
    src/utils/models/pathlist.cpp
    src/utils/model_template/mauilist.cpp
    src/utils/model_template/mauimodel.cpp
    )    

set(mauikit_HDRS
    src/mauikit.h
    src/utils/fmstatic.h
    src/utils/fmh.h
    src/utils/utils.h
    src/utils/handy.h
    src/utils/models/pathlist.h
    src/utils/mauiapp.h
    src/utils/model_template/mauilist.h
    src/utils/model_template/mauimodel.h
    )

if(MYDEFS MATCHES "^COMPONENT_ACCOUNTS=ON" OR MYDEFS MATCHES ";COMPONENT_ACCOUNTS=ON")
    message(STATUS "INCLUDING ACCOUNTS COMPONENT")
    
    include_directories(        
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/accounts
        ${CMAKE_CURRENT_BINARY_DIR}/src/utils/accounts
        )
    
    set(accounts_SRCS
        src/utils/accounts/mauiaccounts.cpp
        src/utils/accounts/accountsdb.cpp
        )
    
    set(accounts_HDRS
        src/utils/accounts/mauiaccounts.h
        src/utils/accounts/accountsdb.h
        )    
    qt5_add_resources(accounts_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/accounts/accounts.qrc) 
endif()

if(MYDEFS MATCHES "^COMPONENT_EDITOR=ON" OR MYDEFS MATCHES ";COMPONENT_EDITOR=ON")
    message(STATUS "INCLUDING EDITOR COMPONENT")
    set(editor_SRCS
        src/utils/editor/documenthandler.cpp
        src/utils/editor/syntaxhighlighterutil.cpp
        )
    
    set(editor_HDRS
        src/utils/editor/documenthandler.h
        src/utils/editor/syntaxhighlighterutil.h
        )
    
    include_directories(        
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/editor
        ${CMAKE_CURRENT_BINARY_DIR}/src/utils/editor
        )
endif()

if(MYDEFS MATCHES "^COMPONENT_FM=ON" OR MYDEFS MATCHES ";COMPONENT_FM=ON")
    message(STATUS "INCLUDING FM COMPONENT")
    
    set(fm_SRCS
        src/fm/fm.cpp
        src/fm/fmlist.cpp
        src/fm/placeslist.cpp        
        )
    
    set(fm_HDRS
        src/fm/fm.h
        src/fm/fmlist.h
        src/fm/placeslist.h
        )
    include_directories(        
        ${CMAKE_CURRENT_SOURCE_DIR}/src/fm
        ${CMAKE_CURRENT_BINARY_DIR}/src/fm
        )
endif()

if(MYDEFS MATCHES "^COMPONENT_TAGGING=ON" OR MYDEFS MATCHES ";COMPONENT_TAGGING=ON")
    message(STATUS "INCLUDING TAGGING COMPONENT")
    set(tagging_SRCS
        src/utils/tagging/tagging.cpp
        src/utils/tagging/tagdb.cpp
        src/utils/tagging/tagsmodel.cpp
        src/utils/tagging/tagslist.cpp
        )
    
    set(tagging_HDRS
        src/utils/tagging/tag.h
        src/utils/tagging/tagging.h
        src/utils/tagging/tagdb.h
        src/utils/tagging/tagsmodel.h
        src/utils/tagging/tagslist.h
        )
    qt5_add_resources(tagging_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging/tagging.qrc)
    include_directories(        
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/tagging
        ${CMAKE_CURRENT_BINARY_DIR}/src/utils/tagging
        )
endif()

if(MYDEFS MATCHES "^COMPONENT_SYNCING=ON" OR MYDEFS MATCHES ";COMPONENT_SYNCING=ON")
    message(STATUS "INCLUDING SYNCING COMPONENT")
    set(syncing_SRCS
        src/utils/syncing/syncing.cpp
        src/utils/syncing/libwebdavclient/lib/WebDAVClient.cpp
        src/utils/syncing/libwebdavclient/lib/dto/WebDAVItem.cpp
        src/utils/syncing/libwebdavclient/lib/utils/Environment.cpp
        src/utils/syncing/libwebdavclient/lib/utils/NetworkHelper.cpp
        src/utils/syncing/libwebdavclient/lib/utils/WebDAVReply.cpp
        src/utils/syncing/libwebdavclient/lib/utils/XMLHelper.cpp
        )
    
    set(syncing_HDRS
        src/utils/syncing/syncing.h
        src/utils/syncing/libwebdavclient/lib/WebDAVClient.hpp
        src/utils/syncing/libwebdavclient/lib/dto/WebDAVItem.hpp
        src/utils/syncing/libwebdavclient/lib/utils/Environment.hpp
        src/utils/syncing/libwebdavclient/lib/utils/NetworkHelper.hpp
        src/utils/syncing/libwebdavclient/lib/utils/WebDAVReply.hpp
        src/utils/syncing/libwebdavclient/lib/utils/XMLHelper.hpp
        )
    include_directories(   
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/syncing
        ${CMAKE_CURRENT_BINARY_DIR}/src/utils/syncing 
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/syncing/libwebdavclient/lib
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/syncing/libwebdavclient/lib/utils
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/syncing/libwebdavclient/lib/dto	
        )
endif()

if(MYDEFS MATCHES "^COMPONENT_STORE=ON" OR MYDEFS MATCHES ";COMPONENT_STORE=ON")
    message(STATUS "INCLUDING STORE COMPONENT")
    set(store_SRCS
        src/utils/store/store.cpp
        src/utils/store/storemodel.cpp
        src/utils/store/storelist.cpp
        )
    
    set(store_HDRS
        src/utils/store/store.h    
        src/utils/store/storemodel.h
        src/utils/store/storelist.h
        )
    
    qt5_add_resources(store_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/store/store.qrc)
    
    include_directories(        
        ${CMAKE_CURRENT_SOURCE_DIR}/src/utils/store
        ${CMAKE_CURRENT_BINARY_DIR}/src/utils/store	
        )
endif()
#use dbus on linux, bsd etc, but not andoid and apple stuff

#options - for the appimage
option(IS_APPIMAGE_PACKAGE "If set to true then the icons and styled is packaged as well")

if(ANDROID OR IS_APPIMAGE_PACKAGE OR MAUIKIT_STYLE)
    qt5_add_resources(MauiIcon_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/android/icons.qrc)
    qt5_add_resources(MauiStyle_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/maui-style/style.qrc)
    
    if (NOT EXISTS ${CMAKE_SOURCE_DIR}/src/android/icons/luv-icon-theme/.git)
        find_package(Git REQUIRED)
        execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 https://github.com/milohr/luv-icon-theme.git ${CMAKE_SOURCE_DIR}/src/android/icons/luv-icon-theme)
    endif()
    
    set(mauikit_style_QRCS
        ${MauiIcon_RESOURCES}
        ${MauiStyle_RESOURCES}
        )
endif()

find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config Service KIO ConfigWidgets)

if(MYDEFS MATCHES "^COMPONENT_EDITOR=ON" OR MYDEFS MATCHES ";COMPONENT_EDITOR=ON")
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS SyntaxHighlighting)
    set(COMPONENT_EDITOR_LIBS
        KF5::SyntaxHighlighting
        )        
endif()

if(MYDEFS MATCHES "^COMPONENT_STORE=ON" OR MYDEFS MATCHES ";COMPONENT_STORE=ON")
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS Attica)
    set(COMPONENT_STORE_LIBS
        KF5::Attica
        )        
endif()

set(MAUIKDE_KF5LIBS
    KF5::ConfigCore
    KF5::Notifications
    KF5::I18n
    KF5::Service
    KF5::KIOCore
    KF5::KIOWidgets
    KF5::KIOFileWidgets
    KF5::Service
    KF5::KIONTLM
    KF5::ConfigWidgets
    ${COMPONENT_EDITOR_LIBS}
    ${COMPONENT_STORE_LIBS}
)

if(ANDROID)
    find_package(Gradle REQUIRED)
    add_subdirectory(src/android)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras Xml WebView Network)    
    set(MAUIANDROID_LIBS
        Qt5::Xml
        Qt5::AndroidExtras
        Qt5::Network
        Qt5::WebView
        )  

    set(mauikit_Android_SRCS
        src/android/mauiandroid.cpp
        )
else()
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)

    set(mauikit_KDE_SRCS
        src/kde/mauikde.cpp
        src/kde/kdeconnect.cpp
        )
    
    set(mauikit_KDE_HDRS
        src/kde/mauikde.h
        src/kde/kdeconnect.h
        )

    list(APPEND MAUIKDE_KF5LIBS
        Qt5::WebEngine
        )
endif()

qt5_add_resources(mauikit_ASSETS ${CMAKE_CURRENT_SOURCE_DIR}/assets.qrc)
qt5_add_resources(mauikit_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/mauikit.qrc)

add_library(MauiKit 
    
    ${fm_HDRS}
    ${fm_SRCS}
    
    ${accounts_HDRS}
    ${accounts_SRCS}
    ${accounts_RESOURCES}
    
    ${editor_HDRS}
    ${editor_SRCS}
    
    ${syncing_HDRS}
    ${syncing_SRCS}
    
    ${store_SRCS}
    ${store_HDRS}
    ${store_RESOURCES}
    
    ${tagging_HDRS}
    ${tagging_SRCS}
    ${tagging_RESOURCES}
    
    ${mauikit_HDRS}
    ${mauikit_SRCS}
    ${mauikit_RESOURCES}
    ${mauikit_ASSETS}
    
    ${MauiIcon_RESOURCES}
    ${MauiStyle_RESOURCES}
    
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
    Qt5::Xml
    ${MAUIKDE_KF5LIBS}
    ${MAUIANDROID_LIBS}
    )

if(IS_APPIMAGE_PACKAGE)
    target_compile_definitions(MauiKit PUBLIC APPIMAGE_PACKAGE)
endif()

if (ANDROID)

    target_link_libraries(MauiKit PRIVATE jnigraphics)

    kde_enable_exceptions(MauiKit PRIVATE)
    target_include_directories(MauiKit PRIVATE src/android)
    install(FILES src/android/mauiandroid.h DESTINATION ${KDE_INSTALL_INCLUDEDIR}/MauiKit COMPONENT Devel)
    
    install(DIRECTORY src/android/ DESTINATION ${KDE_INSTALL_DATAROOTDIR}/MauiKitAndroid COMPONENT Devel)

    install(FILES MauiKit-android-dependencies.xml DESTINATION ${KDE_INSTALL_LIBDIR})
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
    ${syncing_HDRS}
    ${store_HDRS}
    ${accounts_HDRS}
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
