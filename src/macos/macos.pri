QT *= macextras

QMAKE_APPLE_SIMULATOR_ARCHS = x86_64
LIBS += -framework Foundation -framework Cocoa
INCLUDEPATH += /System/Library/Frameworks/Foundation.framework/Versions/C/Headers \
               /System/Library/Frameworks/AppKit.framework/Headers \
               /System/Library/Frameworks/Cocoa.framework/Headers

SOURCES += $$PWD/mauimacos.mm
HEADERS += $$PWD/mauimacos.h

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD
