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

import QtQuick 2.5
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import QtGraphicalEffects 1.0

Maui.Popup
{
    id: control
    
    default property alias content : _pageContent.data
        
    property string message : ""
    property string title: ""
    property alias template : _template
        
    property bool defaultButtons: true
    property bool persistent : true    
    
    property alias acceptButton : _acceptButton
    property alias rejectButton : _rejectButton
    
    property alias textEntry : _textEntry
    property alias entryField: _textEntry.visible
    
    property alias page : _page
    property alias footBar : _page.footBar
    property alias headBar: _page.headBar
    property alias closeButton: _closeButton
    
    signal accepted()
    signal rejected()
    
    closePolicy: control.persistent ? Popup.NoAutoClose | Popup.CloseOnEscape : Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    maxWidth: Maui.Style.unit * 300
    maxHeight: implicitHeight
    implicitHeight: _layout.implicitHeight
    widthHint: 0.9
    heightHint: 0.9  
    clip: false
    
    Maui.Badge
    {
        id: _closeButton    
        visible: control.persistent
        
        color: hovered || pressed ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.backgroundColor
        
        property int position : Maui.App.leftWindowControls.includes("X") ? Qt.AlignLeft : Qt.AlignRight
        
        Maui.X
        {
            height: Maui.Style.iconSizes.tiny
            width: height
            anchors.centerIn: parent
            color: Kirigami.Theme.textColor            
        }
        
        border.color: Kirigami.Theme.textColor
        
        anchors
        {
            verticalCenter: parent.top
            horizontalCenter: _closeButton.position === Qt.AlignLeft ? parent.left : parent.right
            horizontalCenterOffset: control.width === control.parent.width ? _closeButton.width : 0
        }
        
        z: control.z+999
        onClicked: close()
    }
    
    
    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: 0
        
        Maui.Page
        {
            id: _page
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0
            clip: true
            
            implicitHeight: Maui.Style.space.medium + _pageContent.implicitHeight + topPadding + bottomPadding + topMargin + bottomMargin + footer.height + _pageContent.spacing + header.height
            
            ColumnLayout
            {
                id: _pageContent
                anchors.fill: parent
                spacing: Maui.Style.space.medium                          
                
                Kirigami.ScrollablePage
                {
                    id: _scrollable
                    visible: message.length > 0
                    Layout.maximumHeight: Math.min(_scrollable.contentHeight, 500)
//                     Layout.minimumHeight: contentHeight
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    contentHeight: _template.implicitHeight
                    Kirigami.Theme.backgroundColor: "transparent"
                    padding: 0
                    leftPadding: padding
                    rightPadding: padding
                    topPadding: padding
                    bottomPadding: padding
                    
                    Maui.ListItemTemplate
                    {
                     id: _template
                     width: parent.width
                     implicitHeight: label1.implicitHeight + label2.implicitHeight + Maui.Style.space.medium
                     
                     label1.text: title
                     label1.font.weight: Font.Thin
                     label1.font.bold: true
                     label1.font.pointSize:Maui.Style.fontSizes.huge
                     label1.elide: Qt.ElideRight
                     label1.wrapMode: Text.Wrap
                     
                     label2.text: message
                     label2.textFormat : TextEdit.AutoText
                     label2.font.pointSize:Maui.Style.fontSizes.default
                     label2.wrapMode: TextEdit.WordWrap
                     
                     iconSizeHint: Maui.Style.iconSizes.large
                     spacing: Maui.Style.space.big
                    }
                    
                }
                
                Maui.TextField
                {
                    id: _textEntry
                    visible: false
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    focus: visible
                    onAccepted: control.accepted()
                }
            }
            /* 
             *        layer.enabled: control.background.radius
             *        layer.samples: 4
             *        layer.effect: OpacityMask
             *        {
             *            maskSource: Item
             *            {
             *                width: _page.width
             *                height: _page.height
             * 
             *                Rectangle
             *                {
             *                    anchors.centerIn: parent
             *                    width: _page.width
             *                    height: _page.height
             *                    radius: control.background.radius
        }
        }
        }*/
        }
        
        Kirigami.Separator
        {
            Layout.fillWidth: true
            visible: control.defaultButtons
        }
        
        RowLayout
        {
            id: _defaultButtonsLayout
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight:  Maui.Style.toolBarHeightAlt - Maui.Style.space.medium
            Layout.maximumHeight: Maui.Style.toolBarHeightAlt - Maui.Style.space.medium
            visible: control.defaultButtons
            
            Button
            {
                Layout.fillWidth: true                  
                Layout.fillHeight: true
                implicitWidth: width
                id: _rejectButton
                text: qsTr("Cancel")
                background: Rectangle
                {
                    color: _rejectButton.hovered || _rejectButton.down || _rejectButton.pressed ? "#da4453" : Kirigami.Theme.backgroundColor
                }
                
                contentItem: Label
                {
                    text: _rejectButton.text
                    color:  _rejectButton.hovered || _rejectButton.down || _rejectButton.pressed ?  "#fafafa" : Kirigami.Theme.textColor
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                } 
                /*property color color : Kirigami.Theme.negativeBackgroundColor
                 *       property alias text : _rejectLabel.text
                 *       
                 *       Rectangle
                 *       {
                 *           anchors.fill: parent
                 *           color: _rejectButton.color
                 *           Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                 *           Label
                 *           {
                 *               id: _rejectLabel
                 *               anchors.fill: parent
                 *               anchors.margins: Maui.Style.space.small
                 *               text: _rejectButton.text
                 *               color: "#fafafa"
            }
            }    */                
                
                onClicked: rejected()
            }    
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
                visible: _defaultButtonsLayout.visibleChildren.length > 1
            }
            
            Button
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: width
                text: qsTr("Accept")
                id: _acceptButton
                
                background: Rectangle
                {
                    color: _acceptButton.hovered || _acceptButton.down || _acceptButton.pressed ? "#26c6da" : Kirigami.Theme.backgroundColor
                }
                
                contentItem: Label
                {
                    text: _acceptButton.text
                    color:  _acceptButton.hovered || _acceptButton.down || _acceptButton.pressed ?  "#fafafa" : Kirigami.Theme.textColor
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }               
                
                onClicked: accepted()
            }
        }
    }
}
