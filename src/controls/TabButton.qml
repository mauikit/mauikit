import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

TabButton
{
    id: control
    implicitWidth:  150 * Maui.Style.unit
    
    signal closeClicked(int index)
    
    default property alias content : _layout.data
        
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
        
        contentItem: Item
        {   
            RowLayout
            {
                id: _layout
                anchors.fill: parent
                spacing: Maui.Style.space.small
                anchors.margins: Maui.Style.space.small
                anchors.leftMargin: height
                anchors.rightMargin: height
                clip: true
                opacity: control.hovered || control.checked ? 1 : 0.7
                
                Label
                {
                    visible: text.length
                    text: control.text
                    font.pointSize: Maui.Style.fontSizes.default
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    color: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    wrapMode: Text.NoWrap
                    elide: Text.ElideMiddle
                }       
            }
            
            
            MouseArea
            {             
                id: _closeButton        
                
                property int position : Maui.App.leftWindowControls.includes("X") ? Qt.AlignLeft : Qt.AlignRight
                
                hoverEnabled: true
                onClicked: control.closeClicked(index)
                width: height
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left:  _closeButton.position === Qt.AlignLeft ? parent.left : undefined
                anchors.right:  _closeButton.position === Qt.AlignRight ? parent.right : undefined
                
                visible:  opacity > 0
                opacity: Kirigami.Settings.isMobile ? 1 : (control.hovered || control.checked ? 1 : 0)                
                
                Behavior on opacity
                {
                    NumberAnimation
                    {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                
                Maui.X
                {
                    height: Maui.Style.iconSizes.tiny
                    width: height
                    anchors.centerIn: parent
                    color: parent.containsMouse || parent.containsPress ? Kirigami.Theme.negativeTextColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))        
                }
            }            
            
        }
}
