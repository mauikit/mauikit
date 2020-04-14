import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "private" as Private
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Private.BasicToolButton
{
	id: control
	default property list<Item> content
	
	property alias menu : _menu
	checked: _menu.visible
	display: ToolButton.TextBesideIcon
	onClicked:
	{
		if(_menu.visible)
			_menu.close()
			else
                _menu.popup(0, height)
	}
	
	extraContent: Maui.Triangle
        {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            rotation: -45
            color: control.kicon.color
            Layout.preferredWidth: Maui.Style.iconSizes.tiny-3
            Layout.preferredHeight: Layout.preferredWidth 
        }	
	Menu
	{
		id: _menu
		closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside	
		contentData: control.content
	}	
}
