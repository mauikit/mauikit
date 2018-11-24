import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Maui.Menu
{
	id: control
	implicitWidth: colorBar.implicitWidth + space.big
	
	property var items : []
	property bool isDir : false
	
	signal bookmarkClicked(var items)
	signal removeClicked(var items)
	signal shareClicked(var items)
	signal copyClicked(var items)
	signal cutClicked(var items)
	signal renameClicked(var items)
	signal tagsClicked(var items)
	
	
	
	Maui.MenuItem
	{
		text: qsTr("Select")
		onTriggered:
		{
			
			addToSelection(list.get(browser.currentIndex))
		}
	}
	
	MenuSeparator{}
	Maui.MenuItem
	{
		text: qsTr("Copy...")
		onTriggered:
		{
			copyClicked(control.items)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Cut...")
		onTriggered:
		{
			cutClicked(control.items)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Rename...")
		onTriggered:
		{
			renameClicked(control.items)
			close()
		}
	}	
	
	MenuSeparator{}
	
	Maui.MenuItem
	{
		text: qsTr("Bookmark")
		enabled: isDir
		onTriggered:
		{
			bookmarkClicked(control.items)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Tags...")
		onTriggered:
		{
			tagsClicked(control.items)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Share...")
		onTriggered:
		{
			shareClicked(control.items)
			close()
		}
	}
		
	Maui.MenuItem
	{
		text: qsTr("Preview...")
		onTriggered:
		{
			previewer.show(control.items[0].path)
			close()
		}
	}
	
	MenuSeparator{}
	
	Maui.MenuItem
	{
		text: qsTr("Remove...")
		colorScheme.textColor: dangerColor
		
		onTriggered:
		{
			removeClicked(control.items)
			close()
		}
	}
	
	MenuSeparator{}	
	
	Maui.MenuItem
	{
		width: parent.width
		visible: isDir
		Maui.ColorsBar
		{
			anchors.centerIn: parent
			id: colorBar
			size:  iconSize
			onColorPicked:
			{
				for(var i in control.items)
					Maui.FM.setDirConf(control.items[i].path+"/.directory", "Desktop Entry", "Icon", color)
					
					refresh()
			}
		}
	}
	
	
	function show(items)
	{
		if(items.length > 0 )
		{
			if(items.length == 1)
				isDir = Maui.FM.isDir(items[0].path)
				
				control.items = items
				popup()
		}
	}
}
