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
import org.kde.mauikit 1.2 as Maui

Control
{
    id: control
    default property alias content : _content.data
    
    property alias template: _template
    
    property alias label1 : _template.label1
    property alias label2 : _template.label2
    property alias iconSource : _template.iconSource
    property alias iconSizeHint : _template.iconSizeHint
    
    property bool wide : _content.implicitWidth < control.width * 0.5
    
    implicitHeight: _layout.implicitHeight + Maui.Style.space.medium
    Layout.fillWidth: true
    
    GridLayout
    {        
        id: _layout
        width: parent.width
        anchors.centerIn: parent  
        rows: 2
        columns: 2
        
        Maui.ListItemTemplate
        {        
            id: _template
            Layout.fillWidth: true
//             Layout.fillHeight: true
            
            Layout.row: 0
            Layout.column: 0
            Layout.columnSpan: control.wide ? 1 : 2
            Layout.rowSpan: control.wide ? 2 : 1
            
            iconSizeHint: Maui.Style.iconSizes.medium
            label2.wrapMode: Text.WordWrap
            implicitHeight: Math.floor(label1.implicitHeight + label2.implicitHeight + Maui.Style.space.big ) 
        }
        
        RowLayout
        {
            id: _content
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.margins: Maui.Style.space.medium
            Layout.row: control.wide ? 0 : 1
            Layout.column: control.wide ? 1 : 0
            
            Layout.columnSpan: control.wide ? 2 : 1
            Layout.rowSpan: control.wide ? 2 : 1
            
            Layout.fillWidth: !control.wide
//             Layout.fillHeight: true
        }
    }
    
    background: Rectangle
    {
        
        opacity: 0.5
        color: control.enabled ? Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9)) :  "transparent"
        radius: Maui.Style.radiusV
        border.color: control.enabled ? "transparent" : Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
    }
    
}
