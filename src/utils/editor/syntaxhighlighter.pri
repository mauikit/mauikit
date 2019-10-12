QT += core qml quick gui

exists($$PWD/KSyntaxHighlighting) {
    message("Using KSyntaxHighlighting for Android")

}else {
    warning("Getting KSyntaxHighlighting for Android")
    system(git clone $$KSYNTAXHIGHLIGHTING_REPO $$PWD/KSyntaxHighlighting)
}

exists($$PWD/kquicksyntaxhighlighter) {
    message("Using kquicksyntaxhighlighter for Android")

}else {
    warning("Getting kquicksyntaxhighlighter for Android")
    system(git clone $$KQUICKSYNTAXHIGHLIGHTER_REPO $$PWD/kquicksyntaxhighlighter)
}

HEADERS += \
    $$PWD/kquicksyntaxhighlighter/kquicksyntaxhighlighter.h\

SOURCES += \
    $$PWD/kquicksyntaxhighlighter/kquicksyntaxhighlighter.cpp\

ANDROID_EXTRA_LIBS += $$PWD/KSyntaxHighlighting/libKF5SyntaxHighlighting.so

LIBS += -L$$PWD/KSyntaxHighlighting/ -lKF5SyntaxHighlighting

INCLUDEPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting /
               $$PWD/kquicksyntaxhighlighter

DEPENDPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting /
               $$PWD/kquicksyntaxhighlighter
