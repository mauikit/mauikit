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
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtQuick.Layouts 1.3

/**
 * FileDialog
 * A file dialog to quickly open or save files.
 *
 * This component makes use of the FileBrowser.
 *
 * The FileDialog can be in two modes, one for Opening and other for Saving files.
 *
 * The file dialog allows to have multiple or single selection,
 * and filtering content specific to a file type or arbitrary name filters.
 *
 */
Maui.Dialog
{
    id: control
    maxHeight: Kirigami.Settings.isMobile ? parent.height * 0.95 : 500
    maxWidth: 700
    page.padding: 0

    /**
      * currentPath : url
      * The current path of the directory URL.
      * To list a directory path, or other location, use the right schemas,
      * some of them are file://, webdav://, trash:///, tags://
      */
    property alias currentPath : browser.currentPath

    /**
      * browser : FileBrowser
      * The FileBrowser used to listing.
      * For more details on how it works check its documentation.
      */
    readonly property alias browser : browser

    /**
      * selectionBar : SelectionBar
      */
    readonly property alias selectionBar: _selectionBar

    /**
      * singleSelection : bool
      * If true then only one item can be selected, either for saving or for opening.
      */
    property alias singleSelection : _selectionBar.singleSelection

    /**
      * suggestedFileName : string
      * On save mode a text field is visible and this property is used to assign its default text value.
      */
    property string suggestedFileName : ""

    /**
      * settings : BrowserSettings
      * A group of properties for controlling the sorting, listing and behaviour of the file browser.
      * For more details check the BrowserSettings documentation.
      */
    readonly property alias settings : browser.settings

    /**
      * searchBar : bool
      * Show the search bar to enter a search query.
      */
    property bool searchBar : false
    onSearchBarChanged: if(!searchBar) browser.quitSearch()

    /**
      * modes : var
      * There are two modes: Save : 1, to save files with a given file name or
      * Open : 0 to open one or multiple files.
      */
    readonly property var modes : ({OPEN: 0, SAVE: 1})

    /**
      * mode : int
      * The current mode in use. By default the Open : 0 mode is used.
      */
    property int mode : modes.OPEN

       /**
      * textField : TextField
      * On Save mode a text field is visible, this property gives access to it.
      */
    property alias textField: _textField

    /**
      * urlsSelected :
      * Triggered once the urls have been selected.
      */
    signal urlsSelected(var urls)

    /**
      * finished :
      * The selection has been done
      */
    signal finished(var urls)

    page.headerBackground.color: Kirigami.Theme.backgroundColor
    rejectButton.text: i18n("Cancel")
    acceptButton.text: control.mode === modes.SAVE ? i18n("Save") : i18n("Open")

    onRejected: control.close()

    onAccepted:
    {
        console.log("CURRENT PATHb", browser.currentPath+"/"+textField.text)
        if(control.mode === modes.SAVE && Maui.FM.fileExists(browser.currentPath+"/"+textField.text))
        {
            _confirmationDialog.open()
        }else
        {
            done()
        }
    }

    page.footerColumn: [

    Maui.ToolBar
    {
        visible: control.mode === modes.SAVE
        width: parent.width
        position: ToolBar.Footer

        middleContent: Maui.TextField
        {
            id: _textField
            Layout.fillWidth: true
            placeholderText: i18n("File name...")
            text: suggestedFileName
        }
    },

    Maui.TagsBar
    {
        id: _tagsBar
        visible: control.mode === modes.SAVE
        position: ToolBar.Footer
        width: parent.width
        list.urls: [""]
        list.strict: false
        allowEditMode: true
        Kirigami.Theme.textColor: control.Kirigami.Theme.textColor
        Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
    }
    ]

    Component
    {
        id: _pathBarComponent

        Maui.PathBar
        {
            onPathChanged: browser.openFolder(path)
            url: browser.currentPath
            onHomeClicked: browser.openFolder(Maui.FM.homePath())
            onPlaceClicked: browser.openFolder(path)
        }
    }

    Component
    {
        id: _searchFieldComponent

        Maui.TextField
        {
            placeholderText: i18n("Search for files... ")
            onAccepted: browser.search(text)
            onCleared: browser.quitSearch()
            onGoBackTriggered:
            {
                searchBar = false
                clear()
            }

            background: Rectangle
            {
                border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
                radius: Maui.Style.radiusV
                color: Kirigami.Theme.backgroundColor
            }
        }
    }

    headBar.visible: true
    headBar.middleContent: Loader
    {
        Layout.fillWidth: true
        Layout.preferredHeight: Maui.Style.iconSizes.big
        sourceComponent: searchBar ? _searchFieldComponent : _pathBarComponent
    }

    headBar.rightContent: ToolButton
    {
        id: searchButton
        icon.name: "edit-find"
        onClicked: searchBar = !searchBar
        checked: searchBar
    }

    Maui.Dialog
    {
        id: _confirmationDialog

        acceptButton.text: i18n("Yes")
        rejectButton.text: i18n("No")

        title: i18n("A file named %1 already exists!").arg(textField.text)
        message: i18n("This action will overwrite %1. Are you sure you want to do this?").arg(textField.text)

        onAccepted: control.done()
        onRejected: close()
    }

    stack: Kirigami.PageRow
    {
        id: pageRow
        Layout.fillHeight: true
        Layout.fillWidth: true

        separatorVisible: wideMode
        initialPage: [sidebar, _browserLayout]
        defaultColumnWidth: 160 * (Kirigami.Settings.isMobile? 2 : 1)

        Maui.PlacesListBrowser
        {
            id: sidebar
            onPlaceClicked:
            {
                pageRow.currentIndex = 1
                browser.openFolder(path)
            }

            list.groups:  [Maui.FMList.PLACES_PATH,
                Maui.FMList.REMOTE_PATH,
                Maui.FMList.CLOUD_PATH,
                Maui.FMList.DRIVES_PATH]
        }

        ColumnLayout
        {
            id: _browserLayout
            spacing: 0

            Maui.Page
            {
                Layout.fillWidth: true
                Layout.fillHeight: true

                headBar.visible: true
                headBar.rightContent:[ Maui.ToolButtonMenu
                    {
                        icon.name: "view-sort"

                        MenuItem
                        {
                            text: i18n("Show Folders First")
                            checked: browser.currentFMList.foldersFirst
                            checkable: true
                            onTriggered: browser.currentFMList.foldersFirst = !browser.currentFMList.foldersFirst
                        }

                        MenuSeparator {}

                        MenuItem
                        {
                            text: i18n("Type")
                            checked: browser.currentFMList.sortBy === Maui.FMList.MIME
                            checkable: true
                            onTriggered: browser.currentFMList.sortBy = Maui.FMList.MIME
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Date")
                            checked: browser.currentFMList.sortBy === Maui.FMList.DATE
                            checkable: true
                            onTriggered: browser.currentFMList.sortBy = Maui.FMList.DATE
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Modified")
                            checkable: true
                            checked: browser.currentFMList.sortBy === Maui.FMList.MODIFIED
                            onTriggered: browser.currentFMList.sortBy = Maui.FMList.MODIFIED
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Size")
                            checkable: true
                            checked: browser.currentFMList.sortBy === Maui.FMList.SIZE
                            onTriggered: browser.currentFMList.sortBy = Maui.FMList.SIZE
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Name")
                            checkable: true
                            checked: browser.currentFMList.sortBy === Maui.FMList.LABEL
                            onTriggered: browser.currentFMList.sortBy = Maui.FMList.LABEL
                            autoExclusive: true
                        }

                        MenuSeparator{}

                        MenuItem
                        {
                            id: groupAction
                            text: i18n("Group")
                            checkable: true
                            checked: browser.settings.group
                            onTriggered:
                            {
                                browser.settings.group = !browser.settings.group
                            }
                        }
                    },

                    ToolButton
                    {
                        id: _optionsButton
                        icon.name: "overflow-menu"
                        enabled: browser.currentFMList.pathType !== Maui.FMList.TAGS_PATH && browser.currentFMList.pathType !== Maui.FMList.TRASH_PATH && browser.currentFMList.pathType !== Maui.FMList.APPS_PATH
                        onClicked:
                        {
                            if(browser.browserMenu.visible)
                                browser.browserMenu.close()
                            else
                                browser.browserMenu.show(_optionsButton, 0, height)
                        }
                        checked: browser.browserMenu.visible
                        checkable: false
                    }
                ]

                headBar.leftContent: [
                    Maui.ToolActions
                    {
                        expanded: true
                        autoExclusive: false
                        checkable: false

                        Action
                        {
                            icon.name: "go-previous"
                            onTriggered : browser.goBack()
                        }

                        Action
                        {
                            icon.name: "go-next"
                            onTriggered: browser.goNext()
                        }
                    }
                ]

                Maui.FileBrowser
                {
                    id: browser
                    anchors.fill: parent

                    selectionBar: _selectionBar
                    settings.viewType: Maui.FMList.LIST_VIEW
                    currentPath: Maui.FM.homePath()
                    selectionMode: control.mode === modes.OPEN
                    onItemClicked:
                    {
                        if(currentFMList.get(index).isdir == "true")
                        {
                            openItem(index)
                        }

                        switch(control.mode)
                        {
                        case modes.OPEN :
                        {
                            addToSelection(currentFMList.get(index))
                            break
                        }
                        case modes.SAVE:
                        {
                            textField.text = currentFMList.get(index).label
                            break
                        }
                        }
                    }

                    onCurrentPathChanged:
                    {
                        sidebar.currentIndex = -1

                        for(var i = 0; i < sidebar.count; i++)
                        {
                            if(String(browser.currentPath) === sidebar.list.get(i).path)
                            {
                                sidebar.currentIndex = i
                                return;
                            }
                        }
                    }
                }
            }

            Maui.SelectionBar
            {
                id: _selectionBar
                Layout.alignment: Qt.AlignCenter
                Layout.margins: Maui.Style.space.medium
                onExitClicked:
                {
                    _selectionBar.clear()
                }
            }
        }
    }


    /**
      *
      */
    function closeIt()
    {
        _selectionBar.clear()
        close()
    }

    /**
      *
      */
    function done()
    {
        var paths = browser.selectionBar && browser.selectionBar.visible ? browser.selectionBar.uris : [browser.currentPath]

        if(control.mode === modes.SAVE)
        {
            for(var i in paths)
            {
                paths[i] = paths[i] + "/" + textField.text
            }

            _tagsBar.list.urls = paths
            _tagsBar.list.updateToUrls(_tagsBar.getTags())
        }

        control.finished(paths)

        if(control.mode === modes.SAVE) //do it after finished in cas ethe files need to be saved aka exists, before tryign to insert tags
        {
            _tagsBar.list.urls = paths
            _tagsBar.list.updateToUrls(_tagsBar.getTags())
        }

        control.urlsSelected(paths)
        control.closeIt()
    }
}
