import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import "private"
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.10

Menu
{
	id: control
	/* Controlc color scheming */
	ColorScheme 
	{
		id: colorScheme
		backgroundColor: viewBackgroundColor
	}	
	property alias colorScheme : colorScheme
	/***************************/
	z: 999
	
	default property alias content : content.data
	
	closePolicy: Menu.CloseOnPressOutside
		
	implicitWidth: Math.max(background ? background.implicitWidth : 0,
							contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0)
	implicitHeight: Math.max(background ? background.implicitHeight : 0,
							 contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding
	margins: unit 
	padding: unit
		cascade: true
		transformOrigin: !cascade ? Item.Top : (mirrored ? Item.TopRight : Item.TopLeft)
		delegate: MenuItem { }

	topPadding: menuBackground.radius
	bottomPadding: menuBackground.radius
	leftPadding: control.padding
	rightPadding: control.padding
	
	rightMargin: control.margins
	leftMargin: control.margins
	topMargin: control.margins
	bottomMargin: control.margins   
	
	modal: isMobile
	focus: true
	parent: ApplicationWindow.overlay
	
	contentItem: ListView
	{
		id: content
		implicitHeight: contentHeight
		
		model: control.contentModel
		interactive: Window.window ? contentHeight > Window.window.height : false
		clip: true
		currentIndex: control.currentIndex
		
		ScrollIndicator.vertical: ScrollIndicator {}
	}
	
	Material.accent: colorScheme.highlightColor
	Material.background: colorScheme.backgroundColor
	Material.primary: colorScheme.backgroundColor
	Material.foreground: colorScheme.textColor
	
	enter: Transition 
	{
		// grow_fade_in
		NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
		NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
	}
	
	exit: Transition 
	{
		// shrink_fade_out
		NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
		NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
	}
	
	background: Rectangle
	{
		id: menuBackground 
		radius: radiusV
		color: colorScheme.backgroundColor
		border.color: colorScheme.borderColor		
		
		implicitWidth: Kirigami.Units.gridUnit * 8
		implicitHeight: Kirigami.Units.gridUnit * 6		
	}
}
