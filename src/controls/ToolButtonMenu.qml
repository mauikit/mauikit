import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtQml 2.1

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

ToolButton
{
	id: control
	default property list<Item> content
	property alias menu : _menu
	checked: _menu.visible
	checkable: false
	display: ToolButton.TextBesideIcon
	onClicked:
	{
		if(_menu.visible)
			_menu.close()
			else
				_menu.popup(0, height)
	}
	
	indicator: Maui.Triangle
	{
		anchors
		{
//            rightMargin: 5
			right: parent.right
// 			bottom: parent.bottom
			verticalCenter: parent.verticalCenter
		}
		rotation: -45
		color: control.Kirigami.Theme.textColor
		width: Maui.Style.iconSizes.tiny-3
		height:  width 
	}	

	Menu
	{
		id: _menu
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside	
		contentData: control.content
	}
}
