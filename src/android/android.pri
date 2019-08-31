QT += androidextras xml

HEADERS += \
    $$PWD/mauiandroid.h\

SOURCES += \
    $$PWD/mauiandroid.cpp \

LIBS += -ljnigraphics

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

RESOURCES += \
    $$PWD/android.qrc \
    $$PWD/icons.qrc

ANDROID_PACKAGE_SOURCE_DIR += $$PWD/

