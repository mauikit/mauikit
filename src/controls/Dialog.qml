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
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.9 as Kirigami

import QtGraphicalEffects 1.0

/**
 * Dialog
 * A scrollable dialog popup, with a Page as its main content.
 * With default buttons styled, a close button and a predefiend layout.
 *
 * The dialog can be used with its main default ColumnLayout or with an Item stacked.
 *
 * The dialog contents will be hanlded by a ColumnLayout, so the positioning of its child elements should use the attached property
 * Layout.fillheight layout.fillWidth, etc.
 *
 *
 */
Maui.Popup
{
    id: control

    /**
      * scrollable : ColumnLayout.data
      * Default content will be added to a scrollable ColumnLayout.
      * When adding a item keep on mind that to correctly have the scrollable behavior
      * the item must have an implicit height. And the positioning should be done via the Layout attached properties.
      */
    default property alias scrollable : _pageContent.data

    /**
      * stack : ColumnLayout.data
      * To skip the scrollable behavior there is a stacked component to which items can be added, this is also
      * controlled by a ColumnLayout
      */
    property alias stack : _stack.data

    /**
      * message : string
      * Default message text inside the scrollable layout.
      */
    property string message : ""

    /**
      * title : string
      * Default title text or title of the dialog page.
      */
    property alias title : _page.title

    /**
      * template : ListItemTemplate
      * The templated item used for the default dialog message, holding the icon emblem and the message body.
      * This property gives access to the template for more detailed tweaking, by adding items or changing its properties.
      */
    property alias template : _template

    /**
      * actions : list<Action>
      * List of actions to be added to the dialog footer bar as styled buttons.
      */
    property list<Action> actions

    /**
      * defaultButtons : bool
      * If the Accept and Reject buttons should by displayed in the footer bar.
      */
    property bool defaultButtons: true

    /**
      * persistent : bool
      * If the dialog should be closed when it loses focus or not.
      * If it is marked as persistent a close button is shown in the header bar, other wise the header bar is
      * hidden if there is not more elements on it.
      */
    property bool persistent : true

    /**
      * acceptButton : Button
      * Access to the accepted button.
      * This button is styled to hint about a positive feedback.
      */
    property alias acceptButton : _acceptButton

    /**
      * rejectButton : Button
      * Access to the accepted button.
      * This button is styled to hint about a negative feedback.
      */
    property alias rejectButton : _rejectButton

    /**
      * textEntry : TextEntry
      * Access to the optional text entry.
      */
    property alias textEntry : _textEntry

    /**
      * entryField : bool
      *  If a text entry should be visible under the dialog body message.
      */
    property bool entryField: false

    /**
      * page : Page
      * Access to the default dialog content.
      */
    property alias page : _page

    /**
      * footBar : ToolBar
      * Dialog footer bar.
      */
    property alias footBar : _page.footBar

    /**
      * headBar : ToolBar
      * Dialog header bar.
      */
    property alias headBar: _page.headBar

    /**
      * closeButton : MouseArea
      * MouseArea for the close button when the dialog is marked as persistent.
      */
    property alias closeButton: _closeButton

    /**
      * accepted :
      * Triggered when the accepted button is clicked.
      */
    signal accepted()

    /**
      * rejected :
      * Triggered when the rejected button is clicked.
      */
    signal rejected()

    closePolicy: control.persistent ? Popup.NoAutoClose | Popup.CloseOnEscape : Popup.CloseOnEscape | Popup.CloseOnPressOutside

    maxWidth: 300
    maxHeight: implicitHeight
    implicitHeight: _layout.implicitHeight
    widthHint: 0.9
    heightHint: 0.9

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
            implicitHeight: Math.max(_scrollView.contentHeight, _stack.implicitHeight) + _page.footer.height + (_page.margins*2) + _page.header.height + Maui.Style.space.big
            headerPositioning: ListView.InlineHeader
            padding: 0
            headBar.visible: control.persistent
            headerBackground.color: "transparent"
            headBar.farLeftContent: MouseArea
            {
                id: _closeButton
                visible: control.persistent
                hoverEnabled: !Kirigami.Settings.isMobile
//                 Layout.fillHeight: true
                implicitWidth: Maui.Style.iconSizes.medium
                implicitHeight: Maui.Style.iconSizes.medium
                onClicked: close()

                Rectangle
                {
                    height: Maui.Style.iconSizes.medium
                    width: height
                    anchors.centerIn: parent
                    radius: height
                    color: _closeButton.containsMouse || _closeButton.containsPress ? Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)) : "transparent"

                    Maui.X
                    {
                        height: Maui.Style.iconSizes.tiny
                        width: height
                        anchors.centerIn: parent
                        color: _closeButton.containsMouse || _closeButton.containsPress ? Kirigami.Theme.negativeTextColor : Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.2))
                    }
                }
            }

            ColumnLayout
            {
                id: _stack
                anchors.fill: parent
                spacing: control.spacing
            }

            ScrollView
            {
                id: _scrollView
                anchors.fill: parent
                visible: _stack.children.length === 0

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Flickable
                {
                    id: _flickable
                    contentHeight: _pageContent.implicitHeight
                    clip: true

                    ColumnLayout
                    {
                        id: _pageContent
                        width: parent.width
                        spacing: control.spacing

                        Maui.ListItemTemplate
                        {
                            id: _template
                            visible: control.message.length || control.entryField
                            Layout.fillWidth: true
                            label2.text: message
                            label2.textFormat : TextEdit.AutoText
                            label2.wrapMode: TextEdit.WordWrap
                            
                            leftMargin: 0
                            rightMargin: 0

                            iconSizeHint: Maui.Style.iconSizes.large
                            spacing: Maui.Style.space.big
                            
                            leftLabels.spacing: control.spacing
                            leftLabels.data:  Maui.TextField
                            {
                                id: _textEntry
                                visible: control.entryField
                                Layout.fillWidth: true
                                focus: visible
                                onAccepted: control.accepted()
                            }
                        }                       

                        Label
                        {
                            id: _alertMessage
                            visible: text.length > 0
                            property int level : 0
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            verticalAlignment: Qt.AlignVCenter

                            color: switch(level)
                            {
                                case 0: return Kirigami.Theme.positiveTextColor
                                case 1: return Kirigami.Theme.neutralTextColor
                                case 2: return Kirigami.Theme.negativeTextColor
                            }

                            SequentialAnimation on x
                            {
                                id: _alertAnim
                                // Animations on properties start running by default
                                running: false
                                loops: 3
                                NumberAnimation { from: 0; to: -10; duration: 100; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: -10; to: 0; duration: 100; easing.type: Easing.InOutQuad }
                                PauseAnimation { duration: 50 } // This puts a bit of time between the loop
                            }
                        }
                    }
                }
            }
        }

        Maui.Separator
        {
            Layout.fillWidth: true
            visible: _defaultButtonsLayout.visible
        }

        RowLayout
        {
            id: _defaultButtonsLayout
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25)
            Layout.maximumHeight: Maui.Style.iconSizes.medium + (Maui.Style.space.medium * 1.25)
            visible: control.defaultButtons || control.actions.length

            Button
            {
                id: _rejectButton

                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: width
                visible: control.defaultButtons
                text: i18n("Cancel")
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

                onClicked: rejected()
                   Maui.Separator
                {
                    position: Qt.Vertical
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }
            }

            Button
            {
                id: _acceptButton

                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: width
                text: i18n("Accept")
                visible: control.defaultButtons
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

                Maui.Separator
                {
                    position: Qt.Vertical
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }
            }

            Repeater
            {
                model: control.actions

                Button
                {
                    id: _actionButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitWidth: width

                    action: modelData

                    background: Rectangle
                    {
                        color: _actionButton.hovered || _actionButton.down || _actionButton.pressed ? "#26c6da" : Kirigami.Theme.backgroundColor
                    }

                    contentItem: Label
                    {
                        text: _actionButton.text
                        color:  _actionButton.hovered || _actionButton.down || _actionButton.pressed ?  "#fafafa" : Kirigami.Theme.textColor
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Maui.Separator
                    {
                        position: Qt.Vertical
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        visible: index < control.actions.length-1
                    }
                }
            }
        }
    }
    
    onOpened: 
    {
        if(control.entryField)
            control.textEntry.forceActiveFocus()
    }
    
    /**
      * Send an alert message that is shown inline in the dialog.
      * Depending on the level the color may differ.
      */
    function alert(message, level)
    {
        _alertMessage.text = message
        _alertMessage.level = level
    }
}
