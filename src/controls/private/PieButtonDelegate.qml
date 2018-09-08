import QtQuick 2.6
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    property bool isCurrent: PathView.isCurrentItem
    property alias size : controlIcon.size
    background: Rectangle
    {
        color: "transparent"
    }

    DropShadow
    {
        anchors.fill: bg
        visible: bg.visible
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: bg
    }

    Rectangle
    {
        id: bg
        anchors.fill: parent
        color: isCurrent ? highlightColor : viewBackgroundColor
        radius: Math.max(control.height, control.width)

    }

    Maui.ToolButton
    {
        id: controlIcon
        anchors.centerIn: parent
        enabled: false

        iconName: model.iconName
        text: model.text
        iconColor: isCurrent ? highlightedTextColor : textColor
    }
}
