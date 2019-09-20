import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

ColumnLayout
{
    anchors.fill: parent
    property alias player: player

    Item
    {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 0

        ToolButton
        {
            anchors.centerIn: parent
            icon.color: "transparent"
            flat: true
            icon.width: Maui.Style.iconSizes.huge
            icon.name: iteminfo.icon
        }

        Video
        {
            id: player
            anchors.centerIn: parent
            anchors.fill: parent
            source: "file://"+currentUrl
            autoLoad: true
            autoPlay: true
            
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
        }
        
        Rectangle
        {
			height: iconSizes.big
			width: height
			
			radius: height
			
			color: "black"
			
            anchors.centerIn: parent
			
			ToolButton
			{
				anchors.centerIn: parent
				icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
				icon.color: "white"
				onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()				
			}
		}
    }
    
    Item
    {
        visible: showInfo
        Layout.fillWidth: visible
        Layout.fillHeight: visible
        Layout.minimumHeight: control.height * 0.3
		
		ScrollView
		{
			anchors.fill: parent
			
			contentHeight: _columnInfo.implicitHeight
			
			ColumnLayout
			{
				id: _columnInfo
				width: parent.width
				spacing: Maui.Style.space.large
				// 			spacing: rowHeight
				
				Column
				{
					Layout.fillWidth: true
					spacing: Maui.Style.space.small
					Label
					{
						visible: iteminfo.mime
						text: qsTr("Camera")
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
						text: player.metaData.cameraModel
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.date						
						text: qsTr("Zoom ratio")
						font.pointSize: fontSizes.default
						font.weight: Font.Light			
						color: Kirigami.Theme.textColor
						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: player.metaData.digitalZoomRatio
						color: Kirigami.Theme.textColor
						
					}
				}
				
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.modified						
						text: qsTr("Author")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor
						
						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: player.metaData.author
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.owner						
						text: qsTr("Codec")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: Kirigami.Theme.textColor
						
						
					}
					
					Label
					{							 
						horizontalAlignment: Qt.AlignHCenter
						verticalAlignment: Qt.AlignVCenter
						elide: Qt.ElideRight
						wrapMode: Text.Wrap
						font.pointSize: fontSizes.big
						font.weight: Font.Bold
						font.bold: true
						text: player.metaData.videoCodec
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.tags
						text: qsTr("Copyright")
						font.pointSize: fontSizes.default
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
						text: player.metaData.copyright
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Duration")
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
						text: player.metaData.duration
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Frame rate")
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
						text: player.metaData.videoFrameRate
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Year")
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
						text: player.metaData.year
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Aspect ratio")
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
						text: player.metaData.pixelAspectRatio
						color: Kirigami.Theme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Resolution")
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
						text: player.metaData.resolution
						color: Kirigami.Theme.textColor
						
					}
				}
			}			
		}
	}
    
}
