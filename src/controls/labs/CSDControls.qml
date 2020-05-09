import QtQuick 2.12
import QtQuick.Controls 2.3

import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.kde.appletdecoration 0.1 as AppletDecoration
// import org.kde.plasma.plasmoid 2.0

Item
{
	id: control
	readonly property bool maskButtons: Maui.App.theme.maskButtons
	
	implicitWidth: _controlsLayout.implicitWidth
	property var order : []
	// 		TapHandler {
	// 			onTapped: if (tapCount === 2) toggleMaximized()
	// 			gesturePolicy: TapHandler.DragThreshold
	// 		}
	// 		DragHandler {
	// 			grabPermissions: TapHandler.CanTakeOverFromAnything
	// 			onActiveChanged: if (active) { root.startSystemMove(); }
	// 		}
	
	
	Row
	{
		id: _controlsLayout
		spacing: Maui.Style.space.medium
		width: parent.width
		height: parent.height
		
		Repeater
		{
            model: control.order
            delegate: auroraeThemeEngine.isEnabled ? auroraeButton : pluginButton     
        }
    }
    
    Component
    {
        id: pluginButton
        
        
        AppletDecoration.Button
        {               
            width: 22                
            height: 22            
            anchors.verticalCenter: parent.verticalCenter
            bridge: bridgeItem.bridge
            sharedDecoration: sharedDecorationItem
            scheme: plasmaThemeExtended.colors.schemeFile
            type: mapControl(modelData)
            //                 isOnAllDesktops: root.isLastActiveWindowPinned
            isMaximized: Window.window.visibility === Window.Maximized 
            //                 isKeepAbove: root.isLastActiveWindowKeepAbove
            
            //                 localX: x
            //                 localY: y
            isActive: Window.window.active
            
            onClicked: performActiveWindowAction(type)                  
        }    
    }
    
    Component
    {
        id: auroraeButton
        Item {}
//         AppletDecoration.AuroraeButton
//         {
//             width: 22            
//             height: 22
//             
//             isMaximized: Window.window.visibility === Window.Maximized 
//             //                 isKeepAbove: root.isLastActiveWindowKeepAbove
//             
//             //                 localX: x
//             //                 localY: y
//             isActive: Window.window.active
//             
//             onClicked: performActiveWindowAction(buttonType)  
//             
//             buttonType: mapControl(modelData)
//             auroraeTheme: auroraeThemeEngine
//             
//         }
    }
    
    AppletDecoration.WindowSystem 
    {
        id: windowSystem
    }
    
    AppletDecoration.PlasmaThemeExtended 
    {
        id: plasmaThemeExtended
        
                readonly property bool isActive: plasmoid.configuration.selectedScheme === "_plasmatheme_"
                    
                    function triggerUpdate() 
                    {
                        if (isActive) 
                        {
//                             initButtons();
                            sharedDecorationItem.createDecoration();
                        }
                    }
                    
                    onThemeChanged: triggerUpdate();
                    onColorsChanged: triggerUpdate();
    }
    
    AppletDecoration.Bridge 
    {
        id: bridgeItem
        plugin: decorations.currentPlugin
        theme: decorations.currentTheme 
    }
    
    AppletDecoration.Settings 
    {
        id: settingsItem
        bridge: bridgeItem.bridge
        borderSizesIndex: 0 // Normal
    }
    
    AppletDecoration.SharedDecoration 
    {
        id: sharedDecorationItem
        bridge: bridgeItem.bridge
        settings: settingsItem
    }
    
    AppletDecoration.DecorationsModel 
    {
        id: decorations
    }
    
    AppletDecoration.AuroraeTheme 
    {
        id: auroraeThemeEngine
        theme: isEnabled ? decorations.currentTheme : ""
        
        readonly property bool isEnabled: decorations.isAurorae(decorations.currentPlugin, decorations.currentTheme);
    }
    
//     PlasmaTasksModel{id: windowInfo}
	
	function mapControl(key)
	{
        switch(key)
        {
            case "X": return  AppletDecoration.Types.Close;
            case "I": return  AppletDecoration.Types.Minimize;
            case "A": return  AppletDecoration.Types.Maximize;
            case "F": return  AppletDecoration.Types.KeepAbove;
            case "S": return  AppletDecoration.Types.OnAllDesktops;
            default: return null;			
        }
	}
	
	function performActiveWindowAction(type)
    {
        if (type === AppletDecoration.Types.Close) {
            root.close()
        } else if (type === AppletDecoration.Types.Maximize) {
            root.toggleMaximized()
        } else if (type ===  AppletDecoration.Types.Minimize) {
            root.showMinimized()
        } else if (type === AppletDecoration.Types.TogglePinToAllDesktops) {
            windowInfo.togglePinToAllDesktops();
        } else if (type === AppletDecoration.Types.ToggleKeepAbove){
            windowInfo.toggleKeepAbove();
        }
    }
}
