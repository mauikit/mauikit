import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

ItemDelegate
{
	
	id: control

	property int tagWidth: Math.max(Maui.Style.iconSizes.medium * 5, tagLabel.implicitWidth + _closeIcon.width)
    property int tagHeight: Maui.Style.iconSizes.medium
    property bool showDeleteIcon: true
    
    signal removeTag(int index)
	
    hoverEnabled: !Kirigami.Settings.isMobile
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
            
            Label
            {
                id: tagLabel
                text: tag      
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: tagWidth *0.2
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Qt.ElideRight
                wrapMode: Text.NoWrap
                font.pointSize: Maui.Style.fontSizes.medium
                color: Kirigami.Theme.textColor
            }
        

        Item
        {
			id: _closeIcon
            Layout.fillHeight: true
            Layout.preferredWidth: showDeleteIcon ? Maui.Style.iconSizes.small : 0
            Layout.margins: Maui.Style.space.small
            Layout.alignment: Qt.AlignRight

            ToolButton
            {
                anchors.centerIn: parent
                visible: showDeleteIcon
                icon.name: "window-close"
				height: Maui.Style.iconSizes.small
				width: height
				icon.width: height
                onClicked: removeTag(index)
				icon.color: Kirigami.Theme.textColor
            }
        }
    }
}
