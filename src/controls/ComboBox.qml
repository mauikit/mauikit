/*
 * Copyright 2017 Marco Martin <mart@kde.org>
 * Copyright 2017 The Qt Company Ltd.
 *
 * GNU Lesser General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU Lesser
 * General Public License version 3 as published by the Free Software
 * Foundation and appearing in the file LICENSE.LGPLv3 included in the
 * packaging of this file. Please review the following information to
 * ensure the GNU Lesser General Public License version 3 requirements
 * will be met: https://www.gnu.org/licenses/lgpl.html.
 *
 * GNU General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU
 * General Public License version 2.0 or later as published by the Free
 * Software Foundation and appearing in the file LICENSE.GPL included in
 * the packaging of this file. Please review the following information to
 * ensure the GNU General Public License version 2.0 requirements will be
 * met: http://www.gnu.org/licenses/gpl-2.0.html.
 */


import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

ComboBox
{
	id: control
	
	ColorScheme 
	{
		id: colorScheme
	}
	property alias colorScheme : colorScheme
	property alias iconButton : _iconButton
	property alias indicatorButton : _indicatorButton
	
	
	implicitWidth: Math.max(background ? background.implicitWidth : 0,
							contentItem.implicitWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(background ? background.implicitHeight : 0,
							 Math.max(contentItem.implicitHeight,
									  indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
	
	baselineOffset: contentItem.y + contentItem.baselineOffset
	
	leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
	rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
	
	
	
	Maui.ToolButton
	{
		id: _iconButton
		visible: iconName.length
		size: iconSizes.medium
		enabled: false
		iconColor: control.pressed || control.down ? control.colorScheme.highlightedTextColor : control.colorScheme.textColor
		anchors.left: control.left
		anchors.verticalCenter: control.verticalCenter
		anchors.margins: space.small
	}
	
	indicator: Maui.ToolButton
	{
		id: _indicatorButton
		size: iconSizes.small
		enabled: false
		iconName: _popup.visible ? "go-up" : "go-down"
		iconColor: control.pressed || control.down ? control.colorScheme.highlightedTextColor : control.colorScheme.textColor
		anchors.right: control.right
		anchors.verticalCenter: control.verticalCenter
		anchors.margins: space.small
	}
	
	delegate: Maui.ListDelegate
	{		
		label: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
// 		highlighted: control.highlightedIndex == index		
	}
	
	contentItem: Text
	{
		leftPadding: iconButton.width + space.small
		rightPadding: control.indicator.width + control.spacing
		
		text: control.displayText
		font: control.font
		color: control.pressed || control.down ? control.colorScheme.highlightedTextColor : control.colorScheme.textColor
		verticalAlignment: TextInput.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
	}
	
	background: Rectangle
	{
		implicitWidth: iconSizes.medium * 2     
		implicitHeight: iconSizes.medium + space.small
		color: control.pressed || control.down ? control.colorScheme.highlightColor : control.colorScheme.viewBackgroundColor
		border.color: control.pressed ? control.colorScheme.highlightColor : control.colorScheme.borderColor
		border.width: control.visualFocus ? 2 : 1
		radius: radiusV
	}
	
	
	popup: Popup 
	{
		id: _popup
		y: control.height + space.small
		width: control.width
// 		implicitWidth: 100 * unit
		implicitHeight: contentItem.implicitHeight + space.small
		padding: unit * 2
		z: control.parent.z + 1
		
		contentItem: ListView 
		{
			clip: true
			implicitHeight: contentHeight
			model: control.popup.visible ? control.delegateModel : null
			currentIndex: control.highlightedIndex
			
			ScrollIndicator.vertical: ScrollIndicator { }
		}
		
		background: Rectangle
		{
			radius: radiusV
			color: control.colorScheme.backgroundColor
			border.color: control.colorScheme.borderColor 
		}  
	}
}
