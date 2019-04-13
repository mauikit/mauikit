import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui

ColumnLayout
{
    id: layout
    anchors.fill: parent
    property alias player: player
    
//     Rectangle
//     {
// 		Layout.fillWidth: true
// 		Layout.fillHeight: true
// 		color: "yellow"
// 		height: 300
// 	}

    Item
    {
        Layout.fillWidth: true
//         Layout.fillHeight: true
        Layout.preferredHeight: parent.width * 0.3
        Layout.margins: contentMargins

        MediaPlayer
        {
            id: player
            source: "file://"+currentUrl
            autoLoad: true
            autoPlay: true
        }

        Maui.ToolButton
        {
            anchors.centerIn: parent
            isMask: false
            flat: true
            size: iconSizes.huge
            iconName: iteminfo.icon
            iconFallback: "qrc:/assets/application-x-zerosize.svg"
			onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
        }
        
        
        Rectangle
        {
			height: iconSizes.big
			width: height
			
			radius: height
			
			color: "black"
			
			anchors.centerIn: parent
			
			Maui.ToolButton
			{
				anchors.centerIn: parent
				iconName: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
				iconColor: "white"
				onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()				
			}
        }
        
    }
    
    Item
    {
		visible: showInfo
		Layout.fillWidth: true
		Layout.fillHeight: true
		
		ScrollView
		{
			anchors.fill: parent
			
			contentHeight: _columnInfo.implicitHeight
			
			ColumnLayout
			{
				id: _columnInfo
				width: parent.width
				spacing: space.large
				// 			spacing: rowHeight
								
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.mime
						text: qsTr("Title")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
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
						text: player.metaData.title
						color: colorScheme.textColor
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.date						
						text: qsTr("Artist")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
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
						text: player.metaData.albumArtist
						color: colorScheme.textColor
					}
				}
				
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.modified						
						text: qsTr("Album")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
						
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
						text: player.metaData.albumTitle
						color: colorScheme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.owner						
						text: qsTr("Author")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
						
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
						color: colorScheme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.tags
						text: qsTr("Codec")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.audioCodec
						color: colorScheme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Copyright")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.copyright
						color: colorScheme.textColor
						
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
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.duration
						color: colorScheme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Track")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.trackNumber
						color: colorScheme.textColor
						
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
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.year
						color: colorScheme.textColor
						
					}
				}
				
				Column
				{
					Layout.fillWidth: true
					spacing: space.small
					Label
					{
						visible: iteminfo.permissions						
						text: qsTr("Rating")
						font.pointSize: fontSizes.default
						font.weight: Font.Light
						color: colorScheme.textColor
						
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
						text: player.metaData.userRating
						color: colorScheme.textColor
						
					}
				}
				
			}
			
		}
	}
}

