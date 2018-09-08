import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

ItemDelegate
{
    property bool isCurrentListItem : ListView.isCurrentItem
    property color labelColor : isCurrentListItem ? highlightColor : textColor
    property color borderColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    anchors.verticalCenter: parent.verticalCenter

    background: Rectangle
    {
        color: isCurrentListItem ? buttonBackgroundColor : "transparent"

        Kirigami.Separator
        {
            anchors
            {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            color: borderColor
        }
    }

    RowLayout
    {
        width: parent.width
        height: parent.height
        Item
        {
            id: pathLabel

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: space.small
            Layout.rightMargin: space.small
            Label
            {
                text: label
                width: parent.width
                height: parent.height
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment:  Qt.AlignVCenter
                elide: Qt.ElideRight
                font.pointSize: fontSizes.default
                color: labelColor
            }
        }
    }
}
