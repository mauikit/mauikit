cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)


set(KF5_MIN_VERSION "5.38.0")
set(KF5_LOCALE_PREFIX "")

find_package(ECM ${KF5_MIN_VER} REQUIRED NO_MODULE)
find_package(ECM 0.0.11 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(KDecoration2 REQUIRED)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS CoreAddons Declarative Plasma PlasmaQuick)

include(ECMQMLModules)
include(CheckIncludeFiles)
include(KDECMakeSettings)
include(KDEInstallDirs)

set(KDECORATION2_VERSION_MINOR ${KDecoration2_VERSION_MINOR})
message(STATUS "KDECORATION2 VERSION MINOR : ${KDECORATION2_VERSION_MINOR}")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config-decoration.h.cmake
               ${CMAKE_CURRENT_BINARY_DIR}/config-decoration.h)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)

set(appletdecoration_SRCS
    appletdecorationplugin.cpp
    auroraetheme.cpp
    buttonsmodel.cpp
    commontools.cpp
    decorationsmodel.cpp
    decorationpalette.cpp
    environment.cpp
    padding.cpp
    previewbutton.cpp
    previewclient.cpp
    previewbridge.cpp
    previewsettings.cpp
    previewshareddecoration.cpp
    schemecolors.cpp
    schemesmodel.cpp
    themeextended.cpp
    types.cpp
    windowsystem.cpp
)

add_library(appletdecorationplugin SHARED ${appletdecoration_SRCS})

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED  Quick DBus Widgets)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Plasma PlasmaQuick WindowSystem I18n Service ConfigWidgets)

target_link_libraries(appletdecorationplugin
                      Qt5::Core
                      Qt5::DBus
                      Qt5::Widgets
                      Qt5::Quick
                      KF5::ConfigWidgets
                      KF5::I18n
                      KF5::Plasma
                      KF5::PlasmaQuick
                      KF5::WindowSystem
                      KF5::I18n
                      KF5::Service
                      KDecoration2::KDecoration
                      KDecoration2::KDecoration2Private)
                      
install(TARGETS appletdecorationplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)
