SOURCES += $$PWD/mauiwindows.cpp
HEADERS += $$PWD/mauiwindows.h

message("Using OpenSSL for Windows")
LIBS += -LC:/Qt-tools/Tools/OpenSSL/Win_x64/lib/ -llibssl
LIBS += -LC:/Qt-tools/Tools/OpenSSL/Win_x64/lib/ -llibcrypto

LIBS += -LC:/CraftRoot/lib/ -lKF5I18n
LIBS += -LC:/CraftRoot/lib/ -lKF5CoreAddons
#LIBS += -L$$PWD/../../../../../../CraftRoot/lib/ -lKF5Service

INCLUDEPATH += C:/CraftRoot/include
DEPENDPATH += C:/CraftRoot/include

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

