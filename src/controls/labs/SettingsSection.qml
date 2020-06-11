import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.AlternateListItem
{
    id: control
    default property alias content : _mainData.data
        property int index : -1        
        property alias title : _titleLabel.text
        property alias description : _descLabel.text
        
        alt: index % 2 === 0
        Layout.fillWidth: true
        implicitHeight: _layout.implicitHeight + (Maui.Style.space.huge + _layout.spacing)
        
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
}
