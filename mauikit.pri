QT *=  \
    core \
    qml \
    quick \
    gui \
    svg \
    concurrent

CONFIG *= c++17

DEFINES *= \
    MAUI_APP \
    STATIC_MAUIKIT
    
#set the version for static builds too
VERSION_MAJOR = 1
VERSION_MINOR = 1
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += MAUIKIT_VERSION_STRING=\\\"$$VERSION\\\"


#REPO VARIABLES
LUV_REPO = https://github.com/Nitrux/luv-icon-theme
OPENSSL_REPO = https://github.com/mauikit/openssl
ATTICA_REPO = https://github.com/mauikit/attica
KQUICKSYNTAXHIGHLIGHTER_REPO = https://github.com/mauikit/kquicksyntaxhighlighter.git
KSYNTAXHIGHLIGHTING_REPO = https://github.com/mauikit/KSyntaxHighlighting.git

#ANDROID FILES VALUES
ANDROID_FILES_DIR = $$_PRO_FILE_PWD_/android_files
ANDROID_FILES_MANIFEST = $$_PRO_FILE_PWD_/android_files/AndroidManifest.xml
ANDROID_FILES_GRADLE = $$_PRO_FILE_PWD_/android_files/build.gradle
ANDROID_FILES_RES_DIR = $$_PRO_FILE_PWD_/android_files/res

linux:unix:!android {

    message(Building Maui helpers for Linux KDE)
    include($$PWD/src/kde/kde.pri)

} else:android|win32|macos|ios {

    message(Building Maui helpers for Android or Windows or Mac or iOS)

    android {
        include($$PWD/src/android/android.pri)

        contains(DEFINES, ANDROID_OPENSSL):{
            exists($$PWD/src/utils/syncing/openssl/openssl.pri) {
                message("Using OpenSSL for Android")
                include($$PWD/src/utils/syncing/openssl/openssl.pri)
            }else {
                 message("Getting OpenSSL for Android")
                 system(git clone $$OPENSSL_REPO $$PWD/src/utils/syncing/openssl)
                include($$PWD/src/utils/syncing/openssl/openssl.pri)
            }
        }
    }else:win32 {
        message("Using OpenSSL for Windows")
        LIBS += -L$$PWD/../../../../../../Qt/Tools/OpenSSL/Win_x64/lib/ -llibssl
        LIBS += -L$$PWD/../../../../../../Qt/Tools/OpenSSL/Win_x64/lib/ -llibcrypto
    }else:macos {
        message("Setting up components for Mac")
        include($$PWD/src/macos/macos.pri)
    }else:ios {
        message("Setting up components for iOS")

    }

    contains(DEFINES, COMPONENT_EDITOR):{
        include($$PWD/src/utils/editor/syntaxhighlighter.pri)
    }

    contains(DEFINES, COMPONENT_STORE):{
        exists($$PWD/src/utils/store/attica/attica.pri):{
            message("Using Attica for Android or Windows")
            include($$PWD/src/utils/store/attica/attica.pri)
        }else {
             message("Getting Attica for Android")
             system(git clone $$ATTICA_REPO $$PWD/src/utils/store/attica)
            include($$PWD/src/utils/store/attica/attica.pri)
        }
    }

} else {
    message("Unknown configuration")
}

    contains(DEFINES, MAUIKIT_STYLE):{
        exists($$PWD/src/maui-style/icons/luv-icon-theme) {
            message("Using Luv icon theme")
        }else {
            message("Getting Luv icon theme")
            system(git clone $$LUV_REPO $$PWD/src/maui-style/icons/luv-icon-theme)
        }

        RESOURCES += $$PWD/src/maui-style/style.qrc
        RESOURCES += $$PWD/src/maui-style/icons.qrc

    }

contains(DEFINES, COMPONENT_TAGGING):{
    message("INCLUDING TAGGING COMPONENT")
    include($$PWD/src/utils/tagging/tagging.pri)
} else {
    warning("SKIPPING TAGGING COMPONENT")
}

contains(DEFINES, COMPONENT_EDITOR):{
    message("INCLUDING EDITOR COMPONENT")

    HEADERS += \
        $$PWD/src/utils/editor/documenthandler.h

    SOURCES += \
        $$PWD/src/utils//editor/documenthandler.cpp

    INCLUDEPATH += $$PWD/src/utils/editor


} else {
    warning("SKIPPING EDITOR COMPONENT")
}

contains(DEFINES, COMPONENT_STORE):{
    message("INCLUDING STORE COMPONENT")

    HEADERS += \
        $$PWD/src/utils/store/store.h \
        $$PWD/src/utils/store/storemodel.h \
        $$PWD/src/utils/store/storelist.h

    SOURCES += \
        $$PWD/src/utils/store/store.cpp \
        $$PWD/src/utils/store/storemodel.cpp \
        $$PWD/src/utils/store/storelist.cpp

    RESOURCES += $$PWD/src/utils/store/store.qrc

    INCLUDEPATH += $$PWD/src/utils/store
} else {
    warning("SKIPPING STORE COMPONENT")
}

contains(DEFINES, COMPONENT_SYNCING):{
    message("INCLUDING SYNCING COMPONENT")

    include($$PWD/src/utils/syncing/libwebdavclient/webdavclient.pri)

    HEADERS += $$PWD/src/utils/syncing/syncing.h
    SOURCES += $$PWD/src/utils/syncing/syncing.cpp
    INCLUDEPATH += $$PWD/src/utils/syncing
} else {
    warning("SKIPPING SYNCING COMPONENT")
}

contains(DEFINES, COMPONENT_ACCOUNTS):{
    message("INCLUDING ACCOUNTS COMPONENT")
    QT *= sql
    HEADERS +=  \
        $$PWD/src/utils/accounts/mauiaccounts.h \
        $$PWD/src/utils/accounts/accountsdb.h \

    SOURCES += \
        $$PWD/src/utils/accounts/mauiaccounts.cpp\
        $$PWD/src/utils/accounts/accountsdb.cpp

    RESOURCES += $$PWD/src/utils/accounts/accounts.qrc
    DISTFILES += $$PWD//src/utils/accounts/script.sql

    INCLUDEPATH += $$PWD/src/utils/accounts
    DEPENDPATH +=  $$PWD/src/utils/accounts

} else {
    warning("SKIPPING ACCOUNTS COMPONENT")
}

contains(DEFINES, COMPONENT_FM):{
    message("INCLUDING FM COMPONENT")
    HEADERS += \
        $$PWD/src/fm/fm.h \
        $$PWD/src/fm/fmlist.h \
        $$PWD/src/fm/placeslist.h \
        $$PWD/src/fm/downloader.h


    SOURCES += \
        $$PWD/src/fm/fm.cpp \
        $$PWD/src/fm/fmlist.cpp \
        $$PWD/src/fm/placeslist.cpp \
        $$PWD/src/fm/downloader.cpp

    INCLUDEPATH += $$PWD/src/fm
    DEPENDPATH += $$PWD/src/fm
} else {
    warning("SKIPPING FM COMPONENT")
}

RESOURCES += \
    $$PWD/src/mauikit.qrc \
    $$PWD/src/assets.qrc

HEADERS += \
    $$PWD/src/utils/fmstatic.h \
    $$PWD/src/mauikit.h \
    $$PWD/src/utils/fmh.h \
    $$PWD/src/utils/model_template/mauimodel.h \
    $$PWD/src/utils/model_template/mauilist.h \
    $$PWD/src/utils/handy.h \
    $$PWD/src/utils/utils.h \
    $$PWD/src/utils/mauiapp.h \
    $$PWD/src/utils/models/pathlist.h \
    $$PWD/src/controls/libs/appview.h

SOURCES += \
    $$PWD/src/utils/fmstatic.cpp \
    $$PWD/src/mauikit.cpp \
    $$PWD/src/utils/model_template/mauimodel.cpp \
    $$PWD/src/utils/model_template/mauilist.cpp \
    $$PWD/src/utils/handy.cpp \
    $$PWD/src/utils/mauiapp.cpp \
    $$PWD/src/utils/models/pathlist.cpp

DEPENDPATH += \
    $$PWD/src \
    $$PWD/src/utils/model_template \
     $$PWD/src/controls/libs

INCLUDEPATH += \
     $$PWD/src \
     $$PWD/src/utils \
     $$PWD/src/utils/models \
     $$PWD/src/utils/model_template \
     $$PWD/src/controls/libs

API_VER = 1.0

DISTFILES += \
    $$PWD/CMakeLists.txt \
    $$PWD/src/controls/qmldir


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

