QT += androidextras xml

HEADERS += \
    $$PWD/mauiandroid.h\

SOURCES += \
    $$PWD/mauiandroid.cpp \

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

DISTFILES += \
    $$PWD/src/MyService.java \
    $$PWD/src/SendIntent.java \
    $$PWD/AndroidManifest.xml

ANDROID_PACKAGE_SOURCE_DIR += $$PWD/
