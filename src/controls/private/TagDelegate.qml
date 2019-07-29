import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

ItemDelegate
{
	
	id: control

    clip: true

    property int tagWidth: iconSizes.medium * 5
    property int tagHeight: iconSizes.medium
    property bool showDeleteIcon: true
    signal removeTag(int index)
    hoverEnabled: !isMobile

    height: tagHeight
    width: tagWidth

    anchors.verticalCenter: parent.verticalCenter

    ToolTip.visible: hovered
    ToolTip.text: model.tag

    background: Image
    {
        source: "qrc:/assets/tag.svg"
        sourceSize.width: tagWidth
        sourceSize.height: tagHeight
        width: tagWidth
        height: tagHeight
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: tagWidth *0.2
            Label
            {
                id: tagLabel
                text: tag
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Qt.ElideRight
                font.pointSize: fontSizes.medium
                color: Kirigami.Theme.textColor
            }
        }

        Item
        {
            Layout.fillHeight: true
            width: showDeleteIcon? iconSizes.small : 0
            Layout.maximumWidth: iconSizes.small
            Layout.margins: space.small

            ToolButton
            {
                anchors.centerIn: parent
                visible: showDeleteIcon
                icon.name: "window-close"
                icon.width: iconSizes.small
                onClicked: removeTag(index)
				icon.color: Kirigami.Theme.textColor

            }
        }
    }
}
