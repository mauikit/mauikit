import QtQuick 2.6
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ToolBar
{
    id: control
    clip: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: toolBarHeight
    height: implicitHeight
    
    property alias middleLayout : flickableLayout
    property alias layout : layout
    property int margins: space.medium
    property int count : leftContent.length + middleContent.length + rightContent.length
    
    property alias leftContent : leftRowContent.data
    property alias middleContent : middleRowContent.data
    property alias rightContent : rightRowContent.data
    padding: 0
    
    //    leftPadding: Kirigami.Units.smallSpacing*2
    //    rightPadding: Kirigami.Units.smallSpacing*2
    
    Rectangle
    {
        width: parent.height 
        height: iconSizes.tiny
        visible: !mainFlickable.atXEnd && mainFlickable.interactive
        rotation: 270
        opacity: 0.25
        anchors 
        {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        z: 999
        
        gradient: Gradient
        {
            GradientStop
            {
                position: 0.0
                color: "transparent"
            }
            GradientStop 
            {
                position: 1.0
                color: textColor
            }
        }
        
    }
    
    Rectangle
    {
        width: parent.height
        height: iconSizes.tiny
        visible: !mainFlickable.atXBeginning && mainFlickable.interactive
        rotation: 270
        opacity: 0.25
        anchors 
        {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        z: 999
        
        gradient: Gradient 
        {
            GradientStop
            {
                position: 0.0
                color: textColor
            }
            
            GradientStop
            {
                position: 1.0
                color: "transparent"
            }
        }            
    }
    
    
    Flickable
    {
        id: mainFlickable
        
        property int itemSpacing: space.medium
        
        flickableDirection: Flickable.HorizontalFlick
        anchors.fill: parent
        interactive: layout.implicitWidth > control.width
        contentWidth: layout.implicitWidth
        boundsBehavior: isMobile ? Flickable.DragOverBounds : Flickable.StopAtBounds
        
        RowLayout
        {
            id: layout
            width: control.width
            height: control.height
            
            Row
            {
                id: leftRowContent
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.leftMargin: leftContent.length > 0 ? margins : 0
                spacing: mainFlickable.itemSpacing
                Layout.minimumWidth: 0
                clip: true
            }
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
                Layout.margins: space.medium
                Layout.topMargin: space.big
                Layout.bottomMargin: space.big
                width: unit
                opacity: 0.4
                visible: leftContent.length > 0 && flickable.interactive
            }
            
            Item
            {
                id: flickableItem
                Layout.fillHeight: true
                Layout.fillWidth: true
//                 Layout.minimumWidth: control.width * 0.3
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.rightMargin: middleContent.length === 1 ? 0 : margins
                Layout.leftMargin: middleContent.length === 1 ? 0 : margins
                clip: true
                
                Flickable
                {
                    id: flickable
                    
                    property int itemSpacing: space.medium
                    anchors.fill: parent
                    flickableDirection: Flickable.HorizontalFlick
                    
                    interactive: middleRowContent.implicitWidth > width
                    contentWidth: middleRowContent.implicitWidth
                    
                    boundsBehavior: isMobile ?  Flickable.DragOverBounds : Flickable.StopAtBounds
                    
                    
                    RowLayout
                    {
                        id: flickableLayout
                        width: flickableItem.width
                        height: flickableItem.height
                        
                        Item
                        {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 0
                            Layout.minimumWidth: 0
                        }
                        
                        Row
                        {
                            id: middleRowContent
                            
                            spacing: middleContent.length === 1 ? 0 : flickable.itemSpacing
                            
                            
                            //                Layout.maximumWidth: control.width - leftRowContent.implicitWidth - rightRowContent.implicitWidth
                            
                        }
                        
                        Item
                        {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 0
                            Layout.minimumWidth: 0
                        }
                    }
                    
                    ScrollBar.horizontal: ScrollBar { visible: false}
                }
                
            }
            
            Kirigami.Separator
            {
                Layout.fillHeight: true
                Layout.margins: space.medium
                Layout.topMargin: space.big
                Layout.bottomMargin: space.big
                width: unit
                opacity: 0.4
                visible: rightContent.length > 0 && flickable.interactive
            }
            
            Row
            {
                id: rightRowContent
                Layout.alignment: Qt.AlignRight
                spacing: mainFlickable.itemSpacing
                Layout.rightMargin: rightContent.length > 0 ? margins : 0
                Layout.minimumWidth: 0
                clip: true
                
            }
        }
        ScrollBar.horizontal: ScrollBar { visible: false}
        
    }
}
