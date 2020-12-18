include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/utils
    ${CMAKE_CURRENT_BINARY_DIR}/utils

    ${CMAKE_CURRENT_SOURCE_DIR}/utils/models
    ${CMAKE_CURRENT_BINARY_DIR}/utils/models

    ${CMAKE_CURRENT_SOURCE_DIR}/utils/model_template
    ${CMAKE_CURRENT_BINARY_DIR}/utils/model_template
    
	${CMAKE_CURRENT_SOURCE_DIR}/controls/libs
    ${CMAKE_CURRENT_BINARY_DIR}/controls/libs

    ${CMAKE_CURRENT_SOURCE_DIR}/platforms
    ${CMAKE_CURRENT_BINARY_DIR}/platforms
    
    ${CMAKE_CURRENT_SOURCE_DIR}/platforms/linux
    ${CMAKE_CURRENT_BINARY_DIR}/platforms/linux
    )

set(mauikit_SRCS
    mauikit.cpp
    utils/fmstatic.cpp
    utils/appsettings.cpp
    utils/fmh.cpp
    utils/mauiapp.cpp
    utils/handy.cpp
    utils/models/pathlist.cpp
    utils/model_template/mauilist.cpp
    utils/model_template/mauimodel.cpp
    platforms/abstractplatform.cpp
    platforms/platform.cpp
    )

set(mauikit_HDRS
    mauikit.h
    utils/fmstatic.h
    utils/appsettings.h
    utils/fmh.h
    utils/utils.h
    utils/handy.h
    utils/models/pathlist.h
    utils/mauiapp.h
    utils/model_template/mauilist.h
    utils/model_template/mauimodel.h
    controls/libs/appview.h
    platforms/abstractplatform.h
    platforms/platform.h
    )

if(${COMPONENT_ACCOUNTS})
    message(STATUS "INCLUDING ACCOUNTS COMPONENT")

    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/accounts
        ${CMAKE_CURRENT_BINARY_DIR}/utils/accounts
        )

    set(accounts_SRCS
        utils/accounts/mauiaccounts.cpp
        utils/accounts/accountsdb.cpp
        utils/accounts/accounts.qrc
        )

    set(accounts_HDRS
        utils/accounts/mauiaccounts.h
        utils/accounts/accountsdb.h
        )
    add_definitions(-DCOMPONENT_ACCOUNTS)
endif()

if(${COMPONENT_EDITOR})
    message(STATUS "INCLUDING EDITOR COMPONENT")
    set(editor_SRCS
        utils/editor/documenthandler.cpp
        )

    set(editor_HDRS
        utils/editor/documenthandler.h
        )

    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/editor
        ${CMAKE_CURRENT_BINARY_DIR}/utils/editor
        )
    add_definitions(-DCOMPONENT_EDITOR)
endif()

if(${COMPONENT_FM})
    message(STATUS "INCLUDING FM COMPONENT")

    set(fm_SRCS
        utils/fm/fm.cpp
        utils/fm/fmlist.cpp
        utils/fm/placeslist.cpp
        utils/fm/downloader.cpp
        utils/fm/fileloader.cpp
        utils/fm/thumbnailer.cpp
        )

    set(fm_HDRS
        utils/fm/fm.h
        utils/fm/fmlist.h
        utils/fm/placeslist.h
        utils/fm/downloader.h
        utils/fm/fileloader.h
        utils/fm/thumbnailer.h
        )
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/fm
        ${CMAKE_CURRENT_BINARY_DIR}/utils/fm
        )
    add_definitions(-DCOMPONENT_FM)
endif()

if(${COMPONENT_TAGGING})
    message(STATUS "INCLUDING TAGGING COMPONENT")
    set(tagging_SRCS
        utils/tagging/tagging.cpp
        utils/tagging/tagdb.cpp
        utils/tagging/tagslist.cpp
        utils/tagging/tagging.qrc
        )

    set(tagging_HDRS
        utils/tagging/tag.h
        utils/tagging/tagging.h
        utils/tagging/tagdb.h
        utils/tagging/tagslist.h
        )
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/tagging
        ${CMAKE_CURRENT_BINARY_DIR}/utils/tagging
        )
    add_definitions(-DCOMPONENT_TAGGING)
endif()

if(${COMPONENT_SYNCING})
    message(STATUS "INCLUDING SYNCING COMPONENT")
    set(syncing_SRCS
        utils/syncing/syncing.cpp
        utils/syncing/libwebdavclient/lib/WebDAVClient.cpp
        utils/syncing/libwebdavclient/lib/dto/WebDAVItem.cpp
        utils/syncing/libwebdavclient/lib/utils/Environment.cpp
        utils/syncing/libwebdavclient/lib/utils/NetworkHelper.cpp
        utils/syncing/libwebdavclient/lib/utils/WebDAVReply.cpp
        utils/syncing/libwebdavclient/lib/utils/XMLHelper.cpp
        )

    set(syncing_HDRS
        utils/syncing/syncing.h
        utils/syncing/libwebdavclient/lib/WebDAVClient.hpp
        utils/syncing/libwebdavclient/lib/dto/WebDAVItem.hpp
        utils/syncing/libwebdavclient/lib/utils/Environment.hpp
        utils/syncing/libwebdavclient/lib/utils/NetworkHelper.hpp
        utils/syncing/libwebdavclient/lib/utils/WebDAVReply.hpp
        utils/syncing/libwebdavclient/lib/utils/XMLHelper.hpp
        )
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/syncing
        ${CMAKE_CURRENT_BINARY_DIR}/utils/syncing
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/syncing/libwebdavclient/lib
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/syncing/libwebdavclient/lib/utils
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/syncing/libwebdavclient/lib/dto
        )
    add_definitions(-DCOMPONENT_SYNCING)
endif()

if(${SUPPORT_PLUGINS})
       message(STATUS "INCLUDING PLUGINS SUPPORT")
    set(mauikitplugin_SRCS
        utils/plugin/pluginmanager.cpp
        )

    set(mauikitplugin_HDRS
        utils/plugin/pluginmanager.h
        )
    include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}/utils/plugin/
        ${CMAKE_CURRENT_BINARY_DIR}/utils/plugin )
    add_definitions(-DSUPPORT_PLUGINS)
endif()

#options - for the appimage
option(IS_APPIMAGE_PACKAGE "If set to true then the icons and styled is packaged as well" OFF)

if(ANDROID OR IS_APPIMAGE_PACKAGE)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/maui-style/icons/luv-icon-theme/.git)
        find_package(Git REQUIRED)
        execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 https://github.com/Nitrux/luv-icon-theme.git ${CMAKE_CURRENT_SOURCE_DIR}/maui-style/icons/luv-icon-theme)
    endif()

    list(APPEND mauikit_SRCS maui-style/icons.qrc)
endif()

if (ANDROID)
    add_subdirectory(platforms/android)

    set(mauikit_Android_SRCS
        platforms/android/mauiandroid.cpp
    )

    kde_enable_exceptions(MauiKit PRIVATE)
else()
    #add_subdirectory(csd/libappletdecoration)

    set(mauikit_KDE_SRCS
        platforms/linux/mauilinux.cpp
        platforms/linux/kdeconnect.cpp
        )

    set(mauikit_KDE_HDRS
        platforms/linux/mauilinux.h
        platforms/linux/kdeconnect.h
        )
endif()

add_library(MauiKit

    ${fm_HDRS}
    ${fm_SRCS}

    ${accounts_HDRS}
    ${accounts_SRCS}

    ${editor_HDRS}
    ${editor_SRCS}

    ${syncing_HDRS}
    ${syncing_SRCS}
    
    ${tagging_HDRS}
    ${tagging_SRCS}

    ${mauikit_HDRS}
    ${mauikit_SRCS}

    ${mauikit_Android_SRCS}

    ${mauikit_KDE_HDRS}
    ${mauikit_KDE_SRCS}

    maui-style/style.qrc
    assets.qrc
    mauikit.qrc
)

if(ANDROID)
    target_link_libraries(MauiKit PRIVATE Qt5::AndroidExtras jnigraphics)

    target_include_directories(MauiKit PRIVATE platforms/android)
    install(FILES platforms/android/mauiandroid.h DESTINATION ${KDE_INSTALL_INCLUDEDIR}/MauiKit COMPONENT Devel)

    install(DIRECTORY platforms/android/ DESTINATION ${KDE_INSTALL_DATAROOTDIR}/MauiKitAndroid COMPONENT Devel)

    if (Qt5Core_VERSION VERSION_LESS 5.14.0)
        install(FILES MauiKit-android-dependencies.xml DESTINATION ${KDE_INSTALL_LIBDIR})
    else()
        install(FILES MauiKit-android-dependencies.xml DESTINATION ${KDE_INSTALL_LIBDIR} RENAME MauiKit_${CMAKE_ANDROID_ARCH_ABI}-android-dependencies.xml)
    endif()
elseif(UNIX)
    target_link_libraries(MauiKit 
    PUBLIC 
    KF5::ConfigCore
    KF5::KIOCore
    KF5::KIOWidgets
    KF5::KIOFileWidgets

    PRIVATE 
    KF5::Service 
    KF5::KIONTLM)
    target_include_directories(MauiKit PRIVATE platforms/linux)
endif()

target_link_libraries(MauiKit
    PUBLIC
    Qt5::Core
    Qt5::Sql
    Qt5::Gui
    Qt5::Concurrent
    KF5::I18n
    KF5::CoreAddons    

    PRIVATE
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    Qt5::Network
    Qt5::Xml
    )

if(${COMPONENT_EDITOR})
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS SyntaxHighlighting)
    target_link_libraries(MauiKit PRIVATE KF5::SyntaxHighlighting)
endif()

if(IS_APPIMAGE_PACKAGE)
    target_compile_definitions(MauiKit PUBLIC APPIMAGE_PACKAGE)
endif()

generate_export_header(MauiKit BASE_NAME MauiKit)
install(TARGETS MauiKit EXPORT MauiKitTargets ${INSTALL_TARGETS_DEFAULT_ARGS})

target_include_directories(MauiKit
    INTERFACE "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/MauiKit>")

add_custom_target(copy)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin/org/kde/mauikit)
add_custom_command(TARGET copy PRE_BUILD COMMAND ${CMAKE_COMMAND}
    -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/controls
    ${CMAKE_BINARY_DIR}/bin/org/kde/mauikit/)

add_dependencies(MauiKit copy)

install(DIRECTORY controls/ DESTINATION
    ${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

install(TARGETS MauiKit DESTINATION
    ${KDE_INSTALL_QMLDIR}/org/kde/mauikit)

install(FILES
    ${mauikit_HDRS}
    ${mauikit_KDE_HDRS}
    ${tagging_HDRS}
    ${fm_HDRS}
    ${syncing_HDRS}
    ${editor_HDRS}
    ${accounts_HDRS}
    ${CMAKE_CURRENT_BINARY_DIR}/mauikit_export.h
    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/MauiKit
    COMPONENT Devel)

##INSTALL MAUI STYLE
install(DIRECTORY maui-style DESTINATION ${KDE_INSTALL_QMLDIR}/QtQuick/Controls.2)

##INSTALL THE DECO FOR CSD
install(DIRECTORY csd DESTINATION ${DATA_INSTALL_DIR}/maui)
