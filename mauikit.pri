QT +=  \
    core \
    qml \
    quick \
    gui \
    svg \
    
CONFIG += c++11

linux:unix:!android {

    message(Building Maui helpers for Linux KDE)
    include($$PWD/src/kde/kde.pri)

} else:android {

    message(Building Maui helpers for Android)
    include($$PWD/src/android/android.pri)

} else {
    message("Unknown configuration")
}

include($$PWD/src/utils/tagging/tagging.pri)

RESOURCES += \
    $$PWD/mauikit.qrc \
    $$PWD/assets.qrc \
    $$PWD/src/fm/fm.qrc

HEADERS += \
    $$PWD/src/mauikit.h \
    $$PWD/src/fm/fm.h \
    $$PWD/src/fm/fmh.h \
    $$PWD/src/fm/fmdb.h

SOURCES += \
    $$PWD/src/mauikit.cpp \
    $$PWD/src/fm/fm.cpp \
    $$PWD/src/fm/fmdb.cpp

DEPENDPATH += \
    $$PWD/src \
    $$PWD/src/fm


INCLUDEPATH += \
     $$PWD/src \
     $$PWD/src/fm

DEFINES += \
    MAUI_APP \
    STATIC_MAUIKIT

API_VER=1.0

DISTFILES += \
    $$PWD/CMakeLists.txt
