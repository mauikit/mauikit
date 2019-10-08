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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "private"

Drawer
{
	id: control
	
	edge: Qt.LeftEdge
	implicitHeight: parent.height - ApplicationWindow.header.height - ApplicationWindow.footer.height
	height: implicitHeight
	y: ApplicationWindow.header.height
	closePolicy: modal ?  Popup.CloseOnEscape | Popup.CloseOnPressOutside : Popup.NoAutoClose
	visible: true	
	
	property bool collapsible: false
	property bool collapsed: false
	property int collapsedSize: Maui.Style.iconSizes.medium + (Maui.Style.space.medium*4) - Maui.Style.space.tiny
	property int preferredWidth : Kirigami.Units.gridUnit * 12
	
	enter: Transition { SmoothedAnimation { velocity: modal ? 5 : 0 } }
	exit: Transition { SmoothedAnimation { velocity: modal ? 5 : 0 } }
	
	Component.onCompleted:
	{
		if(!modal)
		{
			control.enter.enabled = false;
			control.visible = true;
			control.position = 1;
			control.enter.enabled = true;
		}
	}
	
	Behavior on width
	{
		NumberAnimation
		{
			duration: Kirigami.Units.longDuration
			easing.type: Easing.InOutQuad
		}
	}
	
	EdgeShadow
	{
		z: -2
		visible: control.modal
		parent: control.background
		edge: control.edge
		anchors
		{
			right: control.edge == Qt.RightEdge ? parent.left : (control.edge == Qt.LeftEdge ? undefined : parent.right)
			left: control.edge == Qt.LeftEdge ? parent.right : (control.edge == Qt.RightEdge ? undefined : parent.left)
			top: control.edge == Qt.TopEdge ? parent.bottom : (control.edge == Qt.BottomEdge ? undefined : parent.top)
			bottom: control.edge == Qt.BottomEdge ? parent.top : (control.edge == Qt.TopEdge ? undefined : parent.bottom)
		}
		
		opacity: control.position == 0 ? 0 : 1
		
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

