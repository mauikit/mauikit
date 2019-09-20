import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    property bool isCurrentListItem : ListView.isCurrentItem
    property color labelColor : isCurrentListItem ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: _label.implicitWidth + Maui.Style.space.big
    background: Rectangle
    {
		color: isCurrentListItem ? Qt.lighter( Kirigami.Theme.backgroundColor, 1.1) : "transparent"
        
        Kirigami.Separator
        {
            anchors
            {
                top: parent.top
                bottom: parent.bottom
                right: parent.right               
            }            
            color: pathBarBG.border.color
        }
    }

    Label
    {
        id: _label
        text: model.label
        anchors.fill: parent
        rightPadding: Maui.Style.space.medium
        leftPadding: rightPadding        
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment:  Qt.AlignVCenter
        elide: Qt.ElideRight
        font.pointSize: fontSizes.default
        color: labelColor
    }
    
    
}
