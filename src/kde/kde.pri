QT *= KService KNotifications KNotifications KI18n
QT *= KIOCore KIOFileWidgets KIOWidgets KNTLM

HEADERS += \
    $$PWD/mauikde.h \
    $$PWD/kdeconnect.h

SOURCES += \
    $$PWD/mauikde.cpp \
    $$PWD/kdeconnect.cpp \

DEPENDPATH += \
    $$PWD \

INCLUDEPATH += \
     $$PWD \

