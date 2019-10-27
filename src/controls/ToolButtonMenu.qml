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
	checked: _menu.visible
	checkable: false
	display: ToolButton.TextBesideIcon
	text: " "
	onClicked:
	{
		if(_menu.visible)
			_menu.close()
			else
				_menu.popup(0, height)
	}
	
	indicator: Kirigami.Icon
	{
		anchors
		{
			right: parent.right
// 			bottom: parent.bottom
			verticalCenter: parent.verticalCenter
		}
		color: control.Kirigami.Theme.textColor
		source: "qrc://assets/arrow-down.svg"
		width: Maui.Style.iconSizes.small
		height: width
		isMask: true
	}		
	
	
	Menu
	{
		id: _menu
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
		
		contentData: control.content
	}
}
