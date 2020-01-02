QT *= androidextras xml

HEADERS += \
    $$PWD/mauiandroid.h\

SOURCES += \
    $$PWD/mauiandroid.cpp \

LIBS += -ljnigraphics

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

#exists($$ANDROID_FILES_DIR) {
#    warning("Using application android files at $${ANDROID_FILES_DIR}")
#    system(cp -as $$ANDROID_FILES_DIR/. $${PWD}/)

#}else {
#    warning("Expected files: $$ANDROID_FILES_MANIFEST, $$ANDROID_FILES_GRADLE, $$ANDROID_FILES_RES_DIR")
#    error("The application is missing the android files, this files are supossed to be located at $$ANDROID_FILES_DIR")
#}


RESOURCES += \
    $$PWD/android.qrc

#ANDROID_PACKAGE_SOURCE_DIR += $$PWD/

#DISTFILES += \
#    $$PWD/AndroidManifest.xml \
#    $$PWD/build.gradle \
#    $$PWD/res/values/libs.xml
