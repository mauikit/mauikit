cmake_minimum_required(VERSION 3.0)

project(kquicksyntaxhighlighter)
set(PROJECT_VERSION "0.1")
set(PROJECT_VERSION_MAJOR 0)

set(QT_MIN_VERSION "5.6.0")
set(KF5_MIN_VERSION "5.40.0")
find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Gui Quick)
find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(WriteBasicConfigVersionFile)
include(CheckIncludeFiles)
include(FeatureSummary)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS SyntaxHighlighting)

set(kquicksyntaxhighlighter_SRCS
    kquicksyntaxhighlighterplugin.cpp
    kquicksyntaxhighlighter.cpp
)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kquicksyntaxhighlighter)

add_library(kquicksyntaxhighlighterplugin SHARED ${kquicksyntaxhighlighter_SRCS})

target_link_libraries(kquicksyntaxhighlighterplugin
                      Qt5::Core
                      Qt5::Gui
                      Qt5::Qml
                      Qt5::Quick
                      KF5::SyntaxHighlighting)

install(TARGETS kquicksyntaxhighlighterplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kquicksyntaxhighlighter)
