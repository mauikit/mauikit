/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.3 as Maui

Maui.Dialog
{
    id: control
    
    default property alias content : _content.data
    property var urls: []
    
    readonly property var singleItem : Maui.FM.getFileInfo(control.urls[0])
    
    maxWidth: 400
      
    page.margins: Maui.Style.space.big
    
    spacing: Maui.Style.space.medium
    
    template.iconSource: singleItem.icon
    template.imageSource: singleItem.thumbnail
    template.iconSizeHint: Maui.Style.iconSizes.huge
    template.implicitHeight: Math.max(template.leftLabels.implicitHeight, 64)
    
    template.leftLabels.data:  Column
    {
        id: _content
        Layout.fillWidth: true
    }
    
    template.iconComponent: Item
    {
        Item
        {
            anchors.fill: parent
            layer.enabled: true
            
            Rectangle
            {
                visible: control.urls ? control.urls.length > 1 : false
                anchors.fill: parent
                anchors.leftMargin: Maui.Style.space.small
                anchors.rightMargin: Maui.Style.space.small
                radius: Maui.Style.radiusV
                color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
                border.color: Kirigami.Theme.backgroundColor
            }
            
            Rectangle
            {
                visible: control.urls ? control.urls.length > 1 : false
                anchors.fill: parent
                anchors.topMargin: Maui.Style.space.tiny
                anchors.leftMargin: Maui.Style.space.tiny
                anchors.rightMargin: Maui.Style.space.tiny
                radius: Maui.Style.radiusV
                color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
                border.color: Kirigami.Theme.backgroundColor                    
            }
            
            Rectangle
            {
                anchors.fill: parent
                anchors.topMargin:  control.urls.length > 1 ? Maui.Style.space.small : 0
                border.color: Kirigami.Theme.backgroundColor
                
                radius: Maui.Style.radiusV
                color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))        
                
                Maui.GridItemTemplate
                {
                    anchors.fill: parent
                    anchors.margins: Maui.Style.space.tiny
                    iconSizeHint: height
                    
                    iconSource: control.template.iconSource
                    imageSource:  control.template.imageSource                 
                }
            }
        }        
    }

 

    Maui.Separator
    {
        Layout.preferredWidth: 100
        Layout.alignment: Qt.AlignCenter
        radius: 1
        Layout.margins: Maui.Style.space.medium
    }
/*
    Maui.SectionDropDown
    {
        id: _dropDown
        Layout.fillWidth: true
        implicitHeight: Maui.Style.rowHeight
        checked: true
        label1.text: i18n("List files")
        label2.text: i18n("Review and edit selected files.")
    }
    */
    Item {Layout.fillWidth: true}
    
    Maui.ListBrowser
    {
        //visible: _dropDown.checked
        
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight + Maui.Style.space.big, 300)
        model: urls
        spacing: Maui.Style.space.small
        margins: 0
        verticalScrollBarPolicy: ScrollBar.AlwaysOff
        
        delegate: Maui.ListItemTemplate
        {
            width: ListView.view.width
            height: 22
            property var item : Maui.FM.getFileInfo(modelData)
            label1.text: item.label
            label3.text: Maui.FM.formatSize(item.size)
            rightLabels.visible: true
            iconVisible: true
            iconSource: item.icon
            imageSource: item.thumbnail
            iconSizeHint: Maui.Style.iconSizes.medium
            imageSizeHint : height * 0.9
            leftMargin: 0
            rightMargin: 0
            
            ToolButton
            {
                //text: i18n("Clear")
                icon.name: "list-remove"
                icon.width: Maui.Style.iconSizes.small
                icon.height: Maui.Style.iconSizes.small
                
                onClicked: 
                {
                    var array = control.urls
                    const index = array.indexOf(modelData);
                    if (index > -1) {
                        array.splice(index, 1);
                    }
                    
                    if(array.length === 0)
                    {
                        control.close()
                        return
                    }
                    
                    control.urls = array                            
                }
            }
        }
    }
}
