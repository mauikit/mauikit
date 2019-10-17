include(../../common-project-config.pri)

TARGET = signon-qt5
TEMPLATE = lib

CONFIG += \
    debug

QT += \
    core

# Error on undefined symbols
QMAKE_LFLAGS += $$QMAKE_LFLAGS_NOUNDEF

SOURCES += \
    signon.cpp

HEADERS += \
    signon.h
