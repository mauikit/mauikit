QT +=  \
    core \
    qml \
    quick \
    gui \
    svg \
    concurrent \
    
CONFIG += c++17

linux:unix:!android {

    message(Building Maui helpers for Linux KDE)
    include($$PWD/src/kde/kde.pri)

} else:android {

    message(Building Maui helpers for Android)
    include($$PWD/src/android/android.pri)    
    include($$PWD/src/utils/editor/syntaxhighlighter.pri)
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
    $$PWD/src/fm/fmlist.h \
    $$PWD/src/fm/pathlist.h \
    $$PWD/src/fm/placeslist.h \
    $$PWD/src/utils/model_template/mauimodel.h \
    $$PWD/src/utils/model_template/mauilist.h \
    $$PWD/src/utils/editor/documenthandler.h \
    $$PWD/src/utils/editor/syntaxhighlighterutil.h \
    $$PWD/src/utils/handy.h \
    $$PWD/src/utils/mauiapp.h \
    $$PWD/src/utils/mauiaccounts.h \
    $$PWD/src/utils/syncing/syncing.h \
    $$PWD/src/utils/store/store.h \
    $$PWD/src/utils/store/storemodel.h \
    $$PWD/src/utils/store/storelist.h

SOURCES += \
    $$PWD/src/mauikit.cpp \
    $$PWD/src/fm/fm.cpp \
    $$PWD/src/fm/fmdb.cpp \
    $$PWD/src/fm/fmlist.cpp \
    $$PWD/src/fm/pathlist.cpp \
    $$PWD/src/fm/placeslist.cpp \
    $$PWD/src/utils/model_template/mauimodel.cpp \
    $$PWD/src/utils/model_template/mauilist.cpp \
    $$PWD/src/utils//editor/documenthandler.cpp \
    $$PWD/src/utils/editor/syntaxhighlighterutil.cpp \
    $$PWD/src/utils/handy.cpp \
    $$PWD/src/utils/mauiapp.cpp \
    $$PWD/src/utils/mauiaccounts.cpp \
    $$PWD/src/utils/syncing/syncing.cpp \
    $$PWD/src/utils/store/store.cpp \
    $$PWD/src/utils/store/storemodel.cpp \
    $$PWD/src/utils/store/storelist.cpp

DEPENDPATH += \
    $$PWD/src \
    $$PWD/src/fm \
    $$PWD/src/utils/model_template

INCLUDEPATH += \
     $$PWD/src \
     $$PWD/src/fm \
     $$PWD/src/utils \
     $$PWD/src/utils/editor \
     $$PWD/src/utils/syncing \
     $$PWD/src/utils/model_template \
     $$PWD/src/utils/store

DEFINES += \
    MAUI_APP \
    STATIC_MAUIKIT

API_VER = 1.0

DISTFILES += \
    $$PWD/CMakeLists.txt

#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5KIOFileWidgets.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5KIOWidgets.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5Bookmarks.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5Solid.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5XmlGui.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5IconThemes.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5KIOCore.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5JobWidgets.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5Service.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5Completion.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5ItemViews.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5ConfigWidgets.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5I18n.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5WidgetsAddons.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5Codecs.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5ConfigGui.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5ConfigCore.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libKF5ConfigCore.so
#ANDROID_EXTRA_LIBS += $$PWD/libs/bin/libdbus-1.so

##KIOFileWidgets
#LIBS += -L$$PWD/libs/bin/ -lKF5KIOFileWidgets
#INCLUDEPATH += $$PWD/libs/includes/KIOFileWidgets
#DEPENDPATH += $$PWD/libs/includes/KIOFileWidgets

##KBookmarks
#LIBS += -L$$PWD/libs/bin/ -lKF5Bookmarks
#INCLUDEPATH += $$PWD/libs/includes/KBookmarks
#DEPENDPATH += $$PWD/libs/includes/KBookmarks

##KSolid
#LIBS += -L$$PWD//libs/bin/ -lKF5Solid
#INCLUDEPATH += $$PWD//libs/includes/Solid
#DEPENDPATH += $$PWD/libs/includes/Solid

##KIOWidgets
#LIBS += -L$$PWD/libs/bin/ -lKF5KIOWidgets
#INCLUDEPATH += $$PWD/libs/includes/KIOWidgets
#DEPENDPATH += $$PWD/libs/includes/KIOWidgets

##KXmlGui
#LIBS += -L$$PWD/libs/bin/ -lKF5XmlGui
#INCLUDEPATH += $$PWD/libs/includes/KXmlGui
#DEPENDPATH += $$PWD/libs/includes/KXmlGui

##KIconThemes
#LIBS += -L$$PWD/libs/bin/ -lKF5IconThemes
#INCLUDEPATH += $$PWD/libs/includes/KIconThemes
#DEPENDPATH += $$PWD/libs/includes/KIconThemes

##KIOCore
#LIBS += -L$$PWD/libs/bin/ -lKF5KIOCore
#INCLUDEPATH += $$PWD/libs/includes/KIOCore
#DEPENDPATH += $$PWD/libs/includes/KIOCore

##KJobWidgets
#LIBS += -L$$PWD/libs/bin/ -lKF5JobWidgets
#INCLUDEPATH += $$PWD/libs/includes/KJobWidgets
#DEPENDPATH += $$PWD/libs/includes/KJobWidgets

##KService
#LIBS += -L$$PWD/libs/bin/ -lKF5Service
#INCLUDEPATH += $$PWD/libs/includes/KService
#DEPENDPATH += $$PWD/libs/includes/KService

##KCompletion
#LIBS += -L$$PWD/libs/bin/ -lKF5Completion
#INCLUDEPATH += $$PWD/libs/includes/KCompletion
#DEPENDPATH += $$PWD/libs/includes/KCompletion

##KItemViews
#LIBS += -L$$PWD/libs/bin/ -lKF5ItemViews
#INCLUDEPATH += $$PWD/libs/includes/KItemViews
#DEPENDPATH += $$PWD/libs/includes/KItemViews

##KConfigWidgets
#LIBS += -L$$PWD/libs/bin/ -lKF5ConfigWidgets
#INCLUDEPATH += $$PWD/libs/includes/KConfigWidgets
#DEPENDPATH += $$PWD/libs/includes/KConfigWidgets

##KI18n
#LIBS += -L$$PWD/libs/bin/ -lKF5I18n
#INCLUDEPATH += $$PWD/libs/includes/KI18n
#DEPENDPATH += $$PWD/libs/includes/KI18n

##KWidgetsAddons
#LIBS += -L$$PWD/libs/bin/ -lKF5WidgetsAddons
#INCLUDEPATH += $$PWD/libs/includes/KWidgetsAddons
#DEPENDPATH += $$PWD/libs/includes/KWidgetsAddons

##KCodecs
#LIBS += -L$$PWD/libs/bin/ -lKF5Codecs
#INCLUDEPATH += $$PWD/libs/includes/KCodecs
#DEPENDPATH += $$PWD/libs/includes/KCodecs

##KConfigGui
#LIBS += -L$$PWD/libs/bin/ -lKF5ConfigGui
#INCLUDEPATH += $$PWD/libs/includes/KConfigGui
#DEPENDPATH += $$PWD/libs/includes/KConfigGui

##KConfigCore
#LIBS += -L$$PWD/libs/bin/ -lKF5ConfigCore
#INCLUDEPATH += $$PWD/libs/includes/KConfigCore
#DEPENDPATH += $$PWD/libs/includes/KConfigCore


