cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

find_package(ECM 5.45.0 NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(ECMQMLModules)
include(CheckIncludeFiles)
include(KDECMakeSettings)

include(KDEInstallDirs)
include(KDECompilerSettings)

set(mauikitplugin_SRCS
    pluginmanager.cpp
)

add_library(mauikitplugin SHARED ${mauikitplugin_SRCS})

find_package(Qt5 ${REQUIRED_QT_VERSION} CONFIG REQUIRED  Quick Qml)

target_link_libraries(mauikitplugin
                    MauiKit
                      Qt5::Core
                      Qt5::Qml
                      Qt5::Quick)
                      
install(TARGETS mauikitplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mauikit/plugin)

install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mauikit/plugin)

install(FILES qml/qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/mauikit/plugin)
