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
        //        page.flickable: _flickable
        headBar.visible: true        
        
        acceptButton.text: i18n("Apply")
        rejectButton.text: i18n("Cancel")
        
        
        Component.onCompleted:
        {
            for(var i in control.content)
            {
                if(control.content[i] instanceof Maui.SettingsSection)
                {
                    control.content[i].index = i
                }
            }
        }
}
