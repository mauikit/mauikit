import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    
    property bool isCurrentListItem :  ListView.isCurrentItem
    property bool labelsVisible : true
    property int sidebarIconSize : iconSizes.small
    property alias label: controlLabel.text
    
    width: parent.width
    height: Math.max(sidebarIconSize + space.big, rowHeight)
    
    clip: true
    
    property color itemFgColor : Kirigami.Theme.textColor
    property string labelColor: ListView.isCurrentItem ? Kirigami.Theme.highlightedTextColor :
    itemFgColor
    
    signal rightClicked()	
    
    hoverEnabled: !isMobile
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: hovered 
    ToolTip.text: qsTr(model.label)
    
    background: Rectangle
    {
        anchors.fill: parent
        color: isCurrentListItem || hovered ? Kirigami.Theme.highlightColor : "transparent"
        opacity: hovered ? 0.3 : 1
    }
    
    MouseArea
    {
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton
		onClicked:
		{
			if(!isMobile && mouse.button === Qt.RightButton)
				rightClicked()
		}
	}
    
    RowLayout
    {
        anchors.fill: parent
        
        Item
        {
			Layout.fillHeight: true
			Layout.fillWidth: false
			Layout.preferredWidth: parent.height
			
			Kirigami.Icon
			{
				anchors.centerIn: parent
				source: model.icon ? model.icon : ""
				width: sidebarIconSize
				height: width
// 				isMask: !isMobile
				color: labelColor
			}
		}
        
        Item
        {
            visible: labelsVisible
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
                
                font.pointSize: isMobile ? Maui.Style.fontSizes.big :
                Maui.Style.fontSizes.default
                color: labelColor
            }
        }
        
        Item
        {
            visible: typeof model.count !== "undefined" && model.count && model.count > 0 && labelsVisible
            Layout.fillHeight: true
            Layout.preferredWidth: Math.max(iconSizes.big + space.small, _badge.implicitWidth)
            Layout.alignment: Qt.AlignRight
            Maui.Badge
            {
                id: _badge
                anchors.centerIn: parent
                text: model.count                
            }
        }
    }
    
    function clearCount()
	{
		console.log("CLEANING SIDEBAR COUNT")
		model.count = 0
	}
}
