import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "private"

import FMModel 1.0
import FMList 1.0

Maui.Page
{
	id: control
	
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
	property alias trackChanges: modelList.trackChanges
	property alias saveDirProps: modelList.saveDirProps
	
	property string currentPath: Maui.FM.homePath()
	
	property var copyItems : []
	property var cutItems : []
	
	property var indexHistory : []
	
	property bool isCopy : false
	property bool isCut : false
	
	property bool selectionMode : false
	property bool group : false
	property bool showEmblems: true
	
	property alias selectionBar : selectionBarLoader.item
	
	property alias model : folderModel
	property alias list : modelList
	property alias browser : viewLoader.item
	
	property alias previewer : previewer
	property alias menu : browserMenu.content
	property alias itemMenu: itemMenu
	property alias holder: holder
	property alias dialog : dialogLoader.item
	property alias goUpButton : goUpButton
	
	property alias currentPathType : modelList.pathType
	property int thumbnailsSize : iconSizes.large
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	signal newBookmark()
	
	margins: 0
	
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
			
			title: qsTr("Delete files?")
			message: qsTr("If you are sure you want to delete the files click on Accept, otherwise click on Cancel")
            rejectButton.text: qsTr("Cancel")
            acceptButton.text: qsTr("Accept")
            onRejected: close()
			onAccepted:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.clear()
					control.selectionBar.animate("red")
				}
				
				control.remove(items)
				close()
			}
		}
	}
	
	Component
	{
		id: newFolderDialogComponent
		
		Maui.NewDialog
		{
            title: qsTr("New folder")
            message: qsTr("Create a new folder with a custom name")
            acceptButton.text: qsTr("Create")
			onFinished: list.createDir(text)
			rejectButton.visible: false
		}
	}
	
	Component
	{
		id: newFileDialogComponent
		
		Maui.NewDialog
		{
            title: qsTr("New file")
            message: qsTr("Create a new file with a custom name and extension")
            acceptButton.text: qsTr("Create")
			onFinished: Maui.FM.createFile(control.currentPath, text)
			rejectButton.visible: false			
		}
	}
	
	Component
	{
		id: renameDialogComponent
		Maui.NewDialog
		{
			title: qsTr("Rename file")
            message: qsTr("Rename a file or folder to a new custom name")
			textEntry.text: list.get(browser.currentIndex).label
			textEntry.placeholderText: qsTr("New name...")
			onFinished: Maui.FM.rename(itemMenu.items[0].path, textEntry.text)
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
			onTagsReady: composerList.updateToUrls(tags)
		}
	}	
	
	BrowserMenu
	{
		id: browserMenu
		width: unit *200		
	}
	
	Maui.FilePreviewer
	{
		id: previewer
		parent: parent
		onShareButtonClicked: control.shareFiles([url])
	}
	
	FMModel
	{
		id: folderModel
		list: modelList
	}
	
	FMList
	{
		id: modelList
		preview: true
		path: currentPath
		foldersFirst: true
		onSortByChanged: if(group) groupBy()
		onContentReadyChanged: console.log("CONTENT READY?", contentReady)
		onWarning:
		{			
			notify("dialog-information", "An error happened", message)
		}
		
		onProgress:
		{
			if(percent === 100)
				_progressBar.value = 0
				else
					_progressBar.value = percent/100
		}
	}	
	
	FileMenu
	{
		id: itemMenu
		width: unit *200
		onBookmarkClicked: control.bookmarkFolder([items[0].path])
		onCopyClicked:
		{
			if(items.length)
				control.copy(items)			
		}
		
		onCutClicked:
		{
			if(items.length)
				control.cut(items)			
		}
		
		onTagsClicked:
		{
			if(items.length)
			{
				dialogLoader.sourceComponent = tagsDialogComponent
				
				if(items.length > 1 && control.selectionBar)			
					dialog.composerList.urls = control.selectionBar.selectedPaths			
					else  
						dialog.composerList.urls = items[0].path
						
						dialog.open()
			}
		}
		
		onRenameClicked:
		{
			if(items.length === 1)
			{
				dialogLoader.sourceComponent = renameDialogComponent
				dialog.open()
			}
		}
		
		//        onSaveToClicked:
		//        {
		//            fmDialog.saveDialog = false
		//            fmDialog.multipleSelection = true
		//            fmDialog.onlyDirs= true
		
		//            var myPath = path
		
		//            var paths = browser.selectionBar.selectedPaths
		//            fmDialog.show(function(paths)
		//            {
		//                inx.copy(myPath, paths)
		//            })
		//        }
		
		onRemoveClicked:
		{
			dialogLoader.sourceComponent= removeDialogComponent
			dialog.items = items
			dialog.open()
		}
		
		onShareClicked:
		{			
			if(items.length)			
                control.shareFiles([items[0].path])
        }
	}
	
	Component
	{
		id: listViewBrowser
		
		Maui.ListBrowser
		{
			showPreviewThumbnails: modelList.preview
			showEmblem: selectionMode
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			showDetailsInfo: true
			// 			itemSize: thumbnailsSize
			model: folderModel
			section.delegate: Maui.LabelDelegate
			{
				id: delegate
				label: section
				labelTxt.font.pointSize: fontSizes.big
				
				isSection: true
				boldLabel: true
				height: toolBarHeightAlt
			}
		}
	}
	
	Component
	{
		id: gridViewBrowser
		
		Maui.GridBrowser
		{
			itemSize : thumbnailsSize + fontSizes.default
			showEmblem: selectionMode
			showPreviewThumbnails: modelList.preview
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "list-add"
			model: folderModel
		}
	}
	
	Connections
	{
		target: browser
		
		onItemClicked: 
		{		
			browser.currentIndex = index
			indexHistory.push(index)
			control.itemClicked(index)
		}
		
		onItemDoubleClicked: 
		{
			browser.currentIndex = index	
			indexHistory.push(index)
			control.itemDoubleClicked(index)
		}
		
		onItemRightClicked:
		{
			itemMenu.show([modelList.get(index)])
			control.itemRightClicked(index)
		}
		
		onLeftEmblemClicked:
		{
			control.addToSelection(modelList.get(index), true)
			control.itemLeftEmblemClicked(index)
		}
		
		onRightEmblemClicked:
		{
			isAndroid ? Maui.Android.shareDialog([modelList.get(index).path]) : shareDialog.show([modelList.get(index).path])
			control.itemRightEmblemClicked(index)
		}
		
		onAreaClicked:
		{
			if(!isMobile && mouse.button === Qt.RightButton)
				browserMenu.show()
				else return
					
					control.rightClicked()
		}
		
		onAreaRightClicked: browserMenu.show()
	}
	
	focus: true
	
	Maui.Holder
	{
		id: holder
		anchors.fill : parent
		z: -1
		visible: !modelList.pathExists || modelList.pathEmpty || !modelList.contentReady
		emoji: if(modelList.pathExists && modelList.pathEmpty)
		"qrc:/assets/MoonSki.png" 
		else if(!modelList.pathExists)
			"qrc:/assets/ElectricPlug.png"
			else if(!modelList.contentReady && currentPathType === FMList.SEARCH_PATH)
				"qrc:/assets/animat-search-color.gif"
			else if(!modelList.contentReady)
				"qrc:/assets/animat-rocket-color.gif"
				
				isGif: !modelList.contentReady			
				isMask: false
				title : if(modelList.pathExists && modelList.pathEmpty)
				qsTr("Folder is empty!")
				else if(!modelList.pathExists)
					qsTr("Folder doesn't exists!")
					else if(!modelList.contentReady && currentPathType === FMList.SEARCH_PATH)
						qsTr("Searching for content!")
						else if(!modelList.contentReady)
							qsTr("Loading content!")					
						
						
						body: if(modelList.pathExists && modelList.pathEmpty)
						qsTr("You can add new files to it")
						else if(!modelList.pathExists)
							qsTr("Create Folder?")
							else if(!modelList.contentReady && currentPathType === FMList.SEARCH_PATH)
								qsTr("This might take a while!")
								else if(!modelList.contentReady)
									qsTr("Almost ready!")	
							
								
								
								emojiSize: iconSizes.huge
								
								onActionTriggered:
								{
									if(!modelList.pathExists)
									{
										Maui.FM.createDir(control.currentPath.slice(0, control.currentPath.lastIndexOf("/")), control.currentPath.split("/").pop())
										control.openFolder(modelList.parentPath)				
									}
								}
	}
	
	Keys.onSpacePressed: previewer.show(modelList.get(browser.currentIndex).path)
	
	headBarExit: false
	headBar.visible: currentPathType !== FMList.APPS_PATH
	altToolBars: isMobile
	headBar.rightContent: [
	
	Maui.ToolButton
	{
		id: viewBtn
		iconName: list.viewType == FMList.ICON_VIEW ?  "view-list-details" : "view-list-icons"
		onClicked: control.switchView()
	},
	
	Maui.ToolButton
	{
		iconName: "view-sort"
		tooltipText: qsTr("Sort by...")
		onClicked: sortMenu.popup()
		
		Maui.Menu
		{
			id: sortMenu
			
			Maui.MenuItem
			{
				text: qsTr("Folders first")
				checkable: true
				checked: list.foldersFirst
				onTriggered: list.foldersFirst = !list.foldersFirst
			}
			
			MenuSeparator{}
			
			Maui.MenuItem
			{
				text: qsTr("Type")
				checkable: true
				checked: list.sortBy === FMList.MIME
				onTriggered: list.sortBy = FMList.MIME
			}
			
			Maui.MenuItem
			{
				text: qsTr("Date")
				checkable: true
				checked: list.sortBy === FMList.DATE
				onTriggered: list.sortBy = FMList.DATE
			}
			
			Maui.MenuItem
			{
				text: qsTr("Modified")
				checkable: true
				checked: list.sortBy === FMList.MODIFIED
				onTriggered: list.sortBy = FMList.MODIFIED
			}
			
			Maui.MenuItem
			{
				text: qsTr("Size")
				checkable: true
				checked: list.sortBy === FMList.SIZE
				onTriggered: list.sortBy = FMList.SIZE
			}
			
			Maui.MenuItem
			{
				text: qsTr("Name")
				checkable: true
				checked: list.sortBy === FMList.LABEL
				onTriggered: list.sortBy = FMList.LABEL
			}
			
			MenuSeparator {}
			
			Maui.MenuItem
			{
				id: groupAction
				text: qsTr("Group")
				checkable: true
				onTriggered:
				{
					group = checked
					group ? groupBy() : browser.section.property = ""
				}
			}
		}
	},
	
	Maui.ToolButton
	{
		iconName: "item-select"
		checkable: true
		checked: selectionMode		
		onClicked: selectionMode = !selectionMode
		
	},
	
	Maui.ToolButton
	{
		iconName: "overflow-menu"
		onClicked: browserMenu.show()
		tooltipText: qsTr("Menu...")
	}
	]
	
	headBar.leftContent: [
	Maui.ToolButton
	{
		iconName: "go-previous"
		onClicked: control.goBack()
	},
	
	Maui.ToolButton
	{
		id: goUpButton
		visible: isAndroid
		iconName: "go-up"
		onClicked: control.goUp()
	},
	
	Maui.ToolButton
	{
		iconName: "go-next"
		onClicked: control.goNext()
	}	
	]
	
	footBar.visible: false
	
	
	Component
	{
		id: selectionBarComponent
		
		Maui.SelectionBar
		{
			anchors.fill: parent
			onIconClicked: _selectionBarmenu.popup()
			onExitClicked: clearSelection()
			
			Maui.Menu
			{
				id: _selectionBarmenu
				Maui.MenuItem
				{
					text: qsTr("Copy...")
					onTriggered:
					{
						if(control.selectionBar)				
							control.selectionBar.animate("#6fff80")
						control.copy(selectedItems)		
						console.log(selectedItems)
						_selectionBarmenu.close()
					}
				}
				
				Maui.MenuItem
				{
					text: qsTr("Cut...")
					onTriggered:
					{
						if(control.selectionBar)
							control.selectionBar.animate("#fff44f")
						control.cut(selectedItems)
						
						_selectionBarmenu.close()
					}
				}
				
				Maui.MenuItem
				{
					text: qsTr("Share")
					onTriggered:
					{						
						control.shareFiles(selectedPaths)						
						_selectionBarmenu.close()
					}
				}
				
				MenuSeparator{}
				
				Maui.MenuItem
				{
					text: qsTr("Remove...")
					colorScheme.textColor: dangerColor
					
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
	
	ColumnLayout
	{
		anchors.fill: parent
		visible: !holder.visible
		z: holder.z + 1
		spacing: 0
		
		Loader
		{
			id: viewLoader
			z: holder.z + 1
			sourceComponent: list.viewType == FMList.ICON_VIEW  ?  gridViewBrowser :  listViewBrowser
			
			Layout.margins: list.viewType == FMList.LIST_VIEW ? unit : contentMargins * 2
			
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		
		Loader
		{
			id: selectionBarLoader
			Layout.fillWidth: true
			Layout.preferredHeight: control.selectionBar ? (control.selectionBar.visible ? control.selectionBar.barHeight : 0) : 0
			Layout.leftMargin:  contentMargins * (isMobile ? 3 : 2)
			Layout.rightMargin: contentMargins * (isMobile ? 3 : 2)
			Layout.bottomMargin: contentMargins*2
			z: holder.z +1
		}
		
		
		ProgressBar
		{
			id: _progressBar
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignBottom
			height: iconSizes.medium
			visible: value > 0
		}
		
	}
	
	// 	PinchArea
	// 	{
	//         anchors.fill: parent
	//         
	//         property real initialWidth
	//         property real initialHeight
	// 
	//         onPinchStarted:
	//         {
	//             console.log("pinch started")
	//         }
	// 
	//         onPinchUpdated:
	//         {
	//             console.log(pinch.scale)
	//         }
	// 
	//         onPinchFinished:
	//         {
	//             console.log("pinch finished")
	//         }
	//     }
	
	onThumbnailsSizeChanged:
	{
		if(trackChanges && saveDirProps)
			Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
			else 
				Maui.FM.saveSettings("IconSize", thumbnailsSize, "SETTINGS")
				
				if(list.viewType == FMList.ICON_VIEW)
					browser.adaptGrid()
	}
	
	
    function shareFiles(urls)
    {
        if(urls.length <= 0)
            return;
        
        if(isAndroid)              
            Maui.Android.shareDialog(urls[0])        
        else
        {
            dialogLoader.sourceComponent= shareDialogComponent            
            dialog.show(urls)                    
        }
    }
    
	function openItem(index)
	{
		var item = modelList.get(index)
		var path = item.path
		
		switch(currentPathType)
		{
			case FMList.APPS_PATH:
				if(item.path.endsWith("/"))
					populate(path)
					else
						Maui.FM.runApplication(path)
						break
			case FMList.CLOUD_PATH:
				if(item.mime === "inode/directory")
					control.openFolder(path)
					else
						Maui.FM.openCloudItem(item)
						break;
			default:
				if(selectionMode && !Maui.FM.isDir(item.path))
					addToSelection(item, true)
					else
					{
						if(Maui.FM.isDir(path))
							control.openFolder(path)
							else if(Maui.FM.isApp(path))
								control.launchApp(path)
								else
								{
									if (isMobile)
										previewer.show(path)
										else
											control.openFile(path)
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
		populate(path)
	}
	
	function setPath(path)
	{
		currentPath = path
	}
	
	function populate(path)
	{
		if(!path.length)
			return;
		
		browser.currentIndex = 0
		setPath(path)
		
		if(currentPathType === FMList.PLACES_PATH)
		{
			if(trackChanges && saveDirProps)
			{
				var conf = Maui.FM.dirConf(path+"/.directory")
				var iconsize = conf["iconsize"] ||  iconSizes.large
				thumbnailsSize = parseInt(iconsize)				
			}else
			{
				thumbnailsSize = parseInt(Maui.FM.loadSettings("IconSize", "SETTINGS", thumbnailsSize))		
			}
		}
		
		if(list.viewType == FMList.ICON_VIEW)
			browser.adaptGrid()
	}
	
	function goBack()
	{
		populate(modelList.previousPath)
		browser.currentIndex = indexHistory.pop()
//		browser.positionViewAtIndex(browser.currentIndex, ListView.Center)
	}
	
	function goNext()
	{
		openFolder(modelList.posteriorPath)
	}
	
	function goUp()
	{
		openFolder(modelList.parentPath)
	}
	
	function refresh()
	{
		var pos = browser.contentY
		modelList.refresh()
		
		browser.contentY = pos
	}
	
	function addToSelection(item, append)
	{
		selectionBarLoader.sourceComponent= selectionBarComponent
		selectionBar.append(item)
	}
	
	function clearSelection()
	{
		clean()
		// 		selectionMode = false
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
			list.copyInto(copyItems, currentPath)
		else if(isCut)
		{
			list.cutInto(cutItems, currentPath)
			clearSelection()			
		}
	}
	
	function remove(items)
	{
		for(var i in items)
			Maui.FM.removeFile(items[i].path)
	}	
	
	function switchView()
	{	
		list.viewType = list.viewType ===  FMList.ICON_VIEW ? FMList.LIST_VIEW : FMList.ICON_VIEW
	}
	
	function bookmarkFolder(paths)
	{
		if(paths.length > 0)
		{
			for(var i in paths)
			{
				if(Maui.FM.isDefaultPath(paths[i]))
					continue
					Maui.FM.bookmark(paths[i])
			}
			newBookmark()
		}		
	}
	
	function zoomIn()
	{		
		control.thumbnailsSize = control.thumbnailsSize + 8		
	}
	
	function zoomOut()
	{
		var newSize = control.thumbnailsSize - 8
		
		if(newSize >= iconSizes.small)
			control.thumbnailsSize = newSize
	}	
	
	function groupBy()
	{
		var prop = ""
		var criteria = ViewSection.FullString
		
		switch(modelList.sortBy)
		{
			case FMList.LABEL:
				prop = "label"
				criteria = ViewSection.FirstCharacter
				break;
			case FMList.MIME:
				prop = "mime"
				break;
			case FMList.SIZE:
				prop = "size"
				break;
			case FMList.DATE:
				prop = "date"
				break;
			case FMList.MODIFIED:
				prop = "modified"
				break;
		}
		
		list.viewType = FMList.LIST_VIEW 
		
		if(!prop)
		{
			browser.section.property = ""
			return
		}
		
		browser.section.property = prop
		browser.section.criteria = criteria
	}
}
