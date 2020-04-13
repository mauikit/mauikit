import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

Rectangle
{
    id: control
    default property alias content : _mainData.data
        
        property alias title : _titleLabel.text
        property alias description : _descLabel.text
        
        Layout.fillWidth: true
        implicitHeight: _layout.implicitHeight + (Maui.Style.space.huge + _layout.spacing)
        
        property int index : -1
        
        ColumnLayout
        {
            id: _layout
            anchors.fill: parent
            anchors.margins: Maui.Style.space.big
            spacing: Maui.Style.space.small
            
            Label
            {
                id: _titleLabel
                Layout.fillWidth: true
                font.pointSize: Maui.Style.fontSizes.big
                font.bold: true
                font.weight: Font.Bold
                visible: text.length
            }
            
            Label
            {
                id: _descLabel
                Layout.fillWidth: true
                font.pointSize: Maui.Style.fontSizes.small
                font.bold: false
                visible: text.length
                wrapMode: Text.WordWrap
                elide: Qt.ElideRight
                opacity: 0.7
            }  
            
            //         Item
            //         {
            //             visible: _descLabel.visible
            //             Layout.fillWidth: true
            //             Layout.preferredHeight: visible ? Maui.Style.space.small : 0
            //         }
            
            Kirigami.FormLayout
            {
                id: _mainData
                Layout.fillWidth: true
                //             Layout.margins: Maui.Style.space.medium
            }
        }
        
        Kirigami.Separator
        {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
        
        color: Kirigami.Theme.backgroundColor
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: index % 2 === 0 ? Kirigami.Theme.View : Kirigami.Theme.Window
}
