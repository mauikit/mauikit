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

exists($$PWD/KI18n) {
    message("Using KI18n for Android")

}else {
    warning("Getting KI18n for Android")
    system(git clone $$KI18N_ANDROID_REPO $$PWD/KI18n)
}

ANDROID_EXTRA_LIBS += $$PWD/KI18n/libKF5I18n.so

LIBS += -L$$PWD/KI18n/ -lKF5I18n

INCLUDEPATH += $$PWD/KI18n/
DEPENDPATH += $$PWD/KI18n/
