import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3


Page
{
	id: control
	
// 	property int margins: 0       
// 	contentItem.anchors.margins: margins
// 	contentItem.anchors.left: contentItem.parent.left
// 	contentItem.anchors.top: contentItem.parent.top
// 	contentItem.anchors.bottom: contentItem.parent.bottom
// 	contentItem.anchors.right: contentItem.parent.right

leftPadding: control.padding
rightPadding: control.padding
topPadding: control.padding
bottomPadding: control.padding
	
	property alias headBar : _headBar
	property alias footBar: _footBar
	property QtObject mheadBar : Maui.ToolBar
	{ 
		id: _headBar
		visible: count > 1
		width: control.width	
		position: ToolBar.Header 
		Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor	
		
		Component
		{
			id: _titleComponent
			Label
			{				
				text: control.title				
				elide : Text.ElideRight
				font.bold : false
				font.weight: Font.Bold
				color : colorScheme.textColor
				font.pointSize: fontSizes.big
				horizontalAlignment : Text.AlignHCenter
				verticalAlignment :  Text.AlignVCenter
				
			}
		}
		
		middleContent: Loader
		{
            Layout.fillWidth: sourceComponent === _titleComponent
            Layout.fillHeight: sourceComponent === _titleComponent
			sourceComponent: control.title ? _titleComponent : undefined
		}
	}
	
	property QtObject mfootBar : Maui.ToolBar 
	{ 
		id: _footBar
		visible: count
		position: ToolBar.Footer
		width: control.width		
		Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor		
	}   
	
	header: headBar.count && headBar.position === ToolBar.Header ? headBar : undefined
	
	footer: Column 
		{
			id: _footer
			children:
			{
				if(headBar.position === ToolBar.Footer && footBar.count) 
					 return [footBar , headBar]
				else if(headBar.position === ToolBar.Footer)
					 return [headBar]
				else if(footBar.count)
					return [footBar]
				else 
					 return []
			}
		}
	
	
	Keys.onBackPressed:
	{
		goBackTriggered();
		console.log("GO BACK CLICKED")
		event.accepted = true
	}
	
	Shortcut
	{
		sequence: "Forward"
		onActivated: goFowardTriggered();
	}
	
	Shortcut
	{
		sequence: StandardKey.Forward
		onActivated: goFowardTriggered();
	}
	
	Shortcut
	{
		sequence: StandardKey.Back
		onActivated: goBackTriggered();
	}
}
