import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
	id: control
	anchors.fill: parent
	property alias player: player
	
	Item
	{
		anchors.fill: parent
		anchors.margins: Maui.Style.space.big
		
		Kirigami.Icon
		{
			anchors.centerIn: parent
			width: Math.min(parent.width, 200)
			height: width
			source: iteminfo.icon			
			smooth: true
			
			MediaPlayer
			{
				id: player
				source: currentUrl
				autoLoad: true
				autoPlay: true
				property string title : player.metaData.title
				
				onTitleChanged:
				{
					infoModel.append({key:"Title", value: player.metaData.title})
					infoModel.append({key:"Artist", value: player.metaData.albumArtist})
					infoModel.append({key:"Album", value: player.metaData.albumTitle})
					infoModel.append({key:"Author", value: player.metaData.author})
					infoModel.append({key:"Codec", value: player.metaData.audioCodec})
					infoModel.append({key:"Copyright", value: player.metaData.copyright})
					infoModel.append({key:"Duration", value: player.metaData.duration})
					infoModel.append({key:"Track", value: player.metaData.trackNumber})
					infoModel.append({key:"Year", value: player.metaData.year})
					infoModel.append({key:"Rating", value: player.metaData.userRating})
					infoModel.append({key:"Lyrics", value: player.metaData.lyrics})
					infoModel.append({key:"Genre", value: player.metaData.genre})
					infoModel.append({key:"Artwork", value: player.metaData.coverArtUrlLarge})
				}
			}
		}
	}
	
	footBar.leftContent: ToolButton
	{
		icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
		onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
		
	}
	
	footBar.rightContent: Label
	{
		text: Maui.FM.formatTime((player.duration - player.position)/1000)
	}
	
	footBar.middleContent : Slider
	{
		id: _slider
		Layout.fillWidth: true
		orientation: Qt.Horizontal
		from: 0
		to: 1000
		value: (1000 * player.position) / player.duration
		onMoved: player.seek((_slider.value / 1000) * player.duration)
	}	
}


