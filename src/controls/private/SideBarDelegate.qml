import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
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
    
    property color itemFgColor : textColor
    property string labelColor: ListView.isCurrentItem ? highlightedTextColor :
    itemFgColor
    
    hoverEnabled: !Kirigami.Settings.isMobile
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: hovered && isCollapsed
    ToolTip.text: qsTr(model.label)
    
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
            Layout.fillWidth: isCollapsed
            width: !isCollapsed ? parent.height : parent.width
            
            Maui.ToolButton
            {
                anchors.centerIn: parent
                iconName: model.icon ? model.icon : ""
                size: sidebarIconSize
                isMask: !Kirigami.Settings.isMobile
                iconColor: labelColor
                enabled: false
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
                
                font.pointSize: Kirigami.Settings.isMobile ? Maui.Style.fontSizes.big :
                Maui.Style.fontSizes.default
                color: labelColor
            }
        }
        
        Item
        {
            visible: model.count && model.count > 0
            Layout.fillHeight: true
            width: iconSizes.big + space.small
            Layout.alignment: Qt.AlignRight
            Maui.Badge
            {
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
