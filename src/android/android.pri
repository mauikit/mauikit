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
    $$PWD/src/SendIntent.java \
    $$PWD/AndroidManifest.xml

RESOURCES += \
    $$PWD/android.qrc \
    $$PWD/icons.qrc

ANDROID_PACKAGE_SOURCE_DIR += $$PWD/

