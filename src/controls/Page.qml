import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3

Page
{
    id: control
    focus: true
    leftPadding: control.padding
    rightPadding: control.padding
    topPadding: control.padding
    bottomPadding: control.padding
    
    signal goBackTriggered();
    signal goForwardTriggered();    
    
    property alias headBar : _headBar
    property alias footBar: _footBar
    property Maui.ToolBar mheadBar : Maui.ToolBar
    { 
        id: _headBar
        visible: count > 1
         width: control.width
         height: implicitHeight
        position: ToolBar.Header 
        
        Component
        {
            id: _titleComponent
            Label
            {
                text: control.title
                elide : Text.ElideRight
                font.bold : false
                font.weight: Font.Bold
                color : Kirigami.Theme.textColor
                font.pointSize: Maui.Style.fontSizes.big
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
    
    property Maui.ToolBar mfootBar : Maui.ToolBar 
    { 
        id: _footBar
        visible: count
        position: ToolBar.Footer
          width: control.width
          height: implicitHeight
    }   
    
    header: headBar.count && headBar.position === ToolBar.Header ? headBar : null
    
    footer: Column 
    {
        id: _footer
        visible : children 
        children:
        {
			if(headBar.position === ToolBar.Footer && headBar.count && footBar.count)
				return [footBar , headBar]
				else if(headBar.position === ToolBar.Footer && headBar.count)
					return [headBar]
					else if(footBar.count)
						return [footBar]
						else
							return []
        }
    }
    
    
    Keys.onBackPressed:
    {
        control.goBackTriggered();
        event.accepted = true
    }
    
    Shortcut
    {
        sequence: "Forward"
        onActivated: control.goForwardTriggered();
    }
    
    Shortcut
    {
        sequence: StandardKey.Forward
        onActivated: control.goForwardTriggered();
    }
    
    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: control.goBackTriggered();
    }
}
