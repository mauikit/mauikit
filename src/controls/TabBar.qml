import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

TabBar
{
	id: control
	implicitHeight: Maui.Style.rowHeight + Maui.Style.space.tiny
	Kirigami.Theme.colorSet: Kirigami.Theme.View
	Kirigami.Theme.inherit: false	
	clip: true	
	
	background: Rectangle
	{
		color: Kirigami.Theme.backgroundColor
		
		Kirigami.Separator
		{
			color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
			
			anchors
			{
				left: parent.left
				right: parent.right
				top: control.position === TabBar.Footer ? parent.top : undefined
				bottom: control.position == TabBar.Header ? parent.bottom : undefined
			}
			height: Maui.Style.unit
		}		
	}
}
