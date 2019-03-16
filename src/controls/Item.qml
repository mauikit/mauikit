import QtQuick 2.9
import "private"

Item
{
	id: control
	
	/* Controlc color scheming */
	ColorScheme {id: colorScheme}
	property alias colorScheme : colorScheme
	/***************************/
	
	Rectangle
	{
		anchors.fill: parent
		color: control.colorScheme.backgroundColor
	}
	
}
