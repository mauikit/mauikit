
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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.13 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.Dialog
{
    id: control
    
    defaultButtons: false
        persistent: false
        widthHint: 0.9
        heightHint: 0.8
        
        maxWidth: 400
        maxHeight: 300
        
        page.padding: 0
        footBar.visible: true
        footBar.middleContent: Button
        {
            icon.name: "link"
            text: i18n("Site")
            onClicked: Qt.openUrlExternally(Maui.App.webPage)
        }
        
        footBar.rightContent: Button
        {
            icon.name: "love"
            text: i18n("Donate")
            onClicked: Qt.openUrlExternally(Maui.App.donationPage)
        }
        
        footBar.leftContent: Button
        {
            icon.name: "documentinfo"
            text: i18n("Report")
            onClicked: Qt.openUrlExternally(Maui.App.reportPage)
        }
        
        Kirigami.ScrollablePage
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Kirigami.Theme.backgroundColor: "transparent"
            padding: 0
            leftPadding: padding
            rightPadding: padding
            topPadding: padding
            bottomPadding: padding
            
            ColumnLayout
            {                
                Maui.AlternateListItem
                {
                    Layout.fillWidth: true                    
                    implicitHeight: _div1.height + Maui.Style.space.huge
                    alt: true   
                    Kirigami.Theme.backgroundColor: palette.background
                    Kirigami.Theme.textColor: palette.foreground
                    Kirigami.ImageColors
                    {
                        id: palette
                        source: Maui.App.name
                    }
                    
                    Maui.ListItemTemplate
                    {
                        id: _div1
                        width: parent.width
                        height: Math.max(150, label2.implicitHeight + label1.implicitHeight)
                        anchors.centerIn: parent
                        imageBorder: false
                        imageSource: Maui.App.iconName
                        imageWidth: Math.min(Maui.Style.iconSizes.huge, parent.width)
                        imageHeight: imageWidth
                        fillMode: Image.PreserveAspectFit
                        imageSizeHint: imageWidth
                        
                        spacing: Maui.Style.space.big
                        label1.text: Maui.App.displayName 
                        label1.font.weight: Font.Bold
                        label1.font.bold: true
                        label1.font.pointSize: Maui.Style.fontSizes.enormous * 1.3
                        
                        label2.text:  Maui.App.version + "\n" + Maui.App.description + "\n" + Maui.App.org
                        label2.font.pointSize: Maui.Style.fontSizes.default
                        label2.elide: Text.ElideRight
                        label2.wrapMode: Text.WrapAtWordBoundaryOrAnywhere   
                    }  
                }              
                
                Maui.AlternateListItem
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: _credits.contentHeight + Maui.Style.space.huge
                    alt: false
                    
                    ListView
                    {
                        id: _credits
                        spacing: Maui.Style.space.big
                        model: Maui.App.credits
                        width: parent.width
                        height: contentHeight
                        anchors.centerIn: parent
                        delegate: Maui.ListItemTemplate
                        {
                            width: parent.width
                            iconSource: "animal"
                            iconSizeHint: Maui.Style.iconSizes.medium
                            spacing: Maui.Style.space.medium
                            label1.text: modelData.name
                            label2.text: modelData.email
                            label3.text: modelData.year
                        }                  
                    }
                }
                
                Maui.AlternateListItem
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: _poweredBy.implicitHeight + Maui.Style.space.huge
                    alt: true
                    
                    Maui.ListItemTemplate
                    {
                        id: _poweredBy
                        anchors.centerIn: parent
                        width: parent.width
                        iconSource: "code-context"
                        iconSizeHint: Maui.Style.iconSizes.medium
                        spacing: Maui.Style.space.medium
                        label1.text: "Powered by"
                        label2.text: "<a href='https://mauikit.org'>MauiKit</a> " +
                        Maui.App.mauikitVersion + " and  <a href='https://kde.org/products/kirigami'>Kirigami</a>"
                        Connections
                        {
                            target: _poweredBy.label2
                            onLinkActivated: Qt.openUrlExternally(link)                                
                        }
                    }
                }
                
            }
        }        
}
