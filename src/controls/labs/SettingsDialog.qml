import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Dialog
{
    id: control
    maxHeight: implicitHeight
    maxWidth: 500
    defaultButtons: false

    page.title: i18n("Settings")
    headBar.visible: true

    Component.onCompleted:
    {
        for(var i = 0; i < control.scrollable.length; i++)
        {
            if(control.scrollable[i] instanceof Maui.SettingsSection)
            {
                console.log("Setting dialog section", i)
                control.scrollable[i].index = i
            }
        }
    }
}
