QT *= core qml quick gui

android {
    exists($$PWD/KSyntaxHighlighting) {
        message("Using KSyntaxHighlighting for Android")

    }else {
        warning("Getting KSyntaxHighlighting for Android")
        system(git clone $$KSYNTAXHIGHLIGHTING_REPO $$PWD/KSyntaxHighlighting)
    }

    ANDROID_EXTRA_LIBS += $$PWD/KSyntaxHighlighting/libKF5SyntaxHighlighting.so

}else:win32 {

}

LIBS += -L$$PWD/KSyntaxHighlighting/ -lKF5SyntaxHighlighting

INCLUDEPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting 

DEPENDPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting 
