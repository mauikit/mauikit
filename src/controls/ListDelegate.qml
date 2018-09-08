import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control

    property bool isCurrentListItem :  ListView.isCurrentItem

    property alias label: controlLabel.text

    width: parent.width
    height: rowHeight

    clip: true

    property string labelColor: ListView.isCurrentItem ? highlightedTextColor :
                                                         textColor


    background: Rectangle
    {
        anchors.fill: parent
        color: isCurrentListItem ? highlightColor : "transparent"
        //                                   index % 2 === 0 ? Qt.lighter(backgroundColor,1.2) :
        //                                                     backgroundColor
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            visible: model.icon !== typeof("undefined")
            width: model.icon ? parent.height : 0

            Maui.ToolButton
            {
                id:controlIcon
                anchors.centerIn: parent
                iconName: model.icon ? model.icon : ""
//                isMask: !isMobile
                iconColor: labelColor
                enabled: false
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Label
            {
                id: controlLabel
                height: parent.height
                width: parent.width
                verticalAlignment:  Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft

                text: model.label
                font.bold: false
                elide: Text.ElideRight

                font.pointSize: isMobile ? fontSizes.big :
                                           fontSizes.default
                color: labelColor
            }
        }
    }
}
