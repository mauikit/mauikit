import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
	anchors.fill: parent
	Kirigami.Icon
	{
		anchors.centerIn: parent
		source: iteminfo.icon
		height: Maui.Style.iconSizes.huge
		width: height
	}
}
