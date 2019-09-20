import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Video
{
	id: player

    property alias player : player
	anchors.fill: parent
	source: currentUrl
	autoLoad: true
	autoPlay: true
	loops: 3
	
	onStatusChanged:
	{
			infoModel.append({key:"Camera", value: player.metaData.cameraModel})
			infoModel.append({key:"Zoom ratio", value: player.metaData.digitalZoomRatio})
			infoModel.append({key:"Author", value: player.metaData.author})
			infoModel.append({key:"Codec", value: player.metaData.audioCodec})
			infoModel.append({key:"Copyright", value: player.metaData.copyright})
			infoModel.append({key:"Duration", value: player.metaData.duration})
			infoModel.append({key:"Frame rate", value: player.metaData.videoFrameRate})
			infoModel.append({key:"Year", value: player.metaData.year})
			infoModel.append({key:"Aspect ratio", value: player.metaData.pixelAspectRatio})
			infoModel.append({key:"Resolution", value: player.metaData.resolution})	
	}
	
	ToolButton
	{
        visible: player.playbackState == MediaPlayer.StoppedState
		anchors.centerIn: parent
		icon.color: "transparent"
		flat: true
		icon.width: Maui.Style.iconSizes.huge
		icon.name: iteminfo.icon
	}

	focus: true
	Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
	Keys.onLeftPressed: player.seek(player.position - 5000)
	Keys.onRightPressed: player.seek(player.position + 5000)
	
	RowLayout
	{
		anchors.fill: parent
		
		MouseArea
		{
			Layout.fillWidth: true
			Layout.fillHeight: true
			onDoubleClicked: player.seek(player.position - 5000)
		}
		
		MouseArea
		{
			Layout.fillWidth: true
			Layout.fillHeight: true
			onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
		}

		MouseArea
		{
			Layout.fillWidth: true
			Layout.fillHeight: true
			onDoubleClicked: player.seek(player.position + 5000)
		}		
	}
	
	Rectangle
	{
		height: Maui.Style.iconSizes.big
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
