import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    property bool isCurrentListItem : ListView.isCurrentItem
    implicitWidth: _label.implicitWidth + Maui.Style.space.big
    
    hoverEnabled: true
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.path  
    
    background: Rectangle
    {
		color: isCurrentListItem || hovered ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)  : "transparent"
        
        Kirigami.Separator
        {
            anchors
            {
                top: parent.top
                bottom: parent.bottom
                right: parent.right               
            }            
            color: pathBarBG.border.color
        }
    }
    
    signal rightClicked()
    
    MouseArea
    {
		id: _mouseArea
		anchors.fill: parent
		acceptedButtons:  Qt.RightButton | Qt.LeftButton	
		onClicked:
		{
			if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
				control.rightClicked()
				else
					control.clicked()
		}
		
		onDoubleClicked: control.doubleClicked()	
		onPressAndHold : control.pressAndHold()
	}

    Label
    {
        id: _label
        text: model.label
        anchors.fill: parent
        rightPadding: Maui.Style.space.medium
        leftPadding: rightPadding        
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment:  Qt.AlignVCenter
        elide: Qt.ElideRight
        font.pointSize: Maui.Style.fontSizes.default
        color: Kirigami.Theme.textColor
    }    
}
