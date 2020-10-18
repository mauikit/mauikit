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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "private" as Private

Maui.Page
{
    id: control

    //aliases
    property alias currentPath : _browser.path
    onCurrentPathChanged : _searchField.clear()
    
    property alias settings : _browser.settings

    property alias view : _stackView.currentItem

    property alias dropArea : _dropArea

    readonly property QtObject currentView : _stackView.currentItem.currentView
    readonly property Maui.FMList currentFMList : view.currentFMList
    readonly property Maui.BaseModel currentFMModel : view.currentFMModel
    readonly property bool isSearchView : _stackView.currentItem.objectName === "searchView"

    // custom props
    property bool selectionMode: false

    property int thumbnailsSize : Maui.Style.iconSizes.large * 1.7

    property var indexHistory : []

    // need to be set by the implementation as features
    property Maui.SelectionBar selectionBar : null
    property Maui.TagsDialog tagsDialog : null
    property Maui.OpenWithDialog openWithDialog : null

    //relevant menus to file item and the browserview
    property alias browserMenu: browserMenu
    property alias itemMenu: itemMenu

    //access to the loaded the dialog components
    property alias dialog : dialogLoader.item

    //signals
    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    signal itemLeftEmblemClicked(int index)
    signal itemRightEmblemClicked(int index)
    signal rightClicked()
    signal keyPress(var event)
    signal urlsDropped(var urls)

    //color scheme
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    //catch inherited signals from page
    onGoBackTriggered: control.goBack()
    onGoForwardTriggered: control.goNext()

    title: view.title
    focus: true
    flickable: control.currentView.flickable
    floatingFooter: false

    showTitle: false
    headBar.visible: false
    headBar.leftContent: ToolButton
    {
        text: i18n("Back")
        icon.name: "go-previous"
        onClicked: control.quitSearch()
        visible: control.isSearchView
    }

    headBar.middleContent: Maui.TextField
    {
        id: _searchField
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: _filterButton.checked ? i18n("Filter") : ("Search")
        inputMethodHints: Qt.ImhNoAutoUppercase

        onAccepted: 
        {
            if(_filterButton.checked)
            {
                 control.view.filter = text
            }else
            {
                 control.search(text)
            }            
        }
        onCleared:
        {
            if(_filterButton.checked)
            {
                 control.view.filter = ""
            }
        }
        onTextChanged:
        {
            if(_filterButton.checked)
                _searchField.accepted()              
                
        }
        Keys.enabled: _filterButton.checked
        Keys.onPressed:
        {
            // Shortcut for clearing selection
            if(event.key == Qt.Key_Up)
            {
                control.currentView.forceActiveFocus()
            }
        }
        
        actions.data: ToolButton
        {
            id: _filterButton
            icon.name: "view-filter"
//             text: i18n("Filter")
            checkable: true
            checked: true
            flat: true
            onClicked:
            {
                control.view.filter = ""
                _searchField.clear()
                _searchField.forceActiveFocus()
            }
        }
    }
    
    footBar.visible: String(control.currentPath).startsWith("trash:/")

    footBar.leftSretch: false
    footerPositioning: ListView.InlineFooter

    footBar.rightContent: ToolButton
    {
        visible: String(control.currentPath).startsWith("trash:/")
        icon.name: "trash-empty"
        text: i18n("Empty Trash")
        onClicked: Maui.FM.emptyTrash()
    }

    Loader
    {
        id: dialogLoader
        // 		active: item && item.visible
    }

    Component
    {
        id: removeDialogComponent

        Maui.Dialog
        {
            id: _removeDialog
            property var urls: []

            title:  i18n("Removing %1 files", urls.length)
            message: Maui.Handy.isAndroid ?  i18n("This action will completely remove your files from your system. This action can not be undone.") : i18n("You can move the file to the trash or delete it completely from your system. Which one do you prefer?")
            rejectButton.text: i18n("Delete")
            acceptButton.text: i18n("Trash")
            acceptButton.visible: Maui.Handy.isLinux
            page.margins: Maui.Style.space.big
            template.iconSource: urls.length === 1 ? Maui.FM.getFileInfo(urls[0]).icon : "emblem-warning"
            template.imageSource: urls.length === 1 ? Maui.FM.getFileInfo(urls[0]).thumbnail : ""
            
            actions: Action
            {
                text: i18n("Cancel")
                onTriggered: _removeDialog.close()
            }

            CheckBox
            {
                id: _removeDialogFilesCheckBox
                Layout.fillWidth: true

                text: i18n("List files")
            }

            Repeater
            {
                model: urls

                Label
                {
                    visible: _removeDialogFilesCheckBox.checked
                    Layout.fillWidth: true
                    text: modelData
                    wrapMode: Text.WordWrap
                }
            }

            onRejected:
            {
                Maui.FM.removeFiles(urls)
                close()
            }

            onAccepted:
            {
                Maui.FM.moveToTrash(urls)
                close()
            }
        }
    }

    Component
    {
        id: newFolderDialogComponent

        Maui.NewDialog
        {
            title: i18n("New Folder")
            message: i18n("Create a new folder with a custom name")
            template.iconSource: "folder"
            acceptButton.text: i18n("Create")
            onFinished: control.currentFMList.createDir(text)
            textEntry.placeholderText: i18n("Folder name")
        }
    }

    Component
    {
        id: newFileDialogComponent

        Maui.NewDialog
        {
            title: i18n("New File")
            message: i18n("Create a new file with a custom name and extension")
            template.iconSource: "text-plain"
            acceptButton.text: i18n("Create")
            onFinished: Maui.FM.createFile(control.currentPath, text)
            textEntry.placeholderText: i18n("Filename")
        }
    }

    Component
    {
        id: renameDialogComponent
        Maui.NewDialog
        {
            property var item : control.currentFMList ? control.currentFMList.get(control.currentView.currentIndex) : ({})
            title: i18n("Rename")
            message: i18n("Change the name of a file or folder")
            template.iconSource: "emblem-important"
            textEntry.text: item.label
            textEntry.placeholderText: i18n("New name")
            onFinished: Maui.FM.rename(item.path, textEntry.text)
            onRejected: close()
            acceptButton.text: i18n("Rename")
            rejectButton.text: i18n("Cancel")
        }
    }

    Private.BrowserMenu { id: browserMenu }

    Private.FileMenu
    {
        id: itemMenu
        width: Maui.Style.unit * 200
        onBookmarkClicked: control.bookmarkFolder([item.path])
        onCopyClicked:
        {
            if(item)
                control.copy([item.path])
        }

        onCutClicked:
        {
            if(item)
                control.cut([item.path])
        }

        onTagsClicked:
        {
            if(item && control.tagsDialog)
            {
                control.tagsDialog.composerList.urls = [item.path]
                control.tagsDialog.open()
            }
        }

        onRenameClicked:
        {
            dialogLoader.sourceComponent = renameDialogComponent
            dialog.open()
        }

        onRemoveClicked:
        {
            console.log("REMOVE", item.path)
            control.remove([item.path])
        }

        onOpenWithClicked: control.openWith([item.path])
        onShareClicked: control.shareFiles([item.path])
    }

   
    Connections
    {
        target: control.tagsDialog
        enabled: control.tagsDialog
        ignoreUnknownSignals: true

        function onTagsReady(tags)
        {
            control.tagsDialog.composerList.updateToUrls(tags)            
        }
    }

    Connections
    {
        enabled: control.currentView
        target: control.currentView
        ignoreUnknownSignals: true

        function onKeyPress(event)
        {
            const index = control.currentView.currentIndex
            const item = control.currentFMList.get(index)

            // Shortcuts for refreshing
            if((event.key === Qt.Key_F5))
            {
                control.currentFMList.refresh()
            }

            // Shortcuts for renaming
            if((event.key === Qt.Key_F2))
            {
                dialogLoader.sourceComponent = renameDialogComponent
                dialog.open()
            }

            // Shortcuts for selecting file
            if((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier))
            {
                control.selectAll()
            }          

            if((event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                if(control.selectionBar && control.selectionBar.contains(item.path))
                {
                    control.selectionBar.removeAtUri(item.path)
                }else
                {
                    control.addToSelection(item)
                }
            }

            //shortcut for opening files
            if(event.key === Qt.Key_Return)
            {
                indexHistory.push(index)
                control.openItem(index)
            }

            // Shortcut for pasting an item
            if((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier))
            {
                control.paste(Maui.Handy.getClipboard().urls)
            }

            // Shortcut for cutting an item
            if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier))
            {
                const urls = filterSelection(control.currentPath, item.path)
                control.cut(urls)
            }

            // Shortcut for copying an item
            if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier))
            {
                const urls = filterSelection(control.currentPath, item.path)
                control.copy(urls)
            }

            // Shortcut for removing an item
            if(event.key === Qt.Key_Delete)
            {
                const urls = filterSelection(control.currentPath, item.path)
                control.remove(urls)
            }

            // Shortcut for going back in browsing history
            if(event.key === Qt.Key_Backspace || event.key == Qt.Key_Back)
            {
                if(control.selectionBar && control.selectionBar.count> 0)
                {
                    control.selectionBar.clear()
                }
                else
                {
                    control.goBack()
                }
            }

            // Shortcut for clearing selection and filtering
            if(event.key === Qt.Key_Escape) //TODO not working, the event is not catched or emitted or is being accepted else where?
            {
                if(control.selectionBar && control.selectionBar.count > 0)
                    control.selectionBar.clear()

                control.view.filter = ""
            }

            //Shortcut for opening filtering
            if((event.key === Qt.Key_F) && (event.modifiers & Qt.ControlModifier))
            {
                control.headBar.visible = !control.headBar.visible
                _searchField.forceActiveFocus()
            }                    
            
            control.keyPress(event)
        }
        
        function onItemsSelected(indexes)
        {
            control.selectIndexes(indexes)
        }

        function onItemClicked(index)
        {
            control.currentView.currentIndex = index
            indexHistory.push(index)
            control.itemClicked(index)
            control.currentView.forceActiveFocus()
        }

        function onItemDoubleClicked(index)
        {
            control.currentView.currentIndex = index
            indexHistory.push(index)
            control.itemDoubleClicked(index)
            control.currentView.forceActiveFocus()
        }

        function onItemRightClicked(index)
        {
            if(control.currentFMList.pathType !== Maui.FMList.TRASH_PATH && control.currentFMList.pathType !== Maui.FMList.REMOTE_PATH)
            {
                itemMenu.show(index)
            }
            control.itemRightClicked(index)
            control.currentView.forceActiveFocus()
        }

        function onItemToggled(index)
        {
            const item = control.currentFMList.get(index)

            if(control.selectionBar && control.selectionBar.contains(item.path))
            {
                control.selectionBar.removeAtUri(item.path)
            }else
            {
                control.addToSelection(item)
            }
            control.itemLeftEmblemClicked(index)
            control.currentView.forceActiveFocus()
        }

        function onAreaClicked(mouse)
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                browserMenu.show(control)
            else return

            control.rightClicked()
            control.currentView.forceActiveFocus()
        }

        function onAreaRightClicked(mouse)
        {
            browserMenu.show(control)
        }
    }
    
    StackView
    {
        id: _stackView

        anchors.fill: parent
        clip: true

        initialItem: DropArea
        {
            id: _dropArea
            property alias currentView : _browser.currentView
            property alias currentFMList : _browser.currentFMList
            property alias currentFMModel: _browser.currentFMModel
            property alias filter: _browser.filter
            property alias title : _browser.title

            onDropped:
            {
                if(drop.urls)
                {
                    _dropMenu.urls = drop.urls.join(",")
                    _dropMenu.popup()
                    control.urlsDropped(drop.urls)
                }
            }

            opacity:  _dropArea.containsDrag ? 0.5 : 1

            Private.BrowserView
            {
                id: _browser
                anchors.fill: parent
                selectionMode: control.selectionMode
            }

            Menu
            {
                id: _dropMenu
                property string urls
                enabled: Maui.FM.getFileInfo(control.currentPath).isdir == "true"

                MenuItem
                {
                    text: i18n("Copy here")
                    onTriggered:
                    {
                        const urls = _dropMenu.urls.split(",")
                        Maui.FM.copy(urls, control.currentPath, false)
                    }
                }

                MenuItem
                {
                    text: i18n("Move here")
                    onTriggered:
                    {
                        const urls = _dropMenu.urls.split(",")
                        Maui.FM.cut(urls, control.currentPath)
                    }
                }

                MenuItem
                {
                    text: i18n("Link here")
                    onTriggered:
                    {
                        const urls = _dropMenu.urls.split(",")
                        for(var i in urls)
                            Maui.FM.createSymlink(urls[i], control.currentPath)
                    }
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Cancel")
                    onTriggered: _dropMenu.close()
                }
            }
        }

        Component
        {
            id: _searchBrowserComponent

            Private.BrowserView
            {
                id: _searchBrowser
                objectName: "searchView"
                settings.viewType: control.settings.viewType === Maui.FMList.MILLERS_VIEW ? Maui.FMList.LIST_VIEW : control.settings.viewType // do not use millersview it does not makes sense since search does not follow a path url structures
            }
        }
    }

    Component.onCompleted:
    {
        control.currentView.forceActiveFocus()
    }


    /**
      *
      **/
    function tagFiles(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

        if(control.tagsDialog)
        {
            control.tagsDialog.composerList.urls = urls
            control.tagsDialog.open()
        }
    }
    
    /**
      *
      **/
    function openWith(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

        if(control.openWithDialog)
        {
            openWithDialog.urls = urls
            openWithDialog.open()
        }
    }

    /**
      *
      **/
    function shareFiles(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

       Maui.Platform.shareFiles(urls)        
    }
    
    /**
      *
      **/
    function copy(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

        Maui.Handy.copyToClipboard({"urls": urls}, false)
    }

    /**
      *
      **/
    function cut(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

        Maui.Handy.copyToClipboard({"urls": urls}, true)
    }

    /**
      *
      **/
    function paste()
    {
        const data = Maui.Handy.getClipboard()
        const urls = data.urls
        
        if(!urls)
        {
            return
        }
        if(data.cut)
        {
            control.currentFMList.cutInto(urls)
        }else
        {
            control.currentFMList.copyInto(urls)
        }
    }

    /**
      *
      **/
    function remove(urls)
    {
        if(urls.length <= 0)
        {
            return
        }

        dialogLoader.sourceComponent= removeDialogComponent
        dialog.urls = urls
        dialog.open()
    }

    /**
      *
      **/
    function openItem(index)
    {
        const item = control.currentFMList.get(index)
        const path = item.path

        switch(control.currentFMList.pathType)
        {
        case Maui.FMList.CLOUD_PATH: //TODO deprecrated and needs to be removed or clean up for 1.1
            if(item.isdir === "true")
            {
                control.openFolder(path)
            }
            else
            {
                Maui.FM.openCloudItem(item)
            }
            break;
        default:
            if(control.selectionMode && item.isdir == "false")
            {
                if(control.selectionBar && control.selectionBar.contains(item.path))
                {
                    control.selectionBar.removeAtPath(item.path)
                }else
                {
                    control.addToSelection(item)
                }
            }
            else
            {
                if(item.isdir == "true")
                {
                    control.openFolder(path)
                }
                else
                {                    
                    control.openFile(path)                    
                }
            }
        }
    }

    /**
      *
      **/
    function openFile(path)
    {
        Maui.FM.openUrl(path)
    }

    /**
      *
      **/
    function openFolder(path)
    {
        if(!String(path).length)
        {
            return;
        }

        if(control.isSearchView)
        {
            control.quitSearch()
        }

        control.currentPath = path
    }

    /**
      *
      **/
    function goBack()
    {
        openFolder(control.currentFMList.previousPath)
        //        control.currentView.currentIndex = indexHistory.pop()
    }

    /**
      *
      **/
    function goNext()
    {
        openFolder(control.currentFMList.posteriorPath)
    }

    /**
      *
      **/
    function goUp()
    {
        openFolder(control.currentFMList.parentPath)
    }

    /**
      * For this to work the implementation needs to have passed a selectionBar
      **/
    function addToSelection(item)
    {
        if(control.selectionBar == null || item.path.startsWith("tags://") || item.path.startsWith("applications://"))
        {
            return
        }

        control.selectionBar.append(item.path, item)
    }


    /**
      * Given a list of indexes add them to the selectionBar
      **/
    function selectIndexes(indexes)
    {
        if(control.selectionBar == null)
        {
            return
        }

        for(var i in indexes)
            addToSelection(control.currentFMList.get(indexes[i]))
    }

    /**
      *
      **/
    function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
    {
        if(control.selectionBar == null)
        {
            return
        }

        selectIndexes([...Array( Math.min(control.currentFMList.count, 100)).keys()])
    }

    /**
      *
      **/
    function bookmarkFolder(paths) //multiple paths
    {
        for(var i in paths)
        {
            Maui.FM.bookmark(paths[i])
        }
    }

       
    /**
      *
      **/
    function openSearch()
    {
        if(!control.isSearchView)
        {
            _stackView.push(_searchBrowserComponent, StackView.Immediate)
        }
        _searchField.forceActiveFocus()
    }

    /**
      *
      **/
    function quitSearch()
    {
        _stackView.pop(StackView.Immediate)
    }
    
    /**
      *
      **/
    function search(query)
    {
        openSearch()
        _stackView.currentItem.title = i18n("Search: %1").arg(query)
        _stackView.currentItem.currentFMList.search(query, _browser.currentFMList)
    }
    
    /**
      *
      **/
    function newFile()
    {
        dialogLoader.sourceComponent= newFileDialogComponent
        dialog.open()
        dialog.forceActiveFocus()
    }
    
    /**
      *
      **/
    function newFolder()
    {
        dialogLoader.sourceComponent= newFolderDialogComponent
        dialog.open()
        dialog.forceActiveFocus()
    }

    /**
      * Filters the content of the selection to the current path. The currentPath must be a directory, so the selection can be compared if it is its parent directory. The itemPath is a default item path in case the selectionBar is empty
      **/
    function filterSelection(currentPath, itemPath)
    {
        var res = []

        if(selectionBar && selectionBar.count > 0 && selectionBar.contains(itemPath))
        {
            const uris = selectionBar.uris
            for(var uri of uris)
            {
                if(Maui.FM.parentDir(uri) === currentPath)
                {
                    res.push(uri)
                }
            }

        } else
        {
            res = [itemPath]
        }

        return res
    }
}
