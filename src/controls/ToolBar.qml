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

import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "private"

/**
 * ToolBar
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
ToolBar
{
    id: control
    implicitHeight: preferredHeight
    implicitWidth: mainFlickable.contentWidth
    spacing: Maui.Style.space.small
    padding: 0

    /**
      * content : RowLayout.data
      */
    default property alias content : leftRowContent.data

    /**
      * preferredHeight : int
      */
    property int preferredHeight: Maui.Style.toolBarHeight

    /**
      * forceCenterMiddleContent : bool
      */
    property bool forceCenterMiddleContent : true

    /**
      * leftContent : RowLayout.data
      */
    property alias leftContent : leftRowContent.data

    /**
      * middleContent : RowLayout.data
      */
    property alias middleContent : middleRowContent.data

    /**
      * rightContent : RowLayout.data
      */
    property alias rightContent : rightRowContent.data

    /**
      * farLeftContent : RowLayout.data
      */
    property alias farLeftContent : farLeftRowContent.data

    /**
      * farRightContent : RowLayout.data
      */
    property alias farRightContent : farRightRowContent.data

    /**
      * middleLayout : RowLayout
      */
    property alias middleLayout : middleRowContent

    /**
      * leftLayout : RowLayout
      */
    property alias leftLayout : leftRowContent

    /**
      * rightLayout : RowLayout
      */
    property alias rightLayout : rightRowContent

    /**
      * layout : RowLayout
      */
    property alias layout : layout

    /**
      * fits : bool
      */
    readonly property alias fits : _scrollView.fits

    /**
      * margins : int
      */
    property int margins: Maui.Style.space.medium

    /**
      * count : int
      */
    readonly property int count : leftContent.length + middleContent.length + rightContent.length + farLeftContent.length + farRightContent.length

    /**
      * visibleCount: int
      */
    readonly property int visibleCount : leftRowContent.visibleChildren.length + middleRowContent.visibleChildren.length  + rightRowContent.visibleChildren.length + farLeftRowContent.visibleChildren.length  + farRightRowContent.visibleChildren.length

    /**
      * flickable : bool
      */
    property bool flickable: true

    /**
      * strech : bool
      */
    property bool strech : true

    /**
      * leftSretch : bool
      */
    property bool leftSretch: strech

    /**
      * rightSretch : bool
      */
    property bool rightSretch: strech

    /**
      * middleStrech : bool
      */
    property bool middleStrech: strech

    EdgeShadow
    {
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXEnd && !control.fits && control.flickable
        opacity: 0.7
        z: 999
        edge: Qt.RightEdge
        anchors
        {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }

    EdgeShadow
    {
        width: Maui.Style.iconSizes.medium
        height: parent.height
        visible: !mainFlickable.atXBeginning && !control.fits && control.flickable
        opacity: 0.7
        z: 999
        edge: Qt.LeftEdge
        anchors
        {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Kirigami.WheelHandler
    {
        id: wheelHandler
        target: mainFlickable
    }

    Item
    {
        anchors.fill: parent

        DragHandler
        {
            acceptedDevices: PointerDevice.GenericPointer
            grabPermissions:  PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
            onActiveChanged: if (active) { root.startSystemMove(); }
        }
        //
        /*  TapHandler
            {
                grabPermissions:  PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
                onTapped: if (tapCount === 2) root.toggleMaximized()
                gesturePolicy: TapHandler.DragThreshold
            } */
    }

    ScrollView
    {
        id: _scrollView
        property bool fits : mainFlickable.contentWidth < control.width
        onFitsChanged: mainFlickable.returnToBounds()

        height: control.implicitHeight
        width: control.width

        contentWidth: mainFlickable.contentWidth
        contentHeight: height

        states: [State
            {
                when: control.position === ToolBar.Header

                AnchorChanges
                {
                    target: _scrollView
                    anchors.top: undefined
                    anchors.bottom: parent.bottom
                }
            },

            State
            {
                when: control.position === ToolBar.Footer

                AnchorChanges
                {
                    target: _scrollView
                    anchors.top: parent.top
                    anchors.bottom: undefined
                }
            }
        ]

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        /* ScrollBar.horizontal: ScrollBar {parent: _scrollView; visible: false;}
             *        ScrollBar.vertical: ScrollBar {parent: _scrollView; visible: false}     */

        Flickable
        {
            id: mainFlickable

            anchors.fill: parent

            anchors.leftMargin: control.margins
            anchors.rightMargin: control.margins

            flickableDirection: Flickable.HorizontalFlick
            interactive: !fits && Maui.Handy.isTouch
            contentWidth: layout.implicitWidth

            boundsBehavior: Kirigami.Settings.isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
            clip: true

            RowLayout
            {
                id: layout
                width: mainFlickable.width
                height: mainFlickable.height
                spacing: control.spacing

                Row
                {
                    id: _leftContent
                    readonly property int alignment : Qt.AlignLeft
                    Layout.fillHeight: true

                    Layout.preferredWidth: implicitWidth
                    Layout.maximumWidth: implicitWidth
                    Layout.minimumWidth: implicitWidth

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    spacing: farLeftRowContent.visibleChildren.length > 0 ? control.spacing : 0

                    RowLayout
                    {
                        id: farLeftRowContent
                        readonly property int alignment : Qt.AlignLeft
                        height: parent.height
                        spacing: control.spacing
                    }

                    RowLayout
                    {
                        id: leftRowContent
                        readonly property int alignment : Qt.AlignLeft

                        spacing: control.spacing
                        height: parent.height
                    }
                }

                Item //helper to force center middle content
                {
                    visible: control.forceCenterMiddleContent && control.leftSretch
                    Layout.minimumWidth: 0
                    Layout.fillWidth: visible
                    Layout.maximumWidth: visible ? Math.max(_rightContent.implicitWidth - _leftContent.implicitWidth, 0) : 0
                }

                RowLayout
                {
                    id: middleRowContent
                    readonly property int alignment : Qt.AlignCenter

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spacing: visibleChildren.length > 1 ? control.spacing : 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
//                    Layout.preferredWidth: implicitWidth
//                    Layout.maximumWidth: implicitWidth
//                    Layout.minimumWidth: implicitWidth
                    Layout.minimumWidth: implicitWidth
                }

                Item //helper to force center middle content
                {
                    visible: control.forceCenterMiddleContent && control.rightSretch
                    Layout.minimumWidth: 0
                    Layout.fillWidth: visible
                    Layout.maximumWidth: visible ? Math.max(_leftContent.implicitWidth-_rightContent.implicitWidth, 0) : 0
                }

                Row
                {
                    id: _rightContent
                    readonly property int alignment : Qt.AlignRight
                    Layout.fillHeight: true

                    Layout.preferredWidth: implicitWidth
                    Layout.maximumWidth: implicitWidth
                    Layout.minimumWidth: implicitWidth

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    spacing: farRightRowContent.visibleChildren.length > 0 ? control.spacing : 0

                    RowLayout
                    {
                        id: rightRowContent
                        readonly property int alignment : Qt.AlignRight
                        spacing: control.spacing
                        height: parent.height
                    }

                    RowLayout
                    {
                        id: farRightRowContent
                        readonly property int alignment : Qt.AlignRight
                        spacing: control.spacing
                        height: parent.height
                    }
                }
            }
        }
    }
}
