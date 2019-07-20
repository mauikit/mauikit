import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Page
{
	id: control
	
	property alias headBar : _headBar
	property alias footBar: _footBar
	property QtObject mheadBar : Maui.ToolBar
	{ 
		id: _headBar
		visible: count
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
			sourceComponent: control.title ? _titleComponent : undefined
		}
	}
	
	property QtObject mfootBar : Maui.ToolBar 
	{ 
		id: _footBar
		visible: count
		position: ToolBar.Footer
		Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor		
	}   
	
	header: headBar.position === ToolBar.Header ? headBar : undefined	
	footer: Column 
	{
		id: _footer
		children: headBar.position === ToolBar.Footer ? [footBar, headBar] : footBar		
	}  
}
