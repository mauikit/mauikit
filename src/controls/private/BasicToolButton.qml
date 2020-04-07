/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
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

import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

MouseArea
{
    id: _delegate
    
     property bool checked : false
    property alias text : _label.text
    property alias iconName : _icon.source
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Button
    
    hoverEnabled: true
    implicitHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25)
    implicitWidth: _layoutButton.implicitWidth  + (Maui.Style.space.medium * (checked ? 2.5 : 1))

    onPressAndHold: control.pressAndHold(index)
    onDoubleClicked: control.doubleClicked(index)
    
    Rectangle
    {
        anchors.fill: parent
        opacity: 0.5
        radius: Maui.Style.radiusV
        color: checked || _delegate.containsMouse || _delegate.containsPress ? Qt.rgba( _delegate.Kirigami.Theme.highlightColor.r,  _delegate.Kirigami.Theme.highlightColor.g,  _delegate.Kirigami.Theme.highlightColor.b, 0.2) : "transparent"
        border.color:  checked ?  _delegate.Kirigami.Theme.highlightColor : "transparent"            
        
        Behavior on color
        {
            ColorAnimation
            {
                duration: Kirigami.Units.longDuration
            }
        }
    }    
    
    RowLayout
    {
        id: _layoutButton
        anchors.centerIn: parent
        height: parent.height
        spacing: _delegate.checked ? Maui.Style.space.tiny : 0  
        clip: true

        Item
        {
            Layout.preferredWidth: Maui.Style.iconSizes.medium
            Layout.alignment: Qt.AlignRight
            
            Kirigami.Icon
            {
                id: _icon 
                anchors.centerIn: parent
                width: Maui.Style.iconSizes.medium
                height: width
                color: checked || _delegate.containsMouse || _delegate.containsPress ? _delegate.Kirigami.Theme.highlightColor : _delegate.Kirigami.Theme.textColor
                
            }                
        }            
        
        Label
        {
            id: _label
            opacity: checked ? 1 : 0
            horizontalAlignment: Qt.AlignLeft
            Layout.fillWidth: checked
            Layout.preferredWidth: checked ? implicitWidth : 0
            color: checked ? _delegate.Kirigami.Theme.highlightColor : _delegate.Kirigami.Theme.textColor
            Behavior on Layout.preferredWidth
            {		
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            
            Behavior on opacity
            {		
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: ( _delegate.containsMouse || _delegate.containsPress ) && !checked
    ToolTip.text: _delegate.text
}
