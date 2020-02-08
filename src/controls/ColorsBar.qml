import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Row
{
	signal colorPicked(string color)
	anchors.verticalCenter: parent.verticalCenter
	spacing: Maui.Style.space.medium
	property string currentColor
	property int size : Maui.Style.iconSizes.medium
	
	
	Rectangle
	{
		color:"#f21b51"
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		radius: Maui.Style.radiusV
		border.color: Qt.darker(color, 1.7)
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = parent.color
				colorPicked("folder-red")
			}
		}
	}
	
	
	Rectangle
	{
		color:"#f9a32b"
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		radius: Maui.Style.radiusV
		border.color: Qt.darker(color, 1.7)
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = parent.color
				colorPicked("folder-orange")
			}
		}
	}
	
	
	Rectangle
	{
		color:"#3eb881"
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		radius: Maui.Style.radiusV
		border.color: Qt.darker(color, 1.7)
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = parent.color
				colorPicked("folder-green")
			}
		}
	}
	
	
	Rectangle
	{
		color:"#b2b9bd"
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		radius: Maui.Style.radiusV
		border.color: Qt.darker(color, 1.7)
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = parent.color
				colorPicked("folder-grey")
			}
		}		
	}
	
	Rectangle
	{
		color:"#474747"
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		radius: Maui.Style.radiusV
		border.color: Qt.darker(color, 1.7)
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = parent.color
				colorPicked("folder-black")
			}
		}
	}
	
	Kirigami.Icon
	{
		anchors.verticalCenter: parent.verticalCenter
		height: size
		width: height
		
		source: "edit-clear"
		color: Kirigami.Theme.textColor
		
		MouseArea
		{
			anchors.fill: parent
			onClicked:
			{
				currentColor = ""
				colorPicked("folder")
			}
		}
	}
}
