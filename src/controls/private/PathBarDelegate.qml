import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

ItemDelegate
{
    id: control
    property int arrowWidth : 8
    property bool isCurrentListItem : ListView.isCurrentItem
    implicitWidth: _label.implicitWidth + Maui.Style.space.big
    
    hoverEnabled: true
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: control.hovered
    ToolTip.text: model.path 
    
    background: Maui.PathArrowBackground
    {        
        arrowWidth: control.arrowWidth
        color: isCurrentListItem || hovered ? Kirigami.Theme.highlightColor : pathBarBG.border.color
        
        Maui.PathArrowBackground
        {
            anchors.fill: parent
            anchors.margins: 1
            arrowWidth: parent.arrowWidth
            color:  Kirigami.Theme.backgroundColor
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

    contentItem: Label
    {
        id: _label
        text: model.label
        anchors.fill: parent
        rightPadding: Maui.Style.space.medium
        leftPadding: rightPadding        
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment:  Qt.AlignVCenter
        elide: Qt.ElideRight
        wrapMode: Text.NoWrap
        font.pointSize: Maui.Style.fontSizes.default
        color: Kirigami.Theme.textColor
    }    
}
