import QtQuick 2.12
import QtQuick.Controls 2.3

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.3
import org.kde.mauikit 1.1 as MauiLab
import org.kde.appletdecoration 0.1 as AppletDecoration

MauiLab.CSDControls
{
    id: control
    onButtonClicked: performActiveWindowAction(type)

    /**
      *
      */
    function performActiveWindowAction(type)
    {
        if (type === AppletDecoration.Types.Close) {
            root.close()
        } else if (type === AppletDecoration.Types.Maximize) {
            root.toggleMaximized()
        } else if (type ===  AppletDecoration.Types.Minimize) {
            root.showMinimized()
        } else if (type === AppletDecoration.Types.TogglePinToAllDesktops) {
            windowInfo.togglePinToAllDesktops();
        } else if (type === AppletDecoration.Types.ToggleKeepAbove){
            windowInfo.toggleKeepAbove();
        }
    }
}
