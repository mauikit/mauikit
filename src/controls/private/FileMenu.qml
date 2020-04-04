import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Menu
{
    id: control
    implicitWidth: colorBar.implicitWidth + Maui.Style.space.big
    
    property var item : ({})
    property int index : -1
    property bool isDir : false
    property bool isExec : false
    property bool isFav: false
    
    signal bookmarkClicked(var item)
    signal removeClicked(var item)
    signal shareClicked(var item)
    signal copyClicked(var item)
    signal cutClicked(var item)
    signal renameClicked(var item)
    signal tagsClicked(var item)	
    signal openWithClicked(var item)
                      
    MenuItem
    {
        visible: !control.isExec && selectionBar
        text: qsTr("Select")
        icon.name: "edit-select"		
        onTriggered:
        {			
            addToSelection(currentFMList.get(index))
            if(Maui.Handy.isTouch)
                selectionMode = true
        }
    }
       
    MenuSeparator{visible: selectionBar}    
    
    MenuItem
    {
        visible: !control.isExec && tagsDialog
        text: qsTr("Add Tags")
        icon.name: "tag"
        onTriggered:
        {
            tagsClicked(control.item)
            close()
        }
    }  
    
    MenuItem
    {
        text: control.isFav ? qsTr("Remove from Favorites") : qsTr("Add to Favorites")
        icon.name: "love"		
        onTriggered:
        {			
            if(currentFMList.favItem(item.path))
                control.isFav = !control.isFav
        }
    }    
    
    MenuItem
    {
        visible: !control.isExec && control.isDir
        text: qsTr("Add to Bookmarks")
        icon.name: "bookmark-new"
        onTriggered:
        {
            bookmarkClicked(control.item)
            close()
        }
    }    
    
    MenuSeparator{}    
    
    MenuItem
    {
        visible: !control.isExec && shareDialog	
        text: qsTr("Share")
        icon.name: "document-share"
        onTriggered:
        {
            shareClicked(control.item)
            close()
        }
    }
    
    MenuItem
    {
		visible: !control.isExec && previewer
		text: qsTr("Preview")
		icon.name: "view-preview"
		onTriggered:
		{
			previewer.show(currentFMModel, control.index)
			close()
		}
	}
    
    MenuItem
    {
        visible: !control.isExec && openWithDialog	
        text: qsTr("Open with")
        icon.name: "document-open"
        onTriggered:
        {
            openWithClicked(control.item)
            close()
        }
    }
    
    MenuSeparator{visible: tagsDialog  || shareDialog || previewer}
        
    MenuItem
    {
        visible: !control.isExec
        text: qsTr("Copy")
        icon.name: "edit-copy"
        onTriggered:
        {
            copyClicked(control.item)
            close()
        }
    }
    
    MenuItem
    {
        visible: !control.isExec
        text: qsTr("Cut")
        icon.name: "edit-cut"
        onTriggered:
        {
            cutClicked(control.item)
            close()
        }
    }
    
    MenuItem
    {
        visible: !control.isExec
        text: qsTr("Rename")
        icon.name: "edit-rename"
        onTriggered:
        {
            renameClicked(control.item)
            close()
        }
    }     
    
    MenuSeparator{}
    
    MenuItem
    {
        text: qsTr("Remove")
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        icon.name: "edit-delete"
        onTriggered:
        {
            removeClicked(control.item)
            close()
        }
    }
    
    MenuSeparator{ visible: colorBar.visible }	
    
    MenuItem
    {		
        width: parent.width
        height: visible ? Maui.Style.iconSizes.medium + Maui.Style.space.big : 0
        visible: control.isDir
        Maui.ColorsBar
        {
            id: colorBar
            
            visible: parent.visible
            anchors.centerIn: parent
            size: Maui.Style.iconSizes.medium
            onColorPicked: currentFMList.setDirIcon(index, color)
        }
    }	
    
    function show(index)
    {		
        control.item = currentFMList.get(index)
        
        if(item.path.startsWith("tags://") || item.path.startsWith("applications://") )
            return
            
            if(item)
            {
                console.log("GOT ITEM FILE", index, item.path)
                control.index = index
                control.isDir = item.isdir == true || item.isdir == "true"
                control.isExec = item.executable == true || item.executable == "true"
                control.isFav = currentFMList.itemIsFav(item.path)
                popup()
            }
    }
}
