import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

ItemDelegate
{
    id: control
    
    property int tagHeight: Maui.Style.rowHeightAlt
    property bool showDeleteIcon: true
    
    signal removeTag(int index)
    
    hoverEnabled: !Kirigami.Settings.isMobile
    implicitHeight: tagHeight
    implicitWidth: _layout.implicitWidth
    
    anchors.verticalCenter: parent.verticalCenter
    
    ToolTip.visible: hovered
    ToolTip.text: model.tag
    
    background: Rectangle
    {
        radius: Maui.Style.radiusV
        opacity: 0.5
        color: model.color ? model.color : Kirigami.Theme.backgroundColor        
        border.color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(color.r, color.g, color.b, 0.7))
    }
    
    RowLayout
    {
        id: _layout
        //         anchors.fill: parent
        //         anchors.margins: Maui.Style.space.small
        height: parent.height
        Label
        {
            id: tagLabel
            text: model.tag
            Layout.fillHeight: true
            Layout.preferredWidth: Math.max(Maui.Style.iconSizes.medium * 3, implicitWidth + _closeIcon.width)
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            elide: Qt.ElideRight
            wrapMode: Text.NoWrap
            font.pointSize: Maui.Style.fontSizes.medium
            color: Kirigami.Theme.textColor
        }
        
        MouseArea
        {
            id: _closeIcon
            visible: showDeleteIcon
            hoverEnabled: true
            
            Layout.fillHeight: true
            Layout.preferredWidth: showDeleteIcon ? Maui.Style.iconSizes.medium : 0
            Layout.alignment: Qt.AlignRight
            onClicked: removeTag(index)
            
            Maui.X
            {
                height: Maui.Style.iconSizes.tiny
                width: height
                anchors.centerIn: parent
                color: Kirigami.Theme.textColor            
            }
        }
    }
}
