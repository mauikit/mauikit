import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui

Maui.ItemDelegate
{
    id: control
    
    /**
     * images : function
     */
    property var images : []
    
    /**
     * template : function
     */
    property alias template : _template
    
    /**
     * contentWidth : function
     */
    property int contentWidth: Maui.Style.iconSizes.huge
    
    /**
     * contentHeight : function
     */
    property int contentHeight: Maui.Style.iconSizes.huge
    
    /**
     * randomHexColor : function
     */
    function randomHexColor()
    {
        var color = '#', i = 5;
        do{ color += "0123456789abcdef".substr(Math.random() * 16,1); }while(i--);
        return color;
    }
    
    /**
     * cb : function
     */
    property var cb 
    
    background: Item {}
    
    ColumnLayout
    {
        width: control.contentWidth
        height: control.contentHeight
        anchors.centerIn: parent
        spacing: Maui.Style.space.small
        
        Item
        {
            id: _collageLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Item
            {
                anchors.fill: parent
                
                Rectangle
                {
                    anchors.fill: parent
                    radius: 8
                    color: randomHexColor()
                    visible: _repeater.count === 0
                }
                
                GridLayout
                {
                    anchors.fill: parent
                    columns: 2
                    rows: 2
                    columnSpacing: 2
                    rowSpacing: 2
                    
                    Repeater
                    {
                        id: _repeater
                        
                        model: control.images
                        
                        delegate: Rectangle
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: Qt.rgba(0,0,0,0.3)
                            
                            Image
                            {
                                anchors.fill: parent
                                sourceSize.width: _repeater.count === 4 ? 100 : 200
                                sourceSize.height: _repeater.count === 4 ? 100 : 200
                                asynchronous: true
                                smooth: false
                                source: control.cb ? control.cb(modelData) : modelData
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                    }
                }
                
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    cached: true
                    maskSource: Item
                    {
                        width: _collageLayout.width
                        height: _collageLayout.height
                        
                        Rectangle
                        {
                            anchors.fill: parent
                            radius: Maui.Style.radiusV
                        }
                    }
                }
            }
            
            Rectangle
            {
                anchors.fill: parent
                
                color: "transparent"
                radius: Maui.Style.radiusV
                border.color: Qt.darker(Kirigami.Theme.backgroundColor, 2.7)
                opacity: 0.6
                
                Rectangle
                {
                    anchors.fill: parent
                    color: "transparent"
                    radius: parent.radius - 0.5
                    border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
                    opacity: 0.8
                    anchors.margins: 1
                }
            }
        }
        
        Item
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.rowHeight
            
            Rectangle
            {
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                Behavior on color
                {
                    ColorAnimation
                    {
                        duration: Kirigami.Units.longDuration
                    }
                }
                
                color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor
                
                radius: Maui.Style.radiusV
                border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
            }
            
            
            Maui.ListItemTemplate
            {
                id: _template
                isCurrentItem: control.isCurrentItem
                anchors.fill: parent
                rightLabels.visible: control.width >= 200
                iconSizeHint: Maui.Style.iconSizes.small
            }
        }
    }
}
