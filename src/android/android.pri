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

DISTFILES += \
    $$PWD/src/SendIntent.java \
    $$PWD/src/Union.java \
    $$PWD/AndroidManifest.xml

RESOURCES += \
    $$PWD/android.qrc \
    $$PWD/icons.qrc

ANDROID_PACKAGE_SOURCE_DIR += $$PWD/


#KIOFileWidgets
LIBS += -L$$PWD/../../libs/bin/ -lKF5KIOFileWidgets
INCLUDEPATH += $$PWD/../../libs/includes/KIOFileWidgets
DEPENDPATH += $$PWD/../../libs/includes/KIOFileWidgets

#KBookmarks
LIBS += -L$$PWD/../../libs/bin/ -lKF5Bookmarks
INCLUDEPATH += $$PWD/../../libs/includes/KBookmarks
DEPENDPATH += $$PWD/../../libs/includes/KBookmarks


#KSolid
LIBS += -L$$PWD/../../libs/bin/ -lKF5Solid
INCLUDEPATH += $$PWD/../../libs/includes/Solid
DEPENDPATH += $$PWD/../../libs/includes/Solid
