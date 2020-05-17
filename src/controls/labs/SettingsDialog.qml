import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

Maui.Dialog
{
    id: control
    default property alias content : _layout.data
        
    maxHeight: Math.min(_scrollView.contentHeight + Maui.Style.space.big, 500) + headBar.height
    maxWidth: 350
    defaultButtons: false
        
        page.title: qsTr("Settings")
//        page.flickable: _flickable
        headBar.visible: true        
        
        acceptButton.text: qsTr("Apply")
        rejectButton.text: qsTr("Cancel")
        
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
                if(control.content[i] instanceof MauiLab.SettingsSection)
                {
                    control.content[i].index = i
                }
            }
        }
}
