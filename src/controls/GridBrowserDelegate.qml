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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0
import "private"

Maui.GridItemDelegate
{
    id: control 
    
    property int folderSize : iconSize
    property int emblemSize: Maui.Style.iconSizes.medium
    property bool showLabel : true
    property bool showEmblem : false
    property bool showTooltip : false
    property bool showThumbnails : false
    
    property bool keepEmblemOverlay : false
    
    property string rightEmblem
    property string leftEmblem
    
    opacity: (model.hidden == true || model.hidden == "true" )? 0.5 : 1
    
    signal emblemClicked(int index)
    signal rightEmblemClicked(int index)
    signal leftEmblemClicked(int index)
    
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered && control.showTooltip
    ToolTip.text: model.tooltip ? model.tooltip : model.path 
    
    Maui.Badge
    {
        id: _leftEmblemIcon
        iconName: control.leftEmblem
        visible: (control.hovered || control.keepEmblemOverlay) && control.showEmblem && control.leftEmblem
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: leftEmblemClicked(index)
        size: Maui.Style.iconSizes.small
        Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
        Kirigami.Theme.textColor: Kirigami.Theme.highlightedTextColor
    }
    /*
     * Maui.Badge
     * {
     *	id: _rightEmblemIcon
     *	iconName: rightEmblem
     *	visible: (isHovered || keepEmblemOverlay) && showEmblem && rightEmblem
     *	z: 999
     *	size: Maui.Style.iconSizes.medium
     *	anchors.top: parent.top
     *	anchors.right: parent.right
     *	onClicked: rightEmblemClicked(index)
     *	Kirigami.Theme.backgroundColor: Kirigami.Theme.highlightColor
}    
*/
    Component
    {
        id: _imgComponent
        
        Item
        {
            anchors.fill: parent

            Image
            {
                id: img
                anchors.centerIn: parent
                source: model.thumbnail ? model.thumbnail : undefined
                height: Math.min (control.folderSize, img.implicitHeight)
                width: Math.min(_layout.width * 0.98, img.implicitWidth)
                sourceSize.width: width
                sourceSize.height: height
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
                smooth: !Kirigami.Settings.isMobile
                
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: img.width
                        height: img.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: img.width
                            height: img.height
                            radius: Maui.Style.radiusV
                        }
                    }
                }
            }
            
            Loader
            {
                anchors.centerIn: parent				
                sourceComponent: img.status === Image.Ready ? undefined : _iconComponent
            }
        }
    }
    
    Component
    {
        id: _iconComponent
        
        Kirigami.Icon
        {
            source: model.icon
            fallback: "qrc:/assets/application-x-zerosize.svg"
           
        }
    }
    
    ColumnLayout
    {
        id: _layout
        anchors.fill: parent
        spacing: Maui.Style.space.tiny
        
        Loader
        {
			sourceComponent: model.mime ? (model.mime.indexOf("image") > -1 && control.showThumbnails ? _imgComponent : _iconComponent) : _iconComponent 
			Layout.preferredHeight: control.folderSize
			Layout.preferredWidth: control.folderSize
			Layout.alignment: Qt.AlignCenter
			
			Maui.Badge
			{
				iconName: "link"
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				visible: (model.issymlink == true) || (model.issymlink == "true")
			}   
		}        
        
        Label
        {
            id: label
            text: model.label
            Layout.margins: Maui.Style.space.tiny
            Layout.fillHeight: true
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            elide: Qt.ElideRight
            wrapMode: Text.Wrap
            color: control.labelColor				
        }
    }        

}
