import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Dialog
{
    id: control
    default property alias content : _layout.data
        
    maxHeight: Math.min(_scrollView.contentHeight + Maui.Style.space.big, 500) + headBar.height
    maxWidth: 400
    defaultButtons: false
        
        page.title: i18n("Settings")
//        page.flickable: _flickable
        headBar.visible: true        
        
        acceptButton.text: i18n("Apply")
        rejectButton.text: i18n("Cancel")
        
        ScrollView
        {
            id: _scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: _layout.implicitHeight
            
            Flickable
            {
                id: _flickable
                
                ColumnLayout
                {
                    id: _layout
                    width: parent.width
                    spacing: 0
                }                
            }           
        }

        
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
