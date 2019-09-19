import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Menu
{
	id: control
	implicitWidth: colorBar.implicitWidth + space.big
	
    property var item : ({})
	property int index : -1
	property bool isDir : false
	
	signal bookmarkClicked(var item)
	signal removeClicked(var item)
	signal shareClicked(var item)
	signal copyClicked(var item)
	signal cutClicked(var item)
	signal renameClicked(var item)
	signal tagsClicked(var item)	
	
	MenuItem
	{
		text: qsTr("Select")
		onTriggered:
		{
			
			addToSelection(currentFMList.get(index))
		}
	}
	MenuSeparator{}
	
	MenuItem
	{
		visible: isDir
		text: qsTr("Open in tab")
		onTriggered: openTab(item.path)
	}
	
	MenuSeparator{}
	MenuItem
	{
		text: qsTr("Copy...")
		onTriggered:
		{
			copyClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		text: qsTr("Cut...")
		onTriggered:
		{
			cutClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
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
		text: qsTr("Bookmark")
		enabled: isDir
		onTriggered:
		{
			bookmarkClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		text: qsTr("Tags...")
		onTriggered:
		{
			tagsClicked(control.item)
			close()
		}
	}
	
	MenuItem
	{
		text: qsTr("Share...")
		onTriggered:
		{
			shareClicked(control.item)
			close()
		}
	}
		
	MenuItem
	{
		text: qsTr("Preview...")
		onTriggered:
		{
			previewer.show(control.item.path)
			close()
		}
	}
	
	MenuSeparator{}
	
	MenuItem
	{
		text: qsTr("Remove...")
		Kirigami.Theme.textColor: dangerColor
		
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
		height: visible ? iconSize + space.big : 0
		visible: isDir
		Maui.ColorsBar
        {
			id: colorBar
			
			visible: parent.visible
            anchors.centerIn: parent
			size: iconSize
			onColorPicked: currentFMList.setDirIcon(index, color)
		}
	}	
	
	function show(index)
	{		
		control.item = currentFMList.get(index)

		if(item)
		{
			control.index = index
			isDir = Maui.FM.isDir(item.path)
			popup()
		}
	}
}
