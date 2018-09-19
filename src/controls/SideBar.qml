import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

ListView
{
    id: control

    property color bgColor: isCollapsed ? altColor : backgroundColor
    property color fgColor : isCollapsed ? altColorText : textColor

    property int iconSize : isMobile ? (isCollapsed || isWide ? iconSizes.medium : iconSizes.big) :
                                       iconSizes.small
    property bool collapsable : true
    property bool isCollapsed : false

    signal itemClicked(var item)

    keyNavigationEnabled: true
    clip: true
    focus: true
    interactive: true
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    snapMode: ListView.SnapToItem
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds


    Rectangle
    {
        anchors.fill: parent
        z: -1
        color: bgColor
    }

    model: ListModel {}

    delegate: SideBarDelegate
    {
        id: itemDelegate
        sidebarIconSize: iconSize
        labelsVisible: !isCollapsed
        itemFgColor: fgColor

        Connections
        {
            target: itemDelegate
            onClicked:
            {
                control.currentIndex = index
                itemClicked(control.model.get(index))
            }
        }
    }
}
