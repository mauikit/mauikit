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
		text: control.currentFMList.count + " " + qsTr("items")
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
	
	headBar.position: Kirigami.Settings.isMobile ? ToolBar.Footer : ToolBar.Header
	property list<QtObject> t_actions:
	[
	Action
	{
		id: _previewAction
		icon.name: "image-preview"
		text: qsTr("Previews")
		checkable: true
		checked: control.showThumbnails
		onTriggered: control.showThumbnails = !control.showThumbnails
	},
	
	Action
	{
		id: _hiddenAction
		icon.name: "visibility"
		text: qsTr("Hidden files")
		checkable: true
		checked: control.currentFMList.hidden
		onTriggered: control.currentFMList.hidden = !control.currentFMList.hidden
	},
	
	Action
	{
		id: _bookmarkAction
		icon.name: "bookmark-new"
		text: qsTr("Bookmark")
		onTriggered: control.bookmarkFolder([currentPath])
	},
	
	Action
	{
		id: _newFolderAction
		icon.name: "folder-add"
		text: qsTr("New folder")
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
		text: qsTr("New file")
		onTriggered:
		{
			dialogLoader.sourceComponent= newFileDialogComponent
			dialog.open()
		}
	},
	
	Action
	{
		id: _pasteAction
		text: qsTr("Paste")
		icon.name: "edit-paste"
// 		enabled: control.clipboardItems.length > 0
		onTriggered: paste()
	},
	
	Action
	{
		id: _selectAllAction
		text: qsTr("Select all")
		icon.name: "edit-select-all"
		onTriggered: control.selectAll()
	},
	
	Action
	{
		text: qsTr("Status bar")
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
			property var urls: []
			
			title: qsTr(String("Removing %1 files").arg(urls.length.toString()))
			message: isAndroid ?  qsTr("This action will completely remove your files from your system. This action can not be undone.") : qsTr("You can move the file to the Trash or Delete it completely from your system. Which one you preffer?")
			rejectButton.text: qsTr("Delete")
			acceptButton.text: qsTr("Trash")
			acceptButton.visible: !Kirigami.Settings.isMobile
			page.padding: Maui.Style.space.huge
			
			onRejected:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate(Maui.Style.dangerColor)
					control.clean()
				}
				
				for(var i in urls)
					Maui.FM.removeFile(urls[i])
					
				close()
			}
			
			onAccepted:
			{
				if(control.selectionBar && control.selectionBar.visible)
				{
					control.selectionBar.animate(Maui.Style.dangerColor)
					control.clean()					
				}
				
				for(var i in urls)
					Maui.FM.moveToTrash(urls[i])
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
			title: qsTr("New file")
			message: qsTr("Create a new file with a custom name and extension")
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
			title: qsTr("Rename file")
			message: qsTr("Rename a file or folder to a new custom name")
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
				if(control.previewer.visible)
					control.previewer.tagBar.list.refresh()					
			}
		}
	}
	
	BrowserMenu
	{
		id: browserMenu
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
			control.remove([item.path])
		}
		
		onShareClicked: control.shareFiles([item.path])
	}
	
	Connections
	{
		target: browserView.currentView
		
		onKeyPress:
		{
			console.log(event.key, event.modifier, event.count)
			const index = browserView.currentView.currentIndex			
			const item = control.currentFMList.get(index)
			
			// Shortcuts for refreshing
			if((event.key == Qt.Key_F5))
			{
				control.currentFMList.refresh()
			}
			
			// Shortcuts for selecting file	
			if((event.key == Qt.Key_A) && (event.modifiers & Qt.ControlModifier))
			{
				control.selectAll()
			}
			
			if(event.key == Qt.Key_S)
			{				
				if(control.selectionBar && control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtPath(item.path)
				}else
				{
					control.addToSelection(item)				
				}
			}
			
			if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
			{
				if(control.selectionBar && control.selectionBar.contains(item.path))
				{
					control.selectionBar.removeAtPath(item.path)
				}else
				{
					control.addToSelection(item)				
				}
			}
			
			// Shortcut for pasting an item		
			if((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier))
			{
				control.paste(Maui.Handy.getClipboard().urls)
			}		
			
			// Shortcut for cutting an item				
			if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar)
				{
					urls = control.selectionBar.selectedPaths
				}
				else 
				{
					urls = [item.path]
				}					
				control.cut(urls)
			}		
			
			// Shortcut for copying an item				
			if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier))
			{
				var urls = []
				if(control.selectionBar)
				{
					urls = control.selectionBar.selectedPaths
				}
				else 
				{
					urls = [item.path]
				}				
				control.copy(urls)					
			}	
			
			// Shortcut for removing an item
			if(event.key == Qt.Key_Delete)
			{
				var urls = []
				if(control.selectionBar)
				{
					urls = control.selectionBar.selectedPaths
				}
				else 
				{
					urls = [item.path]
				}				
				control.remove(urls)				
			}
			
			// Shortcut for opening new tab			
			if((event.key == Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
			{
				control.openTab((currentPath).toString())
			}
			
			// Shortcut for closing tab	
			if((event.key == Qt.Key_W) && (event.modifiers & Qt.ControlModifier))
			{
				if(tabsBar.count > 1)
				control.closeTab(tabsBar.currentIndex)
			}
			
			// Shortcut for opening files in new tab , previewing or launching 	
			if((event.key == Qt.Key_Return) && (event.modifiers & Qt.ControlModifier))
			{
				if(item.isdir == "true")
					control.openTab(item.path)
					
			}else if((event.key == Qt.Key_Return) && (event.modifiers & Qt.AltModifier))
			{
				control.previewer.show(control.currentFMList.get(index).path)
			}else if(event.key == Qt.Key_Return)
			{
				indexHistory.push(index)
				control.itemClicked(index)
			}
			
			// Shortcut for going back in browsing history		
			if(event.key == Qt.Key_Backspace)
			{
				control.goBack()
			}
			
			// Shortcut for clearing selection			
			if(event.key == Qt.Key_Escape)
			{
				if(control.selectionBar)
					control.clean()
			}
		}
		
		onItemClicked:
		{			
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
			text: qsTr("Grid view")
			// 			autoExclusive: true
		},
		
		Action
		{
			icon.name: "view-list-details"
			onTriggered: control.viewType = Maui.FMList.LIST_VIEW
			icon.width: Maui.Style.iconSizes.medium
			checked: browserView.viewType === Maui.FMList.LIST_VIEW
			text: qsTr("List view")
			// 			autoExclusive: true
		},
		
		Action
		{
			icon.name: "view-file-columns"
			onTriggered: control.viewType = Maui.FMList.MILLERS_VIEW
			icon.width: Maui.Style.iconSizes.medium
			checked: browserView.viewType === Maui.FMList.MILLERS_VIEW
			text: qsTr("Column view")
			// 			autoExclusive: true
		},
		
		Kirigami.Action
		{
			icon.name: "view-sort"
			text: qsTr("Sort")
			
			Kirigami.Action
			{
				text: qsTr("Folders first")
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
				text: qsTr("Modified")
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
						control.groupBy()
					else
						browserView.currentView.section.property = ""
				}
			}
		},
		
		Kirigami.Action
		{
			text: qsTr("Select mode")
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
			id: _selectionBar
			anchors.fill: parent
			onIconClicked: _selectionBarmenu.popup()
            onExitClicked:
            {
                clean()
                control.selectionMode = false
            }            
            onCountChanged:
            {
				if(_selectionBar.count < 1)
					control.clean()
			}
            onRightClicked: _selectionBarmenu.popup()

			onItemClicked: 
			{				
				control.previewer.show(itemAt(index).path)
			}
			
			onItemPressAndHold:
			{
				removeAtIndex(index)				
			}
			
			Menu
			{
				id: _selectionBarmenu
				
				MenuItem
				{
					text: qsTr("Copy")
					onTriggered: if(control.selectionBar)
					{
						control.selectionBar.animate("#6fff80")
						control.copy(selectedPaths)
						_selectionBarmenu.close()
					}
				}
				
				MenuItem
				{
					text: qsTr("Cut")
					onTriggered: if(control.selectionBar)
					{
						control.selectionBar.animate("#fff44f")
						control.cut(selectedPaths)
						_selectionBarmenu.close()
					}
					
				}
				
				MenuItem
				{
					text: qsTr("Share")
					onTriggered:
					{
						control.shareFiles(selectedPaths)
						_selectionBarmenu.close()
					}
				}
				
				MenuItem
				{
					text: qsTr("Tags")
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
						control.remove(selectedPaths)
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
		
		Maui.TabBar
		{
			id: tabsBar
			visible: _browserList.count > 1
			Layout.fillWidth: true
			Layout.preferredHeight: tabsBar.implicitHeight
			position: TabBar.Header	
			currentIndex : _browserList.currentIndex
			
			ListModel { id: tabsListModel }			
			
			Keys.onPressed:
			{
				if(event.key == Qt.Key_Return)
				{
					_browserList.currentIndex = currentIndex						
					control.currentPath =  tabsObjectModel.get(currentIndex).path
				}
			}
			
			Repeater
			{
				id: _repeater
				model: tabsListModel
				
				Maui.TabButton
				{
					id: _tabButton
					implicitHeight: tabsBar.implicitHeight
					implicitWidth: control.width / _repeater.count
					checked: index === _browserList.currentIndex
					
					text: tabsObjectModel.get(index).currentFMList.pathName
					
					onClicked:
					{
						_browserList.currentIndex = index						
						control.currentPath =  tabsObjectModel.get(index).path
					}
					
					onCloseClicked: control.closeTab(index)
				}
			}
		}
		
		ListView
		{
			id: _browserList
			Layout.margins: 0
			Layout.fillWidth: true
			Layout.fillHeight: true
			clip: true			
			focus: true
			orientation: ListView.Horizontal
			model: tabsObjectModel
			snapMode: ListView.SnapOneItem
			spacing: 0
			interactive: Kirigami.Settings.isMobile && tabsObjectModel.count > 1
			highlightFollowsCurrentItem: true
			highlightMoveDuration: 0
			onMovementEnded: _browserList.currentIndex = indexAt(contentX, contentY)
			
// 			DropArea 
// 			{
// 				id: _dropArea
// 				anchors.fill: parent
// 				z: parent.z -2
// 				onDropped:
// 				{				
// 					const urls = drop.urls
// 					for(var i in urls)			
// 					{
// 						const item = Maui.FM.getFileInfo(urls[i])
// 						if(item.isdir == "true")
// 						{
// 							control.openTab(urls[i])
// 						}
// 					}
// 				}
// 			}
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
		browserView.currentView.forceActiveFocus()
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
	
	function closeTab(index)
	{
		tabsObjectModel.remove(index)
		tabsListModel.remove(index)
	}
	
	function openTab(path)
	{
		if(path)
		{
			const component = Qt.createComponent("private/BrowserView.qml");
			if (component.status === Component.Ready)
			{
				const object = component.createObject(tabsObjectModel);
				tabsObjectModel.append(object);
			}
			
			tabsListModel.append({"path": path})
			_browserList.currentIndex = tabsObjectModel.count - 1
			
			browserView.viewType = control.viewType
			openFolder(path)
		}
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
			case Maui.FMList.CLOUD_PATH:
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
				if(selectionMode && item.isdir == "false")
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
						if (Kirigami.Settings.isMobile)
						{
							control.previewer.show(path)
						}
						else
						{
							control.openFile(path)							
						}
					}
				}
		}
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
		control.currentPath = path
		console.log("SETTING PATH")
	}
	
	function populate(path)
	{
		if(!String(path).length)
			return;
		
		browserView.currentView.currentIndex = 0
		setPath(path)
	}
	
	function goBack()
	{
		openFolder(control.currentFMList.previousPath)
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
		if(item.path.startsWith("tags://") || item.path.startsWith("applications://") )
			return
			
		if(!control.selectionBar)
			selectionBarLoader.sourceComponent = selectionBarComponent
			
			control.selectionBar.singleSelection = control.singleSelection
			control.selectionBar.append(item)
	}
	
	function clean()
	{		
		if(control.selectionBar && control.selectionBar.visible)
		{
			control.selectionBar.clear()
			selectionBarLoader.sourceComponent = null
		}
	}
	
	function copy(urls)
	{		
		Maui.Handy.copyToClipboard({"urls": urls})	
		control.isCut = false
		control.isCopy = true
	}
	
	function cut(urls)
	{
		Maui.Handy.copyToClipboard({"urls": urls})
		control.isCut = true
		control.isCopy = false
	}
	
	function paste()
	{
		const urls = Maui.Handy.getClipboard().urls
		
		if(!urls)
			return			
		
		if(control.isCopy)
		{	
            control.currentFMList.copyInto(urls)
		}
		else if(control.isCut)
		{
			control.currentFMList.cutInto(urls)
			control.clean()
		}
	}
	
	function remove(urls)
	{
		dialogLoader.sourceComponent= removeDialogComponent
		dialog.urls = urls
		dialog.open()	
	}
	
	function selectAll() //TODO for now dont select more than 100 items so things dont freeze or break
	{
		for(var i = 0; i < Math.min(control.currentFMList.count, 100); i++)
			addToSelection(control.currentFMList.get(i))
	}
		
	function bookmarkFolder(paths) //multiple paths
	{
		control.newBookmark(paths)
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
		
		if(!prop)
		{
			control.browserView.currentView.section.property = ""
			return
		}
		
        control.browserView.viewType = Maui.FMList.LIST_VIEW
		control.browserView.currentView.section.property = prop
		control.browserView.currentView.section.criteria = criteria
	}
}
