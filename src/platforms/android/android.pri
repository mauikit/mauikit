QT *= androidextras core

exists($$PWD/KI18n) {
    message("Using KI18n for Android")

}else {
    warning("Getting KI18n for Android")
    system(git clone $$KI18N_ANDROID_REPO $$PWD/KI18n)
}

exists($$PWD/KCoreAddons) {
    message("Using KCoreAddons for Android")

}else {
    warning("Getting KCoreAddons for Android")
    system(git clone $$KCOREADDONS_ANDROID_REPO $$PWD/KCoreAddons)
}

HEADERS += \
    $$PWD/mauiandroid.h

SOURCES += \
    $$PWD/mauiandroid.cpp

LIBS += -ljnigraphics

DEPENDPATH += \
    $$PWD

INCLUDEPATH += \
     $$PWD

RESOURCES += \
    $$PWD/android.qrc

ANDROID_EXTRA_LIBS += $$PWD/KI18n/libKF5I18n_armeabi-v7a.so \
                      $$PWD/KCoreAddons/libKF5CoreAddons_armeabi-v7a.so \
                      $$PWD/KCoreAddons/libKF5CoreAddons_armeabi-v7a.so


LIBS += -L$$PWD/KI18n/ -lKF5I18n_armeabi-v7a \
        -L$$PWD/KCoreAddons/ -lKF5CoreAddons_armeabi-v7a

INCLUDEPATH += $$PWD/KI18n \
               $$PWD/KCoreAddons

DEPENDPATH += $$PWD/KI18n\
              $$PWD/KCoreAddons
