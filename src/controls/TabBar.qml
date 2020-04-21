import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

TabBar
{
    id: control
    default property alias content : _content.data
            
    implicitWidth: _content.width
    implicitHeight: Maui.Style.rowHeight + Maui.Style.space.tiny
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false	
    clip: true	    
    
    property bool showNewTabButton : true
    
    signal newTabClicked()
    
    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
        
        Kirigami.Separator
        {
            color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            
            anchors
            {
                left: parent.left
                right: parent.right
                top: control.position === TabBar.Footer ? parent.top : undefined
                bottom: control.position == TabBar.Header ? parent.bottom : undefined
            }
            height: Maui.Style.unit
        }	
        
        /*EdgeShadow
        {
            edge: Qt.TopEdge		
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: 0.2
        }	*/	
    }
    
    Kirigami.WheelHandler
    {
        target: _flickable
    }
    
    contentItem: RowLayout
    {
        spacing: 0
        
        ScrollView
        {            
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            
            Flickable
            {
                id: _flickable                
                anchors.fill: parent
                contentHeight: height
                contentWidth: _content.implicitWidth
                clip: true
                
                Row
                {
                    id: _content
                    width: _flickable.width
                    height: _flickable.height
                } 
            }
        }       
    
        MouseArea
        {           
            visible: control.showNewTabButton
            hoverEnabled: true
            onClicked: control.newTabClicked()
            Layout.fillHeight: true
            Layout.preferredWidth: visible ? height : 0
            
            Maui.PlusSign
            {
                height: Maui.Style.iconSizes.tiny
                width: height
                anchors.centerIn: parent
                color: parent.containsMouse || parent.containsPress ? Kirigami.Theme.highlightColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))    
            }
        } 
    }
}
