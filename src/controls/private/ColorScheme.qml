import QtQuick 2.4
import org.kde.kirigami 2.0 as Kirigami


QtObject
{
	id: control
	
	property color borderColor: Qt.tint(textColor, Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.7))
	property color backgroundColor: root.backgroundColor
	property color textColor: root.textColor
	property color highlightColor: root.highlightColor
	property color highlightedTextColor: root.highlightedTextColor
	property color buttonBackgroundColor: root.buttonBackgroundColor
	property color viewBackgroundColor: root.viewBackgroundColor
	property color altColor: root.altColor
	property color altColorText: root.altColorText
    property color accentColor : root.accentColor
}
