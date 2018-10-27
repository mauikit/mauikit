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
	
	property string currentPath: Maui.FM.homePath()
	
	property var copyPaths : []
	property var cutPaths : []
	
	property bool isCopy : false
	property bool isCut : false
	
	property bool selectionMode : false
	property bool group : false
	property bool detailsView : false
	property bool showEmblems: true
	
	property alias selectionBar : selectionBar
	
	property alias model : folderModel
	property alias list : modelList	
	property alias browser : viewLoader.item
	
	property alias previewer : previewer
	property alias menu : browserMenu.content
	property alias itemMenu: itemMenu
	property alias holder: holder	
		
	property alias currentPathType : modelList.pathType
	property int thumbnailsSize : iconSizes.large
	
	signal itemClicked(int index)
	signal itemDoubleClicked(int index)
	signal itemRightClicked(int index)
	signal itemLeftEmblemClicked(int index)
	signal itemRightEmblemClicked(int index)
	signal rightClicked()
	
	margins: 0
	
	Maui.Dialog
	{
		id: removeDialog
		property var paths: []
		
		title: qsTr("Delete files?")
		message: qsTr("If you are sure you want to delete the files click on Accept, otherwise click on Cancel")
		onRejected: close()
		onAccepted: 
		{
			if(paths.length > 0)
			{
				control.selectionBar.clear()
				control.selectionBar.animate("red")
			}
			
			control.remove(paths)
			close()
		}
	}	
	
	Maui.NewDialog
	{
		id: newFolderDialog
		title: "Create new folder"
		onFinished: Maui.FM.createDir(control.currentPath, text)		
	}
	
	Maui.NewDialog
	{
		id: newFileDialog
		title: "Create new file"
		onFinished: Maui.FM.createFile(control.currentPath, text)
	}
	
	Maui.NewDialog
	{
		id: renameDialog
		title: qsTr("Rename file")
		textEntry.text: list.get(browser.currentIndex).label
		textEntry.placeholderText: qsTr("New name...")
		onFinished: Maui.FM.rename(itemMenu.paths[0], textEntry.text)
		
		acceptText: qsTr("Rename")
		rejectText: qsTr("Cancel")
	}
	
	Maui.ShareDialog
	{
		id: shareDialog
	}	
	
	BrowserMenu
	{
		id: browserMenu
	}
	
	Maui.FilePreviewer
	{
		id: previewer
		parent: parent
	}
	
	FMModel
	{
		id: folderModel
		list: modelList
	}
	
	FMList
	{
		id: modelList
		path: currentPath
		onSortByChanged: if(group) groupBy()
	}
	
	FileMenu
	{
		id: itemMenu
		onBookmarkClicked: control.bookmarkFolder(paths)
		onCopyClicked:
		{
			if(paths.length > 0)
				control.selectionBar.animate("#6fff80")
				
				control.copy(paths)
				
		}
		onCutClicked:
		{
			if(paths.length > 0)
				control.selectionBar.animate("#fff44f")
				
				control.cut(paths)
		}
		
		onRenameClicked:
		{
			if(paths.length === 1)
				renameDialog.open()
				
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
			removeDialog.paths = paths
			removeDialog.open()
		}
		
		onShareClicked: isAndroid ? Maui.Android.shareDialog(paths) :
		shareDialog.show(paths)
	}
	
	Component
	{
		id: listViewBrowser
		
		Maui.ListBrowser
		{

			showPreviewThumbnails: modelList.preview
			showEmblem: currentPathType !== FMList.APPS_PATH && showEmblems
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "emblem-added"
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
			showEmblem: currentPathType !== FMList.APPS_PATH && showEmblems
			showPreviewThumbnails: modelList.preview
			rightEmblem: isMobile ? "document-share" : ""
			leftEmblem: "emblem-added"
			model: folderModel
		}
	}
	
	Connections
	{
		target: browser
		
		onItemClicked: control.itemClicked(index)
		
		onItemDoubleClicked: control.itemDoubleClicked(index)
		
		onItemRightClicked: 
		{
			itemMenu.show([modelList.get(index).path])
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
		visible: !modelList.pathExists || modelList.pathEmpty
		z: -1
		emoji: modelList.pathExists ? "qrc:/assets/MoonSki.png" : "qrc:/assets/ElectricPlug.png"
		isMask: false
		title : modelList.pathExists && modelList.pathEmpty ?  "Folder is empty!" : "Folder doesn't exists!"
		body: modelList.pathExists && modelList.pathEmpty? "You can add new files to it" : "Create Folder?"
		emojiSize: iconSizes.huge
		
		onActionTriggered: 
		{
			Maui.FM.createDir(control.currentPath.slice(0, control.currentPath.lastIndexOf("/")), control.currentPath.split("/").pop())
			
			control.openFolder(modelList.parentPath)
		}
	}
	
	Keys.onSpacePressed: previewer.show(modelList.get(browser.currentIndex).path)
	
	floatingBar: true
	footBarOverlap: true
	headBarExit: false
	headBarVisible: currentPathType !== FMList.APPS_PATH
	altToolBars: isMobile
	
	headBar.rightContent: [
	
	Maui.ToolButton
	{
		iconName: "visibility"
		onClicked: modelList.hidden = !modelList.hidden
		tooltipText: qsTr("Hidden files...")
		iconColor: modelList.hidden ? colorScheme.highlightColor : colorScheme.textColor
	},
	
	Maui.ToolButton
	{
		iconName: "view-preview"
		onClicked: modelList.preview = !modelList.preview
		tooltipText: qsTr("Previews...")
		iconColor: modelList.preview ? colorScheme.highlightColor : colorScheme.textColor
	},
	
	Maui.ToolButton
	{
		iconName: "bookmark-new"
		iconColor: modelList.isBookmark ? colorScheme.highlightColor : colorScheme.textColor		
		onClicked: modelList.isBookmark = !modelList.isBookmark
		tooltipText: qsTr("Bookmark...")
	},
	
	Maui.ToolButton
	{
		iconName: "edit-select"
		tooltipText: qsTr("Selection...")
		onClicked: selectionMode = !selectionMode
		iconColor: selectionMode ? colorScheme.highlightColor: colorScheme.textColor
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
		id: viewBtn
		//            iconColor: floatingBar ? altColorText : textColor
		iconName:  control.detailsView ? "view-list-icons" : "view-list-details"
		onClicked: control.switchView()
	},
	
	Maui.ToolButton
	{
		iconName: "folder-add"
		onClicked: newFolderDialog.open()
		tooltipText: qsTr("New folder...")
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
				text: qsTr("Type")
				checkable: true
				checked: modelList.sortBy === FMList.MIME
				onTriggered: modelList.sortBy = FMList.MIME
			}
			
			Maui.MenuItem
			{
				text: qsTr("Date")
				checkable: true
				checked: modelList.sortBy === FMList.DATE
				onTriggered: modelList.sortBy = FMList.DATE
			}
			
			Maui.MenuItem
			{
				text: qsTr("Modified")
				checkable: true
				checked: modelList.sortBy === FMList.MODIFIED
				onTriggered: modelList.sortBy = FMList.MODIFIED
			}
			
			Maui.MenuItem
			{
				text: qsTr("Size")
				checkable: true
				checked: modelList.sortBy === FMList.SIZE
				onTriggered: modelList.sortBy = FMList.SIZE
			}
			
			Maui.MenuItem
			{
				text: qsTr("Name")
				checkable: true
				checked: modelList.sortBy === FMList.NAME
				onTriggered: modelList.sortBy = FMList.LABEL
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
					group ? groupBy() : undefined
				}
			}
		}
	}
	]
	
	//    footBar.leftContent: Maui.ToolButton
	//    {
	//        id: viewBtn
	//        iconColor: floatingBar ? altColorText : textColor
	
	//        iconName:  browser.detailsView ? "view-list-icons" : "view-list-details"
	//        onClicked: browser.switchView()
	//    }
	
	footBar.middleContent: Row
	{
		spacing: space.medium
		Maui.ToolButton
		{
			iconName: "go-previous"
			iconColor: footBar.colorScheme.textColor
			onClicked: control.goBack()
		}
		
		Maui.ToolButton
		{
			iconName: "go-up"
			iconColor: footBar.colorScheme.textColor
			onClicked: control.goUp()
		}
		
		Maui.ToolButton
		{
			iconName: "go-next"
			iconColor: footBar.colorScheme.textColor
			onClicked: control.goNext()
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
			sourceComponent: detailsView ? listViewBrowser : gridViewBrowser
			
			Layout.margins: detailsView ? unit : contentMargins * 2
			
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		
		Maui.SelectionBar
		{
			id: selectionBar
			Layout.fillWidth: true
			Layout.leftMargin: contentMargins*2
			Layout.rightMargin: contentMargins*2
			Layout.bottomMargin: contentMargins*2
			z: holder.z +1
			onIconClicked: itemMenu.show(selectedPaths)
			onExitClicked: clearSelection()
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
		setPath(path)
		
		if(currentPathType === FMList.PLACES_PATH && trackChanges)
		{
			var iconsize = Maui.FM.dirConf(path+"/.directory")["iconsize"] ||  iconSizes.large
			thumbnailsSize = parseInt(iconsize)
		
			detailsView = Maui.FM.dirConf(path+"/.directory")["detailview"] === "true" ? true : false
		}
				
		if(!detailsView)
			browser.adaptGrid()		
	}
		
	function goBack()
	{
		populate(modelList.previousPath)
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
		selectionBar.append(item)
	}
	
	function clearSelection()
	{
		clean()
		selectionMode = false
	}
	
	function clean()
	{
		copyPaths = []
		cutPaths = []
		browserMenu.pasteFiles = 0
		selectionBar.clear()
	}
	
	function copy(paths)
	{
		copyPaths = paths
		isCut = false
		isCopy = true
	}
	
	function cut(paths)
	{
		cutPaths = paths
		isCut = true
		isCopy = false
	}
	
	function paste()
	{
		if(isCopy)
			Maui.FM.copy(copyPaths, currentPath)
		else if(isCut)
			if(Maui.FM.cut(cutPaths, currentPath))
				clearSelection()
	}
	
	function remove(paths)
	{
		for(var i in paths)
			Maui.FM.removeFile(paths[i])
	}
	
	
	function switchView(state)
	{
		detailsView = state ? state : !detailsView
		if(trackChanges)
			Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "DetailView", detailsView)
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
		}
	}
	
	function populateTags(myTag)
	{
		Maui.FM.getTagContent(myTag)
		setPath(myTag, pathType.tags)
	}
	
	function zoomIn()
	{
		switch(thumbnailsSize)
		{
			case iconSizes.tiny: thumbnailsSize = iconSizes.small
				break
			case iconSizes.small: thumbnailsSize = iconSizes.medium
				break
			case iconSizes.medium: thumbnailsSize = iconSizes.big
				break
			case iconSizes.big: thumbnailsSize = iconSizes.large
				break
			case iconSizes.large: thumbnailsSize = iconSizes.huge
				break
			case iconSizes.huge: thumbnailsSize = iconSizes.enormous
				break
			case iconSizes.enormous: thumbnailsSize = iconSizes.enormous
				break
			default:
				thumbnailsSize = iconSizes.large
				
		}
	}
	
	function zoomOut()
	{
		switch(thumbnailsSize)
		{
			case iconSizes.tiny: thumbnailsSize = iconSizes.tiny
				break
			case iconSizes.small: thumbnailsSize = iconSizes.tiny
				break
			case iconSizes.medium: thumbnailsSize = iconSizes.small
				break
			case iconSizes.big: thumbnailsSize = iconSizes.medium
				break
			case iconSizes.large: thumbnailsSize = iconSizes.big
				break
			case iconSizes.huge: thumbnailsSize = iconSizes.large
				break
			case iconSizes.enormous: thumbnailsSize = iconSizes.huge
				break
			default:
				thumbnailsSize = iconSizes.large
				
		}
	}
	
	onThumbnailsSizeChanged:
	{
		if(trackChanges)
			Maui.FM.setDirConf(currentPath+"/.directory", "MAUIFM", "IconSize", thumbnailsSize)
		
		if(!control.detailsView)
			browser.adaptGrid()
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
		
		detailsView = true
		
		if(!prop)
		{
			browser.section.property = ""
			return
		}
		
		browser.section.property = prop
		browser.section.criteria = criteria
		
	}
}
