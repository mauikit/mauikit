import QtQuick 2.6
import QtQuick.Controls 2.0

import org.kde.kquicksyntaxhighlighter 0.1

TextArea {
    id: myText

    width: 250
    height: 250

    text: "int foo = 0;"

    KQuickSyntaxHighlighter {
        textEdit: myText
        formatName: "C++"
    }
}
