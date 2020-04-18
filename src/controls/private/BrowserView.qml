import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control
    title: currentFMList.pathName
    property url path 
    onPathChanged:
    {
        if(control.currentView) 
        {
            control.currentView.currentIndex = 0
            control.currentView.forceActiveFocus()
        }
    }
    
    //group properties from the browser since the browser views are loaded async and
    //their properties can not be accesed inmediately, so they are stored here and then when completed they are set    
    property alias settings : _settings
    BrowserSettings 
    {
		id: _settings 
		onGroupChanged:
		{
			if(settings.group)
			{
				groupBy()				
			}	
			else
			{
				currentView.section.property = ""				
			}
		}
	}
    
    property Maui.FMList currentFMList
    property Maui.BaseModel currentFMModel
    
    property alias currentView : viewLoader.item
    property string filter    
   
    function setCurrentFMList()
    {
        if(control.currentView)
        {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }
    
    function filterSelectedItems(path)
    {     
        if(selectionBar && selectionBar.count > 0 && selectionBar.contains(path))
        {
            const uris = selectionBar.uris
            var res = []
            for(var i in uris)
            {
                if(Maui.FM.parentDir(uris[i]) == control.path)
                {
                    res.push(uris[i])                    
                } 
            }  
            
            return res.join("\n")  
        }        
        
        return path
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
			control.currentView.section.property = ""
			return
		}
		
		control.settings.viewType = Maui.FMList.LIST_VIEW
		control.currentView.section.property = prop
		control.currentView.section.criteria = criteria
	}
    
    Menu
    {
        id: _dropMenu
        property string urls
        property url target
        
        enabled: Maui.FM.getFileInfo(target).isdir == "true" && !urls.includes(target.toString())
        
        MenuItem
        {
            text: qsTr("Copy here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.copy(urls, _dropMenu.target, false)
            }
        }
        
        MenuItem
        {
            text: qsTr("Move here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                Maui.FM.cut(urls, _dropMenu.target)
            }
        }
        
        MenuItem
        {
            text: qsTr("Link here")
            onTriggered:
            {
                const urls = _dropMenu.urls.split(",")
                for(var i in urls)
					Maui.FM.createSymlink(url[i], _dropMenu.target)
            }
        }
        
        MenuSeparator {}
        
        MenuItem
        {
            text: qsTr("Cancel")
            onTriggered: _dropMenu.close()
        }
	}    
	
	Loader
	{
		id: viewLoader
		anchors.fill: parent
		focus: true
		sourceComponent: switch(settings.viewType)
		{
			case Maui.FMList.ICON_VIEW: return gridViewBrowser
			case Maui.FMList.LIST_VIEW: return listViewBrowser
			case Maui.FMList.MILLERS_VIEW: return millerViewBrowser
		}
		
		onLoaded: setCurrentFMList()
	}
	
    
    Maui.FMList
    {
        id: _commonFMList
        path: control.path
        onSortByChanged: if(settings.group) groupBy()
        onlyDirs: settings.onlyDirs
        filterType: settings.filterType
        filters: settings.filters
        sortBy: settings.sortBy
        hidden: settings.showHiddenFiles
    }
    
    Component
    {
        id: listViewBrowser
        
        Maui.ListBrowser
        {
            id: _listViewBrowser
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            topMargin: Maui.Style.contentMargins
            showPreviewThumbnails: settings.showThumbnails
            checkable: selectionMode
            enableLassoSelection: true
            spacing: Kirigami.Settings.isMobile ? Maui.Style.space.small : Maui.Style.space.medium
            
            BrowserHolder
            {
                id: _holder
                browser: currentFMList
            }
            
            holder.visible: _holder.visible
            holder.emoji: _holder.emoji
            holder.title: _holder.title
            holder.body: _holder.body
            holder.emojiSize: _holder.emojiSize
            
            model: Maui.BaseModel
            {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }
            
            section.delegate: Maui.LabelDelegate
            {
                id: delegate
                width: parent.width
                height: Maui.Style.toolBarHeightAlt
                
                label: String(section).toUpperCase()
                labelTxt.font.pointSize: Maui.Style.fontSizes.big
                
                isSection: true
            }
            
            delegate: Maui.ListBrowserDelegate
            {
                id: delegate
                width: parent.width
                
                padding: 0
                leftPadding: Maui.Style.space.small
                rightPadding: leftPadding
                
                iconSizeHint : Maui.Style.iconSizes.medium
                imageSizeHint : height * 0.8
                
                tooltipText: model.path
                
                checkable: _listViewBrowser.checkable
                showThumbnails: _listViewBrowser.showPreviewThumbnails
                
                checked: selectionBar ? selectionBar.contains(model.path) : false
				opacity: model.hidden == "true" ? 0.5 : 1
                draggable: true
                
                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ? 
                {
                    "text/uri-list": control.filterSelectedItems(model.path) 
                } : {}
                
                Item
                {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    visible: (model.issymlink == true) || (model.issymlink == "true")
                    
                    Kirigami.Icon
                    {
                        source: "link"
                        height: Maui.Style.iconSizes.small
                        width: Maui.Style.iconSizes.small
                        anchors.centerIn: parent
                        color: label1.color
                    }
                }
                
                Connections
                {
                    target: selectionBar
                    
                    onUriRemoved:
                    {
                        if(uri === model.path)
                            delegate.checked = false
                    }
                    
                    onUriAdded:
                    {
                        if(uri === model.path)
                            delegate.checked = true
                    }
                    
                    onCleared: delegate.checked = false
                }
                
                Connections
                {
                    target: delegate
                    onClicked:
                    {
                        _listViewBrowser.currentIndex = index
						
						if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
						{
							_listViewBrowser.itemsSelected([index])
						}else						
						{
							_listViewBrowser.itemClicked(index)
						}
                    }
                    
                    onDoubleClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemDoubleClicked(index)
                    }
                    
                    onPressAndHold:
                    {
                         if(!Maui.Handy.isTouch)
                                return
                                
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemRightClicked(index)
                    }
                    
                    onRightClicked:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemRightClicked(index)
                    }
                    
                    onToggled:
                    {
                        _listViewBrowser.currentIndex = index
                        _listViewBrowser.itemToggled(index, state)
                    }
                    
                    onContentDropped:
                    {
                        _dropMenu.urls = drop.urls.join(",")
                        _dropMenu.target = model.path
                        _dropMenu.popup()
                    }
                }
            }
        }
    }
    
    Component
    {
        id: gridViewBrowser
        
        Maui.GridBrowser
        {
            id: _gridViewBrowser
            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel
            itemSize : thumbnailsSize + Maui.Style.space.small
            cellHeight: itemSize * 1.5
            checkable: selectionMode
            showPreviewThumbnails: settings.showThumbnails
            enableLassoSelection: true
            
            BrowserHolder
            {
                id: _holder
                browser: currentFMList
            }
            
            holder.visible: _holder.visible
            holder.emoji: _holder.emoji
            holder.title: _holder.title
            holder.body: _holder.body
            holder.emojiSize: _holder.emojiSize
            model: Maui.BaseModel
            {
                id: _browserModel
                list: _commonFMList
                filter: control.filter
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }
            
            delegate: Item
            {
                property bool isCurrentItem : GridView.isCurrentItem
                height: _gridViewBrowser.cellHeight
                width: _gridViewBrowser.cellWidth

                Maui.GridBrowserDelegate
                {
                    id: delegate
                    
                    iconSizeHint: height * 0.5
                    
                    anchors.centerIn: parent
                    height: _gridViewBrowser.cellHeight - 5
                    width: _gridViewBrowser.itemSize - 5
                    padding: Maui.Style.space.tiny
                    isCurrentItem: parent.isCurrentItem
                    tooltipText: model.path
                    checkable: _gridViewBrowser.checkable
                    showThumbnails: _gridViewBrowser.showPreviewThumbnails
                    checked: (selectionBar ? selectionBar.contains(model.path) : false) 
                    draggable: true
                    opacity: model.hidden == "true" ? 0.5 : 1
                    
                    Drag.keys: ["text/uri-list"]
                    Drag.mimeData: Drag.active ? 
                    {
                        "text/uri-list": control.filterSelectedItems(model.path) 
                    } : {}
                    
                    Maui.Badge
                    {
                        iconName: "link"
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Maui.Style.space.big
                        visible: (model.issymlink == true) || (model.issymlink == "true")
                    }                    
                                      
                    Connections
                    {
                        target: selectionBar
                        
                        onUriRemoved:
                        {
                            if(uri === model.path)
                                delegate.checked = false
                        }
                        
                        onUriAdded:
                        {
                            if(uri === model.path)
                                delegate.checked = true
                        }
                        
                        onCleared: delegate.checked = false
                        
                    }
                    
                    Connections
                    {
						target: delegate
						onClicked:
						{					
							_gridViewBrowser.currentIndex = index
							
							if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
							{
								_gridViewBrowser.itemsSelected([index])
							}else						
							{
								_gridViewBrowser.itemClicked(index)
							}
						}
                        
                        onDoubleClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemDoubleClicked(index)
                        }
                        
                        onPressAndHold:
                        {
                            if(!Maui.Handy.isTouch)
                                return
                                
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemRightClicked(index)
                        }
                        
                        onRightClicked:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemRightClicked(index)
                        }
                        
                        onToggled:
                        {
                            _gridViewBrowser.currentIndex = index
                            _gridViewBrowser.itemToggled(index, state)
                        }
                        
                        onContentDropped:
                        {
                            _dropMenu.urls = drop.urls.join(",")
                            _dropMenu.target = model.path
                            _dropMenu.popup()
                            
                        }
                    }
                }
            }            
        }
    }
    
    Component
    {
        id: millerViewBrowser
        
        ScrollView
        {
            id: _millerControl
            property Maui.FMList currentFMList
            property Maui.BaseModel currentFMModel
            property int currentIndex
            
            signal itemClicked(int index)
            signal itemDoubleClicked(int index)
            signal itemRightClicked(int index)
            signal keyPress(var event)
            signal itemToggled(int index, bool state)
            signal itemsSelected(var indexes)
            
            signal areaClicked(var mouse)
            signal areaRightClicked()
            
			function forceActiveFocus()
			{
				_millerColumns.currentItem.forceActiveFocus()
			}
			
			contentWidth: _millerColumns.contentWidth
			contentHeight: height
			
			ScrollBar.horizontal: ScrollBar
			{
                id: horizontalScrollBar
                height: visible ? implicitHeight: 0
                parent: _millerControl
                x: 0
                y: _millerControl.height - height
                width: _millerControl.width
                active: _millerControl.ScrollBar.horizontal || _millerControl.ScrollBar.horizontal.active
            }
			
// 			ScrollBar.horizontal: ScrollBar
// 			{
//                 id: _scrollBar
//                 snapMode: ScrollBar.SnapAlways
//                 policy: ScrollBar.AlwaysOn
//                 
//                 contentItem: Rectangle
//                 {
//                     implicitWidth: _scrollBar.interactive ? 13 : 4
//                     implicitHeight: _scrollBar.interactive ? 13 : 4
//                     
//                     color: "#333"
//                     
//                     opacity: _scrollBar.pressed ? 0.7 :
//                     _scrollBar.interactive && _scrollBar.hovered ? 0.5 : 0.2
//                     radius: 0
//                 }
//                 
//                 background: Rectangle
//                 {
//                     implicitWidth: _scrollBar.interactive ? 16 : 4
//                     implicitHeight: _scrollBar.interactive ? 16 : 4
//                     color: "#0e000000"
//                     opacity: 0.0
//                     visible: _scrollBar.interactive
//                     radius: 0
//                     
//                 }
//             }
            
            ListView
            {
                id: _millerColumns
                anchors.fill: parent
                anchors.bottomMargin: horizontalScrollBar.height
                boundsBehavior: !Maui.Handy.isTouch? Flickable.StopAtBounds : Flickable.OvershootBounds
                
                keyNavigationEnabled: true
                interactive: Kirigami.Settings.hasTransientTouchInput
                cacheBuffer: contentWidth
                orientation: ListView.Horizontal
                snapMode: ListView.SnapToItem
                clip: true               
                
                onCurrentItemChanged:
                {
                    _millerControl.currentFMList = currentItem.currentFMList
                    _millerControl.currentFMModel = currentItem.currentFMModel
                    control.setCurrentFMList()
                    currentItem.forceActiveFocus()
                }
                
                onCountChanged:
                {
                    _millerColumns.currentIndex = _millerColumns.count-1
                    _millerColumns.positionViewAtEnd()
                }
                
                Maui.PathList
                {
                    id: _millerList
                    path: control.path
                    
                    onPathChanged:
                    {
                        _millerColumns.currentIndex = _millerColumns.count-1
                        _millerColumns.positionViewAtEnd()
                    }
                }
                
                model: Maui.BaseModel
                {
                    id: _millerModel
                    list: _millerList
                }
                
                delegate: Item
                {
                    property alias currentFMList : _millersFMList
                    property alias currentFMModel : _millersFMModel
                    property int _index : index
                    width: Math.min(Kirigami.Units.gridUnit * 22, control.width)
                    height: parent.height
                    focus: true
                    
                    function forceActiveFocus()
                    {
                        _millerListView.forceActiveFocus()
                    }
                    
                    Kirigami.Separator
                    {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 1
                        z: 999
                    }
                    
                    Maui.FMList
                    {
                        id: _millersFMList
                        path: model.path
                        onlyDirs: settings.onlyDirs
                        filterType: settings.filterType
                        filters: settings.filters
                        sortBy: settings.sortBy
                        hidden: settings.showHiddenFiles
                    }
                    
                    Maui.ListBrowser
                    {
                        id: _millerListView
                        anchors.fill: parent
                        topMargin: Maui.Style.contentMargins
                        showPreviewThumbnails: settings.showThumbnails
                        checkable: selectionMode
                        onKeyPress: _millerControl.keyPress(event)
                        currentIndex : 0
                        onCurrentIndexChanged: _millerControl.currentIndex = currentIndex
                        enableLassoSelection: true
                        
                        BrowserHolder
                        {
                            id: _holder
                            browser: currentFMList
                        }
                        
                        holder.visible: _holder.visible
                        holder.emoji: _holder.emoji
                        holder.title: _holder.title
                        holder.body: _holder.body
                        holder.emojiSize: _holder.emojiSize
                        
                        section.delegate: Maui.LabelDelegate
                        {
                            id: delegate
                            width: parent.width
                            height: Maui.Style.toolBarHeightAlt
                            
                            label: String(section).toUpperCase()
                            labelTxt.font.pointSize: Maui.Style.fontSizes.big
                            
                            isSection: true
                        }
                        
                        onAreaClicked:
                        {
                            _millerColumns.currentIndex = _index
                            _millerControl.areaClicked(mouse)
                        }
                        
                        onAreaRightClicked:
                        {
                            _millerColumns.currentIndex = _index
                            _millerControl.areaRightClicked()
                        }
                        
                        onItemsSelected:
                        {
							_millerColumns.currentIndex = _index
							_millerControl.itemsSelected(indexes)
						}
						
                        model: Maui.BaseModel
                        {
                            id: _millersFMModel
                            list: _millersFMList
                            filter: control.filter
                            recursiveFilteringEnabled: true
                            sortCaseSensitivity: Qt.CaseInsensitive
                            filterCaseSensitivity: Qt.CaseInsensitive
                        }
                        
                        delegate: Maui.ListBrowserDelegate
                        {
                            id: delegate
                            width: parent.width
                            height: implicitHeight
                            padding: 0                            
                            leftPadding: Maui.Style.space.small
                            rightPadding: leftPadding
                            
                            tooltipText: model.path
                            
                            iconSizeHint : Maui.Style.iconSizes.medium
                            imageSizeHint : height * 0.8
                            
                            checkable: _millerListView.checkable
                            showThumbnails: _millerListView.showPreviewThumbnails
                            checked: selectionBar ? selectionBar.contains(model.path) : false
                            opacity: model.hidden == "true" ? 0.5 : 1
                            draggable: true
                            
                            Drag.keys: ["text/uri-list"]
                            Drag.mimeData: Drag.active ? 
                            {
                                "text/uri-list": control.filterSelectedItems(model.path) 
                            } : {}
                            
                            Item
                            {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                visible: (model.issymlink == true) || (model.issymlink == "true")
                                
                                Kirigami.Icon
                                {
                                    source: "link"
                                    height: Maui.Style.iconSizes.small
                                    width: Maui.Style.iconSizes.small
                                    anchors.centerIn: parent
                                    color: label1.color
                                }
                            }
                            
                            Connections
                            {
                                target: selectionBar
                                
                                onUriRemoved:
                                {
                                    if(uri === model.path)
                                        delegate.checked = false
                                }
                                
                                onUriAdded:
                                {
                                    if(uri === model.path)
                                        delegate.checked = true
                                }
                                
                                onCleared: delegate.checked = false
                            }
                            
                            Connections
                            {
                                target: delegate
                                onClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index  
									
									if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
									{
										_millerControl.itemsSelected([index])
									}else						
									{
										_millerControl.itemClicked(index)
									}
                                }
                                
                                onDoubleClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemDoubleClicked(index)
                                }
                                
                                onPressAndHold:
                                {
                                    if(!Maui.Handy.isTouch)
                                        return
                                        
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemRightClicked(index)
                                }
                                
                                onRightClicked:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemRightClicked(index)
                                }
                                                                
                                onToggled:
                                {
                                    _millerColumns.currentIndex = _index
                                    _millerListView.currentIndex = index
                                    _millerControl.itemToggled(index, state)
                                }
                                
                                onContentDropped:
                                {
                                    _dropMenu.urls =  drop.urls.join(",")
                                    _dropMenu.target = model.path
                                    _dropMenu.popup()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
