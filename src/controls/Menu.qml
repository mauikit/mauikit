import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import "private"
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.10

Menu
{
	id: control
	/* Controlc color scheming */
	ColorScheme 
	{
		id: colorScheme
		backgroundColor: viewBackgroundColor
	}	
	property alias colorScheme : colorScheme
	/***************************/
	z: 999
	
	default property alias content : control.contentData
}
