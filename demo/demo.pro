QT += qml
QT += quick
QT += sql
QT += widgets
QT += quickcontrols2

CONFIG += c++11
#CONFIG += ordered
CONFIG += object_parallel_to_source

TARGET = mauidemo
TEMPLATE = app

linux:unix:!android {

    message(Building for Linux KDE)
    QT += webengine
    QT += KService KNotifications KNotifications KI18n KContacts
    QT += KIOCore KIOFileWidgets KIOWidgets KNTLM
    LIBS += -lMauiKit

} else:android {

    message(Building helpers for Android)
    QT += androidextras webview
    include($$PWD/mauikit/mauikit.pri)
    include($$PWD/3rdparty/kirigami/kirigami.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

SOURCES += \
    $$PWD/src/main.cpp \

RESOURCES += \
    $$PWD/src/qml.qrc \
    $$PWD/src/assets.qrc

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
