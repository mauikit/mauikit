QT += core qml quick gui

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
