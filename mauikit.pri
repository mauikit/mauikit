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
    $$PWD/src/fm/fmdb.h \
    $$PWD/src/fm/fmmodel.h \
    $$PWD/src/fm/fmlist.h \
    $$PWD/src/utils/handy.h

SOURCES += \
    $$PWD/src/mauikit.cpp \
    $$PWD/src/fm/fm.cpp \
    $$PWD/src/fm/fmdb.cpp \
    $$PWD/src/fm/fmmodel.cpp \
    $$PWD/src/fm/fmlist.cpp \
    $$PWD/src/utils/handy.cpp

DEPENDPATH += \
    $$PWD/src \
    $$PWD/src/fm


INCLUDEPATH += \
     $$PWD/src \
     $$PWD/src/fm \
     $$PWD/src/utils

DEFINES += \
    MAUI_APP \
    STATIC_MAUIKIT

API_VER = 1.0

DISTFILES += \
    $$PWD/CMakeLists.txt
