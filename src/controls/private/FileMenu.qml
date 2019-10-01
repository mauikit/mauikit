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
	
	signal bookmarkClicked(var item)
	signal removeClicked(var item)
	signal shareClicked(var item)
	signal copyClicked(var item)
	signal cutClicked(var item)
	signal renameClicked(var item)
	signal tagsClicked(var item)	
	
	MenuItem
	{
		visible: !control.isExec
		text: qsTr("Select")
		onTriggered:
		{
			
			addToSelection(currentFMList.get(index))
		}
	}
	MenuSeparator{}
	
	MenuItem
	{
		visible: control.isDir
		text: qsTr("Open in new tab...")
		onTriggered: openTab(item.path)
	}
	
    MenuSeparator{visible: isDir}
	MenuItem
	{
		visible: !control.isExec
        text: qsTr("Copy")
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
		onTriggered:
		{
			cutClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		visible: !control.isExec
        text: qsTr("Rename...")
		onTriggered:
		{
			renameClicked(control.item)
			close()
		}
	}	
	
	MenuSeparator{}
	
	MenuItem
	{
		visible: !control.isExec && control.isDir
		text: qsTr("Add to Bookmarks")
		onTriggered:
		{
			bookmarkClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		visible: !control.isExec
        text: qsTr("Tags...")
		onTriggered:
		{
			tagsClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		visible: !control.isExec		
        text: qsTr("Share...")
		onTriggered:
		{
			shareClicked(control.item)
			close()
		}
	}
		
	MenuItem
	{
		visible: !control.isExec
        text: qsTr("Properties")
		onTriggered:
		{
			previewer.show(control.item.path)
			close()
		}
	}
	
	MenuSeparator{}
	
	MenuItem
	{
        text: qsTr("Remove")
		Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
		
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

		if(item)
		{
			control.index = index
			control.isDir = item.isdir == true || item.isdir == "true"
			control.isExec = item.executable == true || item.executable == "true"
			popup()
		}
	}
}
