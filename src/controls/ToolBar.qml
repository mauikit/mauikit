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

import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "private"

ToolBar
{
    id: control
    property int preferredHeight: Maui.Style.toolBarHeight
    implicitHeight: preferredHeight
    implicitWidth: mainFlickable.contentWidth
    spacing: Maui.Style.space.small
    padding: 0
    clip: true

    property alias stickyRightContent : rightRowContent.sticky
    property alias stickyLeftContent : leftRowContent.sticky
    property alias stickyMiddleContent : middleRowContent.sticky

    property alias leftContent : leftRowContent.data
    property alias middleContent : middleRowContent.data
    property alias rightContent : rightRowContent.data

    property alias middleLayout : middleRowContent
    property alias leftLayout : leftRowContent
    property alias rightLayout : rightRowContent

    property alias layout : layout

    readonly property alias fits : mainFlickable.fits

    property int margins: Maui.Style.space.medium
    property int count : leftContent.length + middleContent.length + rightContent.length

    property bool flickable: true
    property bool strech : true
    property bool leftSretch: strech
    property bool rightSretch: strech
    property bool middleStrech: strech

    //    leftPadding: Kirigami.Units.smallSpacing*2
    //    rightPadding: Kirigami.Units.smallSpacing*2

    // 	background: Rectangle
    // 	{
    // 		id: headBarBG
    // 		color: colorScheme.backgroundColor
    // 		implicitHeight: Maui.Style.toolBarHeightAlt
    // 		radius: floating ? Maui.Style.radiusV : 0
    // 		border.color: floating ? colorScheme.borderColor : "transparent"
    //
    // 		SequentialAnimation on radius
    // 		{
    // 			ColorAnimation { to: colorScheme.backgroundColor ; duration: 1000 }
    // 		}
    //
    // 		Kirigami.Separator
    // 		{
    // 			visible: drawBorder
    // 			color: colorScheme.borderColor
    // 			height: Maui.Style.unit
    // 			anchors
    // 			{
    // 				left: parent.left
    // 				right: parent.right
    // 				bottom: control.position == ToolBar.Footer ? undefined : parent.bottom
    // 				top: control.position == ToolBar.Footer ? parent.top : undefined
    // 			}
    // 		}
    //
    // 		layer.enabled: dropShadow
    // 		layer.effect: DropShadow
    // 		{
    // 			anchors.fill: headBarBG
    // 			horizontalOffset: 0
    // 			verticalOffset:  Maui.Style.unit * (altToolBars ? -1 : 1)
    // 			radius: 8
    // 			samples: 25
    // 			color: Qt.darker(colorScheme.backgroundColor, 1.4)
    // 			source: headBarBG
    // 		}
    // 	}


    MouseArea
    {
        id: _rightFlickRec
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXEnd && !mainFlickable.fits && control.flickable
        hoverEnabled: true
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        z: 999

        EdgeShadow
        {
            visible: true
            parent: parent
            edge: Qt.RightEdge
            anchors
            {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            opacity: 1

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        Maui.Triangle
        {
			visible: !Kirigami.Settings.isMobile
			anchors.centerIn: parent
			rotation: -135
			color:  _rightFlickRec.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			width: Maui.Style.iconSizes.tiny
			height:  width 
		}

        enabled: !mainFlickable.atXEnd
        opacity: enabled ? 1 : 0.4
        onClicked:
        {
            if(!mainFlickable.atXEnd)
                mainFlickable.contentX += control.height
                if(mainFlickable.atXEnd)
                    mainFlickable.returnToBounds()
        }

    }

    MouseArea
    {
        id: _leftFlickRec
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXBeginning && !mainFlickable.fits && control.flickable
        hoverEnabled: true
        anchors
        {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        z: 999

        EdgeShadow
        {
            visible: true
            parent: parent
            edge: Qt.LeftEdge
            anchors
            {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            opacity: 1

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        Maui.Triangle
        {
			visible: !Kirigami.Settings.isMobile
			anchors.centerIn: parent
			rotation: 45
			color:  _leftFlickRec.hovered ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
			width: Maui.Style.iconSizes.tiny
			height:  width 
		}

        enabled: !mainFlickable.atXBeginning
        opacity: enabled ? 1 : 0.4
        onClicked:
        {
            if(!mainFlickable.atXBeginning)
                mainFlickable.contentX -= control.height

                if(mainFlickable.atXBeginning)
                    mainFlickable.returnToBounds()
        }
    }

    Flickable
    {
        id: mainFlickable
        property bool fits : contentWidth < control.width
        onFitsChanged: returnToBounds()
        height: control.preferredHeight
        anchors {
            left: parent.left
            right: parent.right
            bottom: control.position === ToolBar.Header ? parent.bottom : undefined
            top: control.position === ToolBar.Footer ? parent.top : undefined
        }

        anchors.leftMargin: !fits && _leftFlickRec.visible && control.flickable && !Kirigami.Settings.isMobile ? _leftFlickRec.width : margins
        anchors.rightMargin: !fits && _rightFlickRec.visible && control.flickable && !Kirigami.Settings.isMobile ? _rightFlickRec.width : margins

        flickableDirection: Flickable.HorizontalFlick
        interactive: !fits && Maui.Handy.isTouch
        contentWidth: ((control.margins) + Maui.Style.space.medium)
        + (control.stickyLeftContent ? leftRowContent.implicitWidth : leftRowContent.width)
        + (control.stickyMiddleContent ? middleRowContent.implicitWidth : middleRowContent.width)
        + (control.stickyRightContent ? rightRowContent.implicitWidth : rightRowContent.width)

        boundsBehavior: Kirigami.Settings.isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
        clip: true

        RowLayout
        {
            id: layout
            width: control.width - control.margins - Maui.Style.space.medium
            height: mainFlickable.height

            RowLayout
            {
                id: leftRowContent
                // 					visible: control.leftSretch && implicitWidth
                property bool sticky : false
                Layout.leftMargin: rightRowContent.implicitWidth && implicitWidth === 0 && middleRowContent.implicitWidth && control.leftSretch ? rightRowContent.implicitWidth : 0
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                spacing: control.spacing
                Layout.minimumWidth: !sticky ? implicitWidth : implicitWidth
                Layout.fillWidth: control.leftSretch && implicitWidth
                Layout.fillHeight: true
            }

            RowLayout
            {
                id: middleRowContent
                property bool sticky : false
                // 					visible: control.middleStrech && implicitWidth
                Layout.alignment: Qt.AlignCenter
                spacing: control.spacing
                Layout.minimumWidth: !sticky ? implicitWidth : implicitWidth

                //                             Layout.maximumWidth: control.width - leftRowContent.implicitWidth - rightRowContent.implicitWidth
                Layout.fillWidth: control.middleStrech
                Layout.fillHeight: true
            }

            RowLayout
            {
                id: rightRowContent
                // 					visible: control.rightSretch && implicitWidth
                property bool sticky : false
                Layout.rightMargin: leftRowContent.implicitWidth && implicitWidth === 0 && middleRowContent.implicitWidth && control.rightSretch ? leftRowContent.implicitWidth : 0
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                spacing: control.spacing
                Layout.minimumWidth: !sticky ? implicitWidth : implicitWidth
                // 					Layout.maximumWidth: !sticky ? rightRowContent.width : implicitWidth
                Layout.fillWidth: control.rightSretch && implicitWidth
                Layout.fillHeight: true
            }
        }

        // 			ScrollBar.horizontal: ScrollBar { visible: false}
    }

}
