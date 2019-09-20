import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

ColumnLayout
{
	id: layout
	anchors.fill: parent
	
	Item
	{
		visible : !showInfo		
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.margins: 0
		
		Maui.ImageViewer
		{
			width: parent.width
			height: parent.height
			image.source: currentUrl
		}
	}	
	
	Item
	{
		visible: showInfo
        Layout.fillWidth: visible
        Layout.fillHeight: visible
        Layout.minimumHeight: control.height * 0.3
		
		Kirigami.ScrollablePage
		{
			anchors.fill: parent
			Kirigami.Theme.backgroundColor: "transparent"
            padding: 0
            leftPadding: padding
            rightPadding: padding
            topPadding: padding
            bottomPadding: padding
            
			ColumnLayout
			{
				id: _columnInfo
				spacing: Maui.Style.space.large
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					
					Label
					{
						visible: iteminfo.mime
						text: qsTr("Type")
						font.pointSize: Maui.Style.fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.mime
						color: Kirigami.Theme.textColor
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					
					Label
					{
						visible: iteminfo.date						
						text: qsTr("Date")
						font.pointSize: Maui.Style.fontSizes.default
						font.weight: Font.Light	
						color: Kirigami.Theme.textColor						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.date
						color: Kirigami.Theme.textColor
						
					}
				}
				
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					
					Label
					{
						visible: iteminfo.modified						
						text: qsTr("Modified")
						font.pointSize: Maui.Style.fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.modified
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					
					Label
					{
						visible: iteminfo.owner						
						text: qsTr("Owner")
						font.pointSize: Maui.Style.fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.owner
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small				
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.tags
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Symlink")
						font.pointSize: Maui.Style.fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: Maui.Style.fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: iteminfo.symlink
						color: Kirigami.Theme.textColor
					}
				}
			}
			
		}
	}
	
}

