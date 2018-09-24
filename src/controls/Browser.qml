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
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    property string currentPath: Maui.FM.homePath()

    property var selectedPaths : []
    property var previousPath: []
    property var nextPath: []

    property bool selectionMode : false
    property bool detailsView: Maui.FM.loadSettings("BROWSER_VIEW", "BROWSER", false) === "false" ? false: true

    property alias selectionBar : selectionBar
    property alias grid : viewLoader.item
    //    property alias detailsDrawer: detailsDrawer
    //    property alias browserMenu: browserMenu

    property var views : ({
                              icon : 0,
                              details : 1,
                              tree : 2
                          })

    property int currentView : views.icon

    margins: detailsView ? 0 : contentMargins

    focus: true
    headBarVisible: false

    Connections
    {
        target: Maui.FM
        onPathModified: browser.refresh()
        onItemReady: browser.append(item)
    }

    Component
    {
        id: listViewBrowser

        Maui.ListBrowser
        {
            showEmblem: !saveDialog
        }
    }

    Component
    {
        id: gridViewBrowser

        Maui.GridBrowser
        {
            showEmblem: !saveDialog
        }
    }

    Connections
    {
        target: viewLoader.item
        onItemClicked: openItem(index)
        onItemDoubleClicked:
        {
            var item = viewLoader.item.model.get(index)

            if(Maui.FM.isDir(item.path))
                browser.openFolder(item.path)
            else
                browser.openFile(item.path)
        }
        onItemRightClicked: itemMenu.show(viewLoader.item.model.get(index).path)
        onLeftEmblemClicked: addToSelection(item, true)
        onAreaClicked: if(!isMobile && mouse.button === Qt.RightButton)
                           browserMenu.show()
        onAreaRightClicked: browserMenu.show()
    }

    Maui.Holder
    {
        id: holder
        message: Maui.FM.fileExists(currentPath) ? qsTr("<h3>Folder is empty!</h3><p>You can add new files to it</p>"):
                                                   qsTr("<h3>Folder doesn't exists!</h3><p>Create Folder?</p>")
        visible: viewLoader.item.count === 0

    }

    ColumnLayout
    {
        spacing: 0
        anchors.fill: parent
        visible: !holder.visible

        Item
        {
            id: browserContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: detailsView ? 0 : contentMargins

            ColumnLayout
            {
                anchors.fill: parent

                Loader
                {
                    id: viewLoader
                    sourceComponent: detailsView ? listViewBrowser : gridViewBrowser

                    Layout.topMargin: detailsView ? 0 : contentMargins * 2

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Maui.SelectionBar
                {
                    id: selectionBar
                    y: -20
                    visible: selectionList.count > 0
                    Layout.fillWidth: true
                    Layout.leftMargin: contentMargins*2
                    Layout.rightMargin: contentMargins*2
                    Layout.bottomMargin: contentMargins*2
                    iconVisible: false
                    onIconClicked: selectionReady(selectedPaths)
                    onExitClicked: clearSelection()
                    onModelCleared: clean()

                }
            }
        }
    }

    function openItem(index)
    {
        var item = viewLoader.item.model.get(index)
        if((selectionMode || multipleSelection) && !Maui.FM.isDir(item.path))
            addToSelection(item, true)
        else
        {
            var path = item.path
            selectedPaths = [path]

            if(Maui.FM.isDir(path))
                browser.openFolder(path)
            else
                browser.openFile(path)

        }
    }

    function clear()
    {
        viewLoader.item.model.clear()
    }

    function launchApp(path)
    {
        inx.runApplication(path, "")
    }

    function openFile(path)
    {
        pathBar.append(path)
    }

    function openFolder(path)
    {
        previousPath.push(currentPath)
        populate(path)

    }

    function populate(path)
    {
        currentPath = path
        clear()
        /* should it really return the paths or just use the signal? */
        var items = Maui.FM.getPathContent(path, onlyDirs, filter)

        for(var i=0; i < sidebar.count; i++)
            if(currentPath === sidebar.model.get(i).path)
                sidebar.currentIndex = i

        pathBar.append(currentPath)
        Maui.FM.watchPath(currentPath)
    }

    function append(item)
    {
        viewLoader.item.model.append(item)
    }

    function goBack()
    {
        nextPath.push(currentPath)
        populate(previousPath.pop())
    }

    function goNext()
    {
        openFolder(nextPath.pop())

    }

    function goUp()
    {
        openFolder(Maui.FM.parentDir(currentPath))
    }

    function refresh()
    {
        populate(currentPath)
    }

    function addToSelection(item, append)
    {
        var index = selectedPaths.indexOf(item.path)
        if(index < 0)
        {
            selectedPaths.push(item.path)
            selectionBar.append(item)
        }
        //        else
        //        {
        //            if (index !== -1)
        //                selectedPaths.splice(index, 1)
        //        }
    }

    function handleSelection()
    {
        if(selectedPaths.length > 0)
            selectionBar.visible = true

    }

    function clearSelection()
    {
        clean()
        browser.selectionMode = false
    }

    function clean()
    {
        selectedPaths = []
    }

    function copy(paths)
    {
        copyPaths = paths
        isCut = false
        isCopy = true
        console.log("Paths to copy", copyPaths)
    }

    function cut(paths)
    {
        cutPaths = paths
        isCut = true
        isCopy = false
    }

    function paste()
    {
        console.log("paste to", currentPath, copyPaths)
        if(isCopy)
            inx.copy(copyPaths, currentPath)
        else if(isCut)
            if(inx.cut(cutPaths, currentPath))
                clearSelection()

    }

    function remove(paths)
    {
        for(var i in paths)
            inx.remove(paths[i])
    }


    function switchView()
    {
        detailsView = !detailsView
        Maui.FM.saveSettings("BROWSER_VIEW", detailsView, "BROWSER")
        populate(currentPath)
    }

}
