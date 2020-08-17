import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.ItemDelegate
{
    id: control
    property bool alt : index ? index % 2 === 0 : false
    leftPadding: Maui.Style.space.medium
    rightPadding: Maui.Style.space.medium
    
    background: Rectangle
    {        
        //     color: alt ? Kirigami.Theme.backgroundColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
        color: Kirigami.Theme.backgroundColor
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: alt ? Kirigami.Theme.View : Kirigami.Theme.Window

        Kirigami.Separator
        {
            id: _sep
            opacity: 0.5
            color: Qt.darker(parent.color, 2.5)                    
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
        
        Kirigami.Separator
        {
            opacity: 0.3            
            color: Qt.lighter(parent.color, 2.5)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1        
        }          
    }    
}
