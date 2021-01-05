import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

MouseArea
{
    id: control
    property bool checked : false
    
    property alias template : _template
    property alias label1 : _template.label1
    property alias label2 : _template.label2
    
    implicitHeight: _template.implicitHeight + Maui.Style.space.medium
    hoverEnabled: true
    
    Maui.ListItemTemplate
    {
        id: _template
        width: parent.width
        anchors.centerIn: parent
        label1.font.pointSize: Maui.Style.fontSizes.big
        label1.font.bold: true
        label1.font.weight: Font.Bold
        label2.wrapMode: Text.WordWrap
        label1.color: control.hovered || control.pressed || control.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
//         leftMargin: 0
//         rightMargin: 0
//         
        Item
        {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: Maui.Style.iconSizes.medium
            implicitWidth: implicitHeight
            
            Maui.Triangle
            {
                anchors.centerIn: parent
                height: Maui.Style.iconSizes.tiny
                width: height
                rotation: !control.checked ? -45 : -225
                color: control.hovered || control.pressed || control.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                opacity: 0.7
            }            
        }
    }
    
    onClicked: control.checked = !control.checked    
}
