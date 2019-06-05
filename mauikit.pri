QT +=  \
    core \
    qml \
    quick \
    gui \
    svg \
    concurrent
    
CONFIG += c++11

linux:unix:!android {

    message(Building Maui helpers for Linux KDE)
    include($$PWD/src/kde/kde.pri)

} else:android {

    message(Building Maui helpers for Android)
    include($$PWD/src/android/android.pri)
    include($$PWD/src/utils/syncing/openssl/openssl.pri)
    include($$PWD/src/utils/syncing/libwebdavclient/webdavclient.pri)
    include($$PWD/src/utils/store/attica/attica.pri)
	
} else {
    message("Unknown configuration")
}

include($$PWD/src/utils/tagging/tagging.pri)

RESOURCES += \
    $$PWD/mauikit.qrc \
    $$PWD/assets.qrc \
    $$PWD/src/fm/fm.qrc \
    $$PWD/src/utils/store/store.qrc \
    $$PWD/maui-style/style.qrc

HEADERS += \
    $$PWD/src/mauikit.h \
    $$PWD/src/fm/fm.h \
    $$PWD/src/fm/fmh.h \
    $$PWD/src/fm/fmdb.h \
    $$PWD/src/fm/fmmodel.h \
    $$PWD/src/fm/fmlist.h \
    $$PWD/src/fm/placeslist.h \
    $$PWD/src/fm/placesmodel.h \
    $$PWD/src/utils/editor/documenthandler.h \
    $$PWD/src/utils/handy.h \
    $$PWD/src/utils/syncing/syncing.h \
	$$PWD/src/utils/syncing/syncinglist.h \
    $$PWD/src/utils/syncing/syncingmodel.h \
	$$PWD/src/utils/store/store.h \
    $$PWD/src/utils/store/storemodel.h \
    $$PWD/src/utils/store/storelist.h

SOURCES += \
    $$PWD/src/mauikit.cpp \
    $$PWD/src/fm/fm.cpp \
    $$PWD/src/fm/fmdb.cpp \
    $$PWD/src/fm/fmmodel.cpp \
    $$PWD/src/fm/fmlist.cpp \
    $$PWD/src/fm/placeslist.cpp \    
    $$PWD/src/fm/placesmodel.cpp \    
    $$PWD/src/utils//editor/documenthandler.cpp \
    $$PWD/src/utils/handy.cpp \
    $$PWD/src/utils/syncing/syncing.cpp \
    $$PWD/src/utils/syncing/syncinglist.cpp \
    $$PWD/src/utils/syncing/syncingmodel.cpp \
    $$PWD/src/utils/store/store.cpp \
    $$PWD/src/utils/store/storemodel.cpp \
    $$PWD/src/utils/store/storelist.cpp

DEPENDPATH += \
    $$PWD/src \
    $$PWD/src/fm

INCLUDEPATH += \
     $$PWD/src \
     $$PWD/src/fm \
     $$PWD/src/utils \
     $$PWD/src/utils/editor \
     $$PWD/src/utils/syncing \
     $$PWD/src/utils/store

DEFINES += \
    MAUI_APP \
    STATIC_MAUIKIT

API_VER = 1.0

DISTFILES += \
    $$PWD/CMakeLists.txt
