import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import QtGraphicalEffects 1.0

Kirigami.GlobalDrawer
{
    id: control

    property Item bg

    z: 999
    handleVisible: false
    y: altToolBars ? 0 : headBar.height
    height: parent.height - (floatingBar && altToolBars ? 0 : headBar.height)
    modal: true

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    actions: [

        Column
        {
            id: drawerActionsColumn

        },

        Kirigami.Action
        {
            text: "About..."
            iconName: "documentinfo"
        }

    ]

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
}
