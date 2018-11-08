import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Maui.Menu
{
	id: control
	implicitWidth: colorBar.implicitWidth + space.big
	
	property var paths : []
	property bool isDir : false
	
	signal bookmarkClicked(var paths)
	signal removeClicked(var paths)
	signal shareClicked(var paths)
	signal copyClicked(var paths)
	signal cutClicked(var paths)
	signal renameClicked(var paths)
	signal tagsClicked(var paths)
	
	Maui.MenuItem
	{
		text: qsTr("Bookmark")
		enabled: isDir
		onTriggered:
		{
			bookmarkClicked(paths)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Tags...")
		onTriggered:
		{
			tagsClicked(paths)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Share...")
		onTriggered:
		{
			shareClicked(paths)
			close()
		}
	}
	
	MenuSeparator{}
	
	Maui.MenuItem
	{
		text: qsTr("Copy...")
		onTriggered:
		{
			copyClicked(paths)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Cut...")
		onTriggered:
		{
			cutClicked(paths)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Rename...")
		onTriggered:
		{
			renameClicked(paths)
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Remove...")
		onTriggered:
		{
			removeClicked(paths)
			close()
		}
	}
	
	MenuSeparator{}
	
	Maui.MenuItem
	{
		text: qsTr("Preview...")
		onTriggered:
		{
			previewer.show(paths[0])
			close()
		}
	}
	
	Maui.MenuItem
	{
		text: qsTr("Select")
        onTriggered:
        {

            addToSelection(list.get(browser.currentIndex))
        }
	}
	
	Maui.MenuItem
	{
		width: parent.width
		
		Maui.ColorsBar
		{
			anchors.centerIn: parent
			id: colorBar
			size:  iconSize
			onColorPicked:
			{
				for(var i in control.paths)
					Maui.FM.setDirConf(control.paths[i]+"/.directory", "Desktop Entry", "Icon", color)
					
					refresh()
			}
		}
	}
	
	function show(urls)
	{
		if(urls.length > 0 )
		{
			paths = urls
			isDir = Maui.FM.isDir(paths[0])
			popup()
		}
	}
}
