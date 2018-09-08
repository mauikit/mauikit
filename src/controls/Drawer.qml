import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

Drawer
{
    id: control

    property Item bg

    width: isMobile ? parent.width * 0.9 : Kirigami.Units.gridUnit * 17
    y: altToolBars ? 0 : root.headBar.height
    height: parent.height - (((floatingBar || root.floatingBar) && !altToolBars) ? root.headBar.height :
                                                           headBar.height + footBar.height)
    clip: true

    FastBlur
    {
        id: blur
        height: parent.height
        width: parent.width
        radius: 90
        opacity: 0.5
        source: ShaderEffectSource
        {
            sourceItem: bg
            sourceRect:Qt.rect(bg.width-(control.position * control.width),
                               0,
                               control.width,
                               control.height)
        }
    }

    background: Rectangle
    {
        color: backgroundColor
        Kirigami.Separator
        {
            readonly property bool horizontal: control.edge === Qt.LeftEdge || control.edge === Qt.RightEdge
            anchors
            {
                left: control.edge !== Qt.LeftEdge ? parent.left : undefined
                right: control.edge !== Qt.RightEdge ? parent.right : undefined
                top: control.edge !== Qt.TopEdge ? parent.top : undefined
                bottom: control.edge !== Qt.BottomEdge ? parent.bottom : undefined
            }
        }
    }


}
