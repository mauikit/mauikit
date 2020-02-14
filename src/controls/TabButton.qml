import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private/shapes"

TabButton
{
    id: control
    implicitWidth:  150 * Maui.Style.unit

    signal closeClicked(int index)

    Kirigami.Separator
    {
        color: Kirigami.Theme.highlightColor
        height: Maui.Style.unit * 2
        visible: checked
        anchors
        {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    background: Rectangle
    {
        color: "transparent"

        Kirigami.Separator
        {
            width: Maui.Style.unit
            anchors
            {
                bottom: parent.bottom
                top: parent.top
                right: parent.right
            }
        }
    }

    contentItem: RowLayout
    {
        anchors.fill: control
        spacing: Maui.Style.space.small
        anchors.margins: Maui.Style.space.small

        Label
        {
            text: control.text
            font.pointSize: Maui.Style.fontSizes.default
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            color: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            wrapMode: Text.NoWrap
            elide: Text.ElideMiddle
        }

        
        MouseArea
        {
            Layout.fillHeight: true
            Layout.preferredWidth: Maui.Style.iconSizes.small * 2
            Layout.alignment: Qt.AlignRight           
            hoverEnabled: true
            onClicked: control.closeClicked(index)
            
            X
            {
                height: Maui.Style.iconSizes.tiny
                width: height
                anchors.centerIn: parent
                color: parent.hovered || parent.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor            
            }
        }
    }
}
