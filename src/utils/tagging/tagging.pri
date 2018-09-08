QT += \
    sql \
    network

HEADERS += \
    $$PWD/tagging.h \
    $$PWD/tagdb.h \
    $$PWD/tag.h

SOURCES += \
    $$PWD/tagging.cpp \
    $$PWD/tagdb.cpp \

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

DISTFILES += \
     $$PWD/script.sql \
    $$PWD/CMakeLists.txt


API_VER=1.0

RESOURCES += \
    $$PWD/tagging.qrc
