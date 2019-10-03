import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private"

Maui.Page
{
    id: control

    property url currentPath
    onCurrentPathChanged: control.browserView.path = control.currentPath

    property int viewType : Maui.FMList.LIST_VIEW
    onViewTypeChanged: browserView.viewType = control.viewType    
    
    property int currentPathType : control.currentFMList.pathType
    property int thumbnailsSize : Maui.Style.iconSizes.large * 1.7
    property bool showThumbnails: true

    property var copyItems : []
    property var cutItems : []

    property var indexHistory : []

    property bool isCopy : false
    property bool isCut : false

    property bool selectionMode : false
    property bool singleSelection: false

    property bool group : false
    property bool showEmblems: true

    //group properties from the browser since the browser views are loaded async and
    //their properties can not be accesed inmediately
    property BrowserSettings settings : BrowserSettings {}

    property alias selectionBar : selectionBarLoader.item

    property alias browserView : _browserList.currentItem
    property Maui.FMList currentFMList : browserView.currentFMList

    property alias previewer : previewer
    property alias menu : browserMenu.contentData
    property alias itemMenu: itemMenu
    property alias dialog : dialogLoader.item

    signal itemClicked(int index)
    signal itemDoubleClicked(int index)
    signal itemRightClicked(int index)
    signal itemLeftEmblemClicked(int index)
    signal itemRightEmblemClicked(int index)
    signal rightClicked()
    signal newBookmark(var paths)


    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    onGoBackTriggered: control.goBack()
    onGoForwardTriggered: control.goNext()

    focus: true

    footBar.visible: false
    footBar.leftContent: Label
    {
    Layout.fillWidth: true
    text: qsTr("%n item(s)", "0", control.currentFMList.count)
    }

    footBar.rightContent: [

            ToolButton
            {
                icon.name: "zoom-in"
                onClicked: zoomIn()
            },

            ToolButton
            {
                icon.name: "zoom-out"
                onClicked: zoomOut()
            }
    ]

    headBar.visible: currentPathType !== Maui.FMList.APPS_PATH
    headBar.position: Kirigami.Settings.isMobile ? ToolBar.Footer : ToolBar.Header
    property list<QtObject> t_actions:
    [
    Action
    {
        id: _previewAction
        icon.name: "image-preview"
        text: qsTr("Show Previews")
        checkable: true
        checked: control.showThumbnails
        onTriggered: control.showThumbnails = !control.showThumbnails
    },

    Action
    {
        id: _hiddenAction
        icon.name: "visibility"
        text: qsTr("Show Hidden Files")
        checkable: true
        checked: control.currentFMList.hidden
        onTriggered: control.currentFMList.hidden = !control.currentFMList.hidden
    },

    Action
    {
        id: _bookmarkAction
        icon.name: "bookmark-new"
        text: qsTr("Bookmark Current Path")
        onTriggered: newBookmark([currentPath])
    },

    Action
    {
        id: _newFolderAction
        icon.name: "folder-add"
        text: qsTr("New Folder...")
        onTriggered:
        {
            dialogLoader.sourceComponent= newFolderDialogComponent
            dialog.open()
        }
    },

    Action
    {
        id: _newDocumentAction
        icon.name: "document-new"
        text: qsTr("New file...")
        onTriggered:
        {
            dialogLoader.sourceComponent= newFileDialogComponent
            dialog.open()
        }
    },

    Action
    {
        id: _pasteAction
        text: qsTr("Paste %n File(s)", "0", browserMenu.pasteFiles)
        icon.name: "edit-paste"
        enabled: browserMenu.pasteFiles > 0
        onTriggered: paste()
    },

    Action
    {
        id: _selectAllAction
        text: qsTr("Select All")
        icon.name: "edit-select-all"
        onTriggered: selectAll()
    },

    Action
    {
        text: qsTr("Show Status Bar")
        icon.name: "settings-configure"
        checkable: true
        checked: control.footBar.visible
        onTriggered: control.footBar.visible = !control.footBar.visible
    }
    ]

    Loader
    {
        id: dialogLoader
    }

    Component
    {
        id: removeDialogComponent

        Maui.Dialog
        {
            property var items: []

            title: qsTr("Removing %n file(s)", "0", items.length)
            message: isAndroid ?  qsTr("This action will remove your files from your system permanently. This action can not be undone.") : qsTr("You can move the file to the trash or delete it completely from your system. Which one do you prefer?")
			rejectButton.text: qsTr("Delete Files")
            acceptButton.text: qsTr("Send to Trash")
            acceptButton.visible: !Kirigami.Settings.isMobile
            page.padding: Maui.Style.space.huge

            onRejected:
            {
                if(control.selectionBar && control.selectionBar.visible)
                {
                    control.selectionBar.clear()
                    control.selectionBar.animate(Maui.Style.dangerColor)
                }

                control.remove(items)
                close()
            }

            onAccepted:
            {
                if(control.selectionBar && control.selectionBar.visible)
                {
                    control.selectionBar.clear()
                    control.selectionBar.animate(Maui.Style.dangerColor)
                }

                control.trash(items)
                close()
            }
        }
    }

    Component
    {
        id: newFolderDialogComponent

        Maui.NewDialog
        {
            title: qsTr("New Folder...")
            message: qsTr("Create a new folder")
            acceptButton.text: qsTr("Create")
            onFinished: control.currentFMList.createDir(text)
            rejectButton.visible: false
            textEntry.placeholderText: qsTr("Folder name...")
        }
    }

    Component
    {
        id: newFileDialogComponent

        Maui.NewDialog
        {
            title: qsTr("New File...")
            message: qsTr("Create a new file")
            acceptButton.text: qsTr("Create")
            onFinished: Maui.FM.createFile(control.currentPath, text)
            rejectButton.visible: false
            textEntry.placeholderText: qsTr("File name...")
        }
    }

    Component
    {
        id: renameDialogComponent
        Maui.NewDialog
        {
            title: qsTr("Rename File...")
            message: qsTr("Rename a file or folder")
            textEntry.text: itemMenu.item.label
            textEntry.placeholderText: qsTr("New name...")
            onFinished: Maui.FM.rename(itemMenu.item.path, textEntry.text)
            onRejected: close()
            acceptText: qsTr("Rename")
            rejectText: qsTr("Cancel")
        }
    }

    Component
    {
        id: shareDialogComponent
        Maui.ShareDialog {}
    }

    Component
    {
        id: tagsDialogComponent
        Maui.TagsDialog
        {
            onTagsReady:
            {
                composerList.updateToUrls(tags)
                if(previewer.visible)
                    previewer.tagBar.list.refresh()
            }
        }
    }

    BrowserMenu
    {
        id: browserMenu
        z : control.z +1
    }

    Maui.FilePreviewer
    {
        id: previewer
        onShareButtonClicked: control.shareFiles([url])
    }

    FileMenu
    {
        id: itemMenu
        width: Maui.Style.unit *200
        onBookmarkClicked: control.newBookmark([item.path])
        onCopyClicked:
        {
            if(item)
                control.copy([item])
        }

        onCutClicked:
        {
            if(item)
                control.cut([item])
        }

        onTagsClicked:
        {
            if(item)
            {
                dialogLoader.sourceComponent = tagsDialogComponent
                dialog.composerList.urls = [item.path]
                dialog.open()
            }
        }

        onRenameClicked:
        {
            dialogLoader.sourceComponent = renameDialogComponent
            dialog.open()
        }

        onRemoveClicked:
        {
            dialogLoader.sourceComponent= removeDialogComponent
            dialog.items = [item]
            dialog.open()
        }

        onShareClicked: control.shareFiles([item.path])
    }

    Connections
    {
        target: browserView.currentView

        onItemClicked:
        {
            console.log("item clicked connections:", index)
            browserView.currentView.currentIndex = index
            indexHistory.push(index)
            control.itemClicked(index)
        }

        onItemDoubleClicked:
        {
            browserView.currentView.currentIndex = index
            indexHistory.push(index)
            control.itemDoubleClicked(index)
        }

        onItemRightClicked:
        {
            if(currentFMList.pathType !== Maui.FMList.TRASH_PATH &&
                currentFMList.pathType !== Maui.FMList.REMOTE_PATH
            )
                itemMenu.show(index)
                control.itemRightClicked(index)
        }

        onLeftEmblemClicked:
        {
			const item = control.currentFMList.get(index)
			
			if(control.selectionBar && control.selectionBar.contains(item.path))
			{
				control.selectionBar.removeAtPath(item.path)
			}else
			{
				control.addToSelection(item)				
			}
            control.itemLeftEmblemClicked(index)
        }

        onRightEmblemClicked:
        {
            isAndroid ? Maui.Android.shareDialog([control.currentFMList.get(index).path]) : shareDialog.show([control.currentFMList.get(index).path])
            control.itemRightEmblemClicked(index)
        }

        onAreaClicked:
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                browserMenu.show()
                else return

                    control.rightClicked()
        }

        onAreaRightClicked: browserMenu.show()
    }

    headBar.rightContent:[
    Kirigami.ActionToolBar
    {
        position: ToolBar.Header
        Layout.fillWidth: true
        hiddenActions: t_actions

        display:  ToolButton.IconOnly

        actions: [
        Action
        {
            icon.name: "view-list-icons"
            onTriggered: control.viewType = Maui.FMList.ICON_VIEW
            checkable: false
            checked: browserView.viewType === Maui.FMList.ICON_VIEW
            icon.width: Maui.Style.iconSizes.medium
            text: qsTr("Grid View")
            // 			autoExclusive: true
        },

        Action
        {
            icon.name: "view-list-details"
            onTriggered: control.viewType = Maui.FMList.LIST_VIEW
            icon.width: Maui.Style.iconSizes.medium
            checked: browserView.viewType === Maui.FMList.LIST_VIEW
            text: qsTr("List View")
            // 			autoExclusive: true
        },

        Action
        {
            icon.name: "view-file-columns"
            onTriggered: control.viewType = Maui.FMList.MILLERS_VIEW
            icon.width: Maui.Style.iconSizes.medium
            checked: browserView.viewType === Maui.FMList.MILLERS_VIEW
            text: qsTr("Column View")
            // 			autoExclusive: true
        },

        Kirigami.Action
        {
            icon.name: "view-sort"
            text: qsTr("Sort By")

            Kirigami.Action
            {
                text: qsTr("Show Folders First")
                checked: control.currentFMList.foldersFirst
                checkable: true
                onTriggered: control.currentFMList.foldersFirst = !control.currentFMList.foldersFirst
            }

            Kirigami.Action
            {
                text: qsTr("Type")
                checked: control.currentFMList.sortBy === Maui.FMList.MIME
                checkable: true
                onTriggered: control.currentFMList.sortBy = Maui.FMList.MIME
            }

            Kirigami.Action
            {
                text: qsTr("Date")
                checked: control.currentFMList.sortBy === Maui.FMList.DATE
                checkable: true
                onTriggered: control.currentFMList.sortBy = Maui.FMList.DATE
            }

            Kirigami.Action
            {
                text: qsTr("Last Modified")
                checkable: true
                checked: control.currentFMList.sortBy === Maui.FMList.MODIFIED
                onTriggered: control.currentFMList.sortBy = Maui.FMList.MODIFIED
            }

            Kirigami.Action
            {
                text: qsTr("Size")
                checkable: true
                checked: control.currentFMList.sortBy === Maui.FMList.SIZE
                onTriggered: control.currentFMList.sortBy = Maui.FMList.SIZE
            }

            Kirigami.Action
            {
                text: qsTr("Name")
                checkable: true
                checked: control.currentFMList.sortBy === Maui.FMList.LABEL
                onTriggered: control.currentFMList.sortBy = Maui.FMList.LABEL
            }

            Kirigami.Action
            {
                id: groupAction
                text: qsTr("Group")
                checkable: true
                checked: control.group
                onTriggered:
                {
                    control.group = !control.group
                    if(control.group)
                        groupBy()
                    else
                        browserView.currentView.section.property = ""
                }
            }
        },

        Kirigami.Action
        {
            text: qsTr("Selection Mode")
            icon.name: "item-select"
            checkable: true
            checked: control.selectionMode
            onTriggered: control.selectionMode = !control.selectionMode

        }
        ]
    }
    ]

    headBar.leftContent: [
    ToolButton
    {
        icon.name: "go-previous"
        onClicked: control.goBack()
    },

//     ToolButton
//     {
//         id: goUpButton
//         visible: true
//         icon.name: "go-up"
//         onClicked: control.goUp()
//     },

    ToolButton
    {
        icon.name: "go-next"
        onClicked: control.goNext()
    }
    ]

    Component
    {
        id: selectionBarComponent

        Maui.SelectionBar
        {
            anchors.fill: parent
            onIconClicked: _selectionBarmenu.popup()
            onExitClicked: clean()
            onItemClicked: removeSelection(index)

            Menu
            {
                id: _selectionBarmenu

                MenuItem
                {
                    text: qsTr("Copy")
                    onTriggered: if(control.selectionBar)
                    {
                        control.selectionBar.animate("#6fff80")
                        control.copy(selectedItems)
                        console.log(selectedItems)
                        _selectionBarmenu.close()
                    }
                }

                MenuItem
                {
                    text: qsTr("Cut")
                    onTriggered: if(control.selectionBar)
                    {
                        control.selectionBar.animate("#fff44f")
                        control.cut(selectedItems)
                        _selectionBarmenu.close()
                    }

                }

                MenuItem
                {
                    text: qsTr("Share...")
                    onTriggered:
                    {
                        control.shareFiles(selectedPaths)
                        _selectionBarmenu.close()
                    }
                }

                MenuItem
                {
                    text: qsTr("Tags...")
                    onTriggered: if(control.selectionBar)
                    {
                        dialogLoader.sourceComponent = tagsDialogComponent
                        dialog.composerList.urls = selectedPaths
                        dialog.open()
                        _selectionBarmenu.close()
                    }
                }

                MenuSeparator{}

                MenuItem
                {
                    text: qsTr("Remove")
                    Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor

                    onTriggered:
                    {
                        dialogLoader.sourceComponent= removeDialogComponent
                        dialog.items = selectedItems
                        dialog.open()
                        _selectionBarmenu.close()
                    }
                }
            }
        }
    }

    ObjectModel { id: tabsObjectModel }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        TabBar
        {
            id: tabsBar
            visible: _browserList.count > 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? Maui.Style.rowHeight : 0
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false

            currentIndex : _browserList.currentIndex
            clip: true

            ListModel { id: tabsListModel }

            background: null

            Repeater
            {
                id: _repeater
                model: tabsListModel

                TabButton
                {
                    id: _tabButton
                    readonly property int minTabWidth: 150 * Maui.Style.unit
                    implicitWidth: control.width / _repeater.count
                    implicitHeight: Maui.Style.rowHeight
                    checked: index === _browserList.currentIndex

                    onClicked:
                    {
                        _browserList.currentIndex = index

                        control.currentPath =  tabsObjectModel.get(index).path
                    }

                    background: Rectangle
                    {
                        color: "transparent"


                        Kirigami.Separator
                        {
                            z: tabsBar.z + 1
                            width: Maui.Style.unit
                            anchors
                            {
                                bottom: parent.bottom
                                top: parent.top
                                right: parent.right
                            }
                        }

                        Kirigami.Separator
                        {
                            color: Kirigami.Theme.highlightColor
                            z: tabsBar.z + 1
                            height: Maui.Style.unit * 2
                            visible: checked
                            anchors
                            {
                                bottom: parent.bottom
                                left: parent.left
                                right: parent.right
                            }
                        }
                    }

                    contentItem: RowLayout
                    {
                        spacing: 0

                        Label
                        {
                            text: tabsObjectModel.get(index).currentFMList.pathName
                            font.pointSize: Maui.Style.fontSizes.default
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: Maui.Style.space.small
                            Layout.alignment: Qt.AlignCenter
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            color: checked ?  Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }

                        ToolButton
                        {
                            Layout.preferredHeight: Maui.Style.iconSizes.medium
                            Layout.preferredWidth: Maui.Style.iconSizes.medium
                            icon.height: Maui.Style.iconSizes.medium
                            icon.width: Maui.Style.iconSizes.width
                            Layout.margins: Maui.Style.space.medium
                            Layout.alignment: Qt.AlignRight

                            icon.name: "dialog-close"

                            onClicked:
                            {
                                var removedIndex = index
                                tabsObjectModel.remove(removedIndex)
                                tabsListModel.remove(removedIndex)
                            }
                        }
                    }
                }
            }
        }


        Kirigami.Separator
        {
            visible: tabsBar.visible
            color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        ListView
        {
            id: _browserList
            Layout.margins: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            focus: true
// 			Keys.onSpacePressed: previewer.show(control.currentFMList.get(browser.currentIndex).path)

            orientation: ListView.Horizontal
            model: tabsObjectModel
            snapMode: ListView.SnapOneItem
            spacing: 0
            interactive: Kirigami.Settings.isMobile && tabsObjectModel.count > 1
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            onMovementEnded: _browserList.currentIndex = indexAt(contentX, contentY)
        }

        Loader
        {
            id: selectionBarLoader
            Layout.fillWidth: true
            Layout.preferredHeight: control.selectionBar && control.selectionBar.visible ? control.selectionBar.barHeight: 0
            Layout.leftMargin: Maui.Style.contentMargins * (Kirigami.Settings.isMobile ? 3 : 2)
            Layout.rightMargin: Maui.Style.contentMargins * (Kirigami.Settings.isMobile ? 3 : 2)
            Layout.bottomMargin: control.selectionBar && control.selectionBar.visible ? Maui.Style.contentMargins*2 : 0
        }

        ProgressBar
        {
            id: _progressBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            Layout.preferredHeight: visible ? Maui.Style.iconSizes.medium : 0
            visible: value > 0
        }
    }

    Component.onCompleted:
    {
        openTab(Maui.FM.homePath())
// 		browserView.viewType = control.viewType
        control.setSettings()
    }

    onThumbnailsSizeChanged:
    {
        if(settings.trackChanges && settings.saveDirProps)
            Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
            else
                Maui.FM.saveSettings("IconSize", thumbnailsSize, "SETTINGS")

				if(control.viewType === Maui.FMList.ICON_VIEW)
					browserView.currentView.adaptGrid()
	}
	
	function setSettings()
	{
		if(control.currentFMList !== null)
		{
			control.currentFMList.onlyDirs= control.settings.onlyDirs
			control.currentFMList.filters= control.settings.filters
			control.currentFMList.sortBy= control.settings.sortBy
			control.currentFMList.filterType= control.settings.filterType
			control.currentFMList.trackChanges= control.settings.trackChanges
			control.currentFMList.saveDirProps= control.settings.saveDirProps
		}
	}
	
	function openTab(path)
	{
		const component = Qt.createComponent("private/BrowserView.qml");
		if (component.status === Component.Ready)
		{
			const object = component.createObject(tabsObjectModel);
			tabsObjectModel.append(object);
		}
		
		tabsListModel.append({
			title: qsTr("Untitled"),
							 path: path,
		})
		
		_browserList.currentIndex = tabsObjectModel.count - 1
		
		if(path)
		{
			setTabMetadata(path)
			browserView.viewType = control.viewType			
			openFolder(path)
		}
	}
	
	function setTabMetadata(filepath)
	{
		tabsListModel.setProperty(tabsBar.currentIndex, "path", filepath)
	}
	
	
	function shareFiles(urls)
	{
		if(urls.length <= 0)
			return;
		
		if(isAndroid)
		{
			Maui.Android.shareDialog(urls[0])
		}
		else
		{
			dialogLoader.sourceComponent= shareDialogComponent
			dialog.show(urls)
		}
	}
	
	function openItem(index)
	{
		const item = control.currentFMList.get(index)
		const path = item.path
		
		switch(currentPathType)
		{
			case Maui.FMList.APPS_PATH:
				if(item.path.endsWith("/"))
				{
					populate(path)
				}
				else
				{
					Maui.FM.runApplication(path)
				}
				break
			case Maui.FMList.CLOUD_PATH:
				if(item.mime === "inode/directory")
				{
					control.openFolder(path)
				}
				else
				{
					Maui.FM.openCloudItem(item)		 
				}
				break;
			default:
				if(selectionMode && !Maui.FM.isDir(item.path))
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
					if(item.mime === "inode/directory")
					{	 
						control.openFolder(path)
					}
					else if(Maui.FM.isApp(path))
					{
						control.launchApp(path)	
					}						
					else
					{
						if (Kirigami.Settings.isMobile)
						{
							previewer.show(path)
						}
						else
						{
							control.openFile(path)							
						}
					}
				}
		}
	}
	
	
	function launchApp(path)
	{
		Maui.FM.runApplication(path, "")
	}
	
	function openFile(path)
	{
		Maui.FM.openUrl(path)
	}
	
	function openFolder(path)
	{
		populate(Maui.FM.fileDir(path))// make sure the path is a dir // file to dir
	}
	
	function setPath(path)
	{
		control.currentPath = path
	}
	
	function populate(path)
	{
		if(!path.length)
			return;
		
		browserView.currentView.currentIndex = -1
		setPath(path)
		
		//         if(currentPathType === Maui.FMList.PLACES_PATH)
		//         {
		//             if(trackChanges && saveDirProps)
		//             {
		//                 var conf = Maui.FM.dirConf(path+"/.directory")
		// 				var iconsize = conf["iconsize"] ||  Maui.Style.iconSizes.large
		//                 thumbnailsSize = parseInt(iconsize)
		//             }else
		//             {
		//                 thumbnailsSize = parseInt(Maui.FM.loadSettings("IconSize", "SETTINGS", thumbnailsSize))
		//             }
		//         }
		//
		//         if(browserView.viewType == Maui.FMList.ICON_VIEW)
		//             browser.adaptGrid()
	}
	
	function goBack()
	{
		populate(control.currentFMList.previousPath)
		browserView.currentView.currentIndex = indexHistory.pop()
	}
	
	function goNext()
	{
		openFolder(control.currentFMList.posteriorPath)
	}
	
	function goUp()
	{
		openFolder(control.currentFMList.parentPath)
	}
	
	function refresh()
	{
		const pos = browserView.currentView.contentY
		browserView.currentView.contentY = pos
	}
	
	function addToSelection(item)
	{
		if(!selectionBar)
			selectionBarLoader.sourceComponent = selectionBarComponent
			
			selectionBar.singleSelection = control.singleSelection
			selectionBar.append(item)
	}
	
	function clean()
	{
		copyItems = []
		cutItems = []
		browserMenu.pasteFiles = 0
		
		if(control.selectionBar && control.selectionBar.visible)
			selectionBar.clear()
	}
	
	function copy(items)
	{
		copyItems = items
		isCut = false
		isCopy = true
	}
	
	function cut(items)
	{
		cutItems = items
		isCut = true
		isCopy = false
	}
	
	function paste()
	{
		if(isCopy)
			currentFMList.copyInto(copyItems)
			else if(isCut)
			{
				currentFMList.cutInto(cutItems)
				clean()
			}
	}
	
	function remove(items)
	{
		for(var i in items)
			Maui.FM.removeFile(items[i].path)
	}
	
	function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
	{
		for(var i = 0; i < Math.min(control.currentFMList.count, 100); i++)
			addToSelection(control.currentFMList.get(i))
	}
	
	function trash(items)
	{
		for(var i in items)
			Maui.FM.moveToTrash(items[i].path)
	}
	
	function bookmarkFolder(paths)
	{
		newBookmark(paths)
	}
	
	function zoomIn()
	{
		control.thumbnailsSize = control.thumbnailsSize + 8
	}
	
	function zoomOut()
	{
		const newSize = control.thumbnailsSize - 8
		
		if(newSize >= Maui.Style.iconSizes.small)
			control.thumbnailsSize = newSize
	}
	
	function groupBy()
	{
		var prop = ""
		var criteria = ViewSection.FullString
		
		switch(control.currentFMList.sortBy)
		{
			case Maui.FMList.LABEL:
				prop = "label"
				criteria = ViewSection.FirstCharacter
				break;
			case Maui.FMList.MIME:
				prop = "mime"
				break;
			case Maui.FMList.SIZE:
				prop = "size"
				break;
			case Maui.FMList.DATE:
				prop = "date"
				break;
			case Maui.FMList.MODIFIED:
				prop = "modified"
				break;
		}
		
		browserView.viewType = Maui.FMList.LIST_VIEW
		
		if(!prop)
		{
			browserView.currentView.section.property = ""
			return
		}
		
		browserView.currentView.section.property = prop
		browserView.currentView.section.criteria = criteria
	}
}
