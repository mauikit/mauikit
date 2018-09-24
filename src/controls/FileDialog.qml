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
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

Popup
{
    id: control
    height: parent.height *  (isMobile ? 1 : 0.65)
    width: parent.width * (isMobile ? 1 : 0.7)

    x: parent.width/2  - width/2
    y: parent.height/2 - height/2
    parent: ApplicationWindow.overlay

    modal: true
    margins: 0
    padding: unit * 1
    closePolicy: Popup.CloseOnPressOutsideParent

    property string initPath

    property var filter: []
    property bool onlyDirs : false
    property bool multipleSelection: false
    property bool saveDialog : false
    property bool openDialog : true

    property var callback : ({})
    signal placeClicked (string path)
    signal selectionReady(var paths)

    Maui.NewDialog
    {
        id: newFolderDialog
        title: qsTr("New Folder")
        onFinished: Maui.FM.createDir(browser.currentPath, text)
    }

    Maui.Page
    {
        anchors.fill: parent
        leftPadding: 0
        margins: 0
        rightPadding: leftPadding
        topPadding: leftPadding
        bottomPadding: leftPadding
        headBarExit: false
        headBarTitleVisible: false
        headBar.height: headBar.implicitHeight * 1.1
        headBar.middleContent: Maui.PathBar
        {
            id: pathBar
            height: iconSizes.big
            width: (content.width * 0.8) - btn.width

            onPathChanged: browser.openFolder(path)
            onHomeClicked:
            {
                if(pageRow.currentIndex !== 0 && !pageRow.wideMode)
                    pageRow.currentIndex = 0

                browser.openFolder(Maui.FM.homePath())
            }

            onPlaceClicked: browser.openFolder(path)
        }

        headBar.rightContent:  Maui.ToolButton
        {
            iconName: "overflow-menu"
            onClicked: optionsMenu.visible ? optionsMenu.close() : optionsMenu.popup()
        }

        headBar.leftContent: Maui.ToolButton
        {
            iconName: "dialog-close"
            onClicked: closeIt()
        }

        Kirigami.PageRow
        {
            id: pageRow
            anchors.fill: parent
            clip: true

            property int sidebarWidth: sidebar.isCollapsed ? sidebar.iconSize * 2 :
                                                             Kirigami.Units.gridUnit * (isMobile? 15 : 8)

            separatorVisible: wideMode
            initialPage: [sidebar, content]
            defaultColumnWidth: sidebarWidth
            interactive: currentIndex === 1

            Maui.SideBar
            {
                id: sidebar
                focus: true
                width: isCollapsed ? iconSize*2 : parent.width
                height: parent.height
                section.property :  !sidebar.isCollapsed ? "type" : ""
                section.criteria: ViewSection.FullString
                section.delegate: Maui.LabelDelegate
                {
                    id: delegate
                    label: section
                    labelTxt.font.pointSize: fontSizes.big

                    isSection: true
                    boldLabel: true
                    height: toolBarHeightAlt
                }

                onItemClicked:
                {
                    browser.openFolder(item.path)
                    placeClicked(item.path)

                    if(pageRow.currentIndex === 0 && !pageRow.wideMode)
                        pageRow.currentIndex = 1
                }


                function populate()
                {
                    sidebar.model.clear()
                    var places = Maui.FM.getDefaultPaths()
                    places.push(Maui.FM.getBookmarks())
                    places.push(Maui.FM.getDevices())

                    if(places.length > 0)
                        for(var i in places)
                            sidebar.model.append(places[i])

                }
            }

            Maui.Page
            {
                id: content
                leftPadding: Kirigami.Units.devicePixelRatio
                rightPadding: leftPadding
                topPadding: leftPadding
                bottomPadding: leftPadding
                margins: 0

                headBarVisible: false
                footBar.leftContent:  Maui.ToolButton
                {
                    id: viewBtn
                    iconName:  browser.detailsView ? "view-list-icons" : "view-list-details"
                    onClicked: browser.switchView()
                }


                footBar.middleContent: Row
                {
                    spacing: space.medium
                    Maui.ToolButton
                    {
                        iconName: "go-previous"
                        onClicked: browser.goBack()
                    }

                    Maui.ToolButton
                    {
                        iconName: "go-up"
                        onClicked: browser.goUp()
                    }

                    Maui.ToolButton
                    {
                        iconName: "go-next"
                        onClicked: browser.goNext()
                    }
                }

                footBar.rightContent:  [

                    Maui.ToolButton
                    {
                        id: btn
                        iconName: "dialog-ok"
                        iconColor: highlightColor
                        onClicked:
                        {
                            selectionReady(browser.selectedPaths)
                            callback(browser.selectedPaths)
                            close()
                        }
                    }
                ]

                Menu
                {
                    id: optionsMenu
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height / 2
                    modal: true
                    focus: true
                    parent: ApplicationWindow.overlay
                    margins: 1
                    padding: 2

                    MenuItem
                    {
                        text: qsTr("Compact mode")
                        onTriggered: sidebar.isCollapsed = !sidebar.isCollapsed
                    }

                    MenuItem
                    {
                        text: qsTr("New folder")
                        onTriggered: newFolderDialog.open()
                    }
                }

                ColumnLayout
                {
                    anchors.fill: parent

                    Browser
                    {
                        id: browser
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                    }

                    Maui.ToolBar
                    {
                        visible: saveDialog
                        position: ToolBar.Footer
                        Layout.fillWidth: true
                        middleContent: TextField
                        {
                            width: saveDialog.width
                            placeholderText: qsTr("File name")
                        }
                    }
                }
            }
        }
    }

    function show(cb)
    {
        callback = cb
        sidebar.populate()

        if(initPath)
            browser.openFolder(initPath)
        else
            browser.openFolder(browser.currentPath)

        open()
    }

    function closeIt()
    {
        browser.clearSelection()
        close()
    }

}
