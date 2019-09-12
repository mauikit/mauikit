QT += core qml quick gui

ANDROID_EXTRA_LIBS += $$PWD/KSyntaxHighlighting/libKF5SyntaxHighlighting.so

LIBS += -L$$PWD/KSyntaxHighlighting/ -lKF5SyntaxHighlighting

INCLUDEPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting
DEPENDPATH += $$PWD/KSyntaxHighlighting/KSyntaxHighlighting
