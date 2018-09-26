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

import QtQuick 2.9
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import QtGraphicalEffects 1.0

QQC2.Page
{
    id: control

    property bool headBarVisible : true
    property bool footBarVisible : true
    property bool headBarExit : true
    property bool headBarTitleVisible: headBarTitle
    property string headBarExitIcon : "dialog-close"
    property string headBarTitle: ""

	property int margins: contentMargins * 1.5
	property int topMargin: margins
	property int rightMargin: margins
	property int leftMargin: margins
	property int bottomMargin: margins
	
    property alias headBar: topToolBar
    property alias footBar: bottomToolBar
    property alias floatingBar: bottomToolBar.floatingFootBar

    property int footBarAligment : Qt.AlignCenter    
    property bool altToolBars : false
    property int footBarMargins : space.large   
    property bool footBarOverlap: false
    property bool allowRiseContent: floatingBar && footBarOverlap

    property bool contentIsRised: false

    signal exit();

    default property alias content : mainContainer.data

    clip: true

    leftPadding: 0
    topPadding: leftPadding
    rightPadding: leftPadding
    bottomPadding: leftPadding

    background: Rectangle
    {
        color: viewBackgroundColor
    }

    GridLayout
    {
        id: rootLayout
        anchors.fill: parent
        rows: 3
        columns: 1
        rowSpacing: 0

        Maui.ToolBar
        {
            id: topToolBar

            Layout.fillWidth: true
            Layout.row: altToolBars ? 3 : 1
            Layout.column: 1
            colorScheme.backgroundColor: viewBackgroundColor
            position: altToolBars ? ToolBar.Footer : ToolBar.Header
            dropShadow: false
            drawBorder: !dropShadow
            
            width: parent.width
            height: toolBarHeightAlt
            implicitHeight: toolBarHeightAlt

            visible: headBarVisible && count > 0
            clip: false
            z: container.z +1

            leftContent: Maui.ToolButton
            {
                id: exitBtn
                visible: headBarExit
                anim : true
                iconName : headBarExitIcon
                onClicked : exit()
                //            isMask: false
            }

            middleContent: QQC2.Label
            {
                visible: headBarTitleVisible
                text : headBarTitle
                width: topToolBar.middleLayout.width
                elide : Text.ElideRight
                font.bold : false
                font.weight: Font.Bold
                color : textColor
                font.pointSize: fontSizes.big
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment :  Text.AlignVCenter
            }
        }

        Item
        {
            id: container

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.topMargin: topMargin
            Layout.bottomMargin: bottomMargin
            Layout.rightMargin: rightMargin
            Layout.leftMargin: leftMargin
           
            Layout.row: altToolBars ? 1 : 2
            Layout.column: 1

            clip: false

            anchors.margins: floatingBar && footBarOverlap ? margins : 0
            anchors.top:  if(floatingBar && footBarOverlap && headBarVisible && !altToolBars)
                              topToolBar.bottom
                          else if(floatingBar && footBarOverlap || altToolBars)
                              rootLayout.top
                          else
                              undefined

            anchors.bottom: if(floatingBar && footBarOverlap && !altToolBars)
                                rootLayout.bottom
                            else if(floatingBar && footBarOverlap && altToolBars && headBarVisible)
                                topToolBar.top
                            else if(floatingBar && footBarOverlap && altToolBars && !headBarVisible)
                                rootLayout.bottom
                            else
                                undefined
            z: 1

            Flickable
            {
                id: flickable
                flickableDirection: Flickable.VerticalFlick
                height: parent.height
                width: parent.width
                z: container.z
                //                boundsMovement: Flickable.StopAtBounds
                boundsBehavior: Flickable.StopAtBounds
                interactive:  allowRiseContent
                contentWidth: parent.width
                contentHeight: allowRiseContent ? parent.height + footBar.height + footBarMargins + space.big :
                                                  parent.height

                onContentYChanged: control.contentIsRised = contentY > 0

                Item
                {
                    id: mainContainer
                    z: container.z
                    width: container.width
                    height: contentIsRised ? container.height - (footBar.height + footBarMargins + space.big) :
                                             container.height
                    y: contentIsRised ? flickable.contentY : 0                   
                   
                }
            }
        }

        Maui.ToolBar
        {
            id: bottomToolBar

            visible: footBarVisible && count > 0

            readonly property int _margins : footBarMargins            
            
            Layout.leftMargin: footBarAligment === Qt.AlignLeft ? _margins : (floatingFootBar ? space.small : 0)
			Layout.rightMargin: footBarAligment === Qt.AlignRight ? _margins : (floatingFootBar ? space.small : 0)
			Layout.bottomMargin: floatingFootBar ? _margins : 0
            Layout.alignment: footBarAligment
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            //            Layout.minimumWidth: parent.width * (floatingBar ? 0.4 :  1)
            Layout.maximumWidth: floatingFootBar ? middleLayout.implicitWidth + layout.implicitWidth : parent.width
            Layout.row: altToolBars ? 2 : 3
            Layout.column: 1
            z: container.z +1
            position: ToolBar.Footer
            clip: false
            colorScheme.backgroundColor: viewBackgroundColor
            
            drawBorder: !floatingFootBar
		}
    }

    function riseContent()
    {
        if(allowRiseContent)
            flickable.flick(0, flickable.contentHeight* -2)
    }

    function dropContent()
    {
        if(allowRiseContent)
            flickable.flick(0, flickable.contentHeight* 2)

    }
}
