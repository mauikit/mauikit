SOURCES += $$PWD/mauiwindows.cpp
HEADERS += $$PWD/mauiwindows.h

message("Using OpenSSL for Windows")
LIBS += -L$$PWD/../../../../../../Qt/Tools/OpenSSL/Win_x64/lib/ -llibssl
LIBS += -L$$PWD/../../../../../../Qt/Tools/OpenSSL/Win_x64/lib/ -llibcrypto

LIBS += -L$$PWD/../../../../../../CraftRoot/lib/ -lKF5I18n
LIBS += -L$$PWD/../../../../../../CraftRoot/lib/ -lKF5CoreAddons
#LIBS += -L$$PWD/../../../../../../CraftRoot/lib/ -lKF5Service

INCLUDEPATH += $$PWD/../../../../../../CraftRoot/include
DEPENDPATH += $$PWD/../../../../../../CraftRoot/include

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

