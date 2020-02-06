/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

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
    
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    
    property bool showTitle : true
    
    property Flickable flickable : null
    property int footerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineFooter
    property int headerPositioning : Kirigami.Settings.isMobile && flickable ? ListView.PullBackHeader : ListView.InlineHeader
    
    signal goBackTriggered()
    signal goForwardTriggered()	
    
    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
    }
    
    onFlickableChanged: returnToBounds()
    
    Connections 
    {
        target: control.flickable ? control.flickable : null
        enabled: control.flickable && (control.header || control.footer)
        property int oldContentY
        property bool updatingContentY: false        
        onContentHeightChanged: returnToBounds()
        
        onContentYChanged:
        {   

            if (updatingContentY || !control.flickable || !control.flickable.dragging)
            {
                oldContentY = control.flickable.contentY;
                return;
                //TODO: merge
                //if moves but not dragging, just update oldContentY
            } 
            
            if(control.flickable.contentHeight < control.height)
                return
            
            var oldFHeight
            var oldHHeight
           
               if (control.footer && control.footerPositioning === ListView.PullBackFooter)
                {
                    oldFHeight = control.footer.height                    
                    control.footer.height = Math.max(0,
                                                  Math.min(control.footer.implicitHeight,
                                                           control.footer.height + oldContentY - control.flickable.contentY));
                }
            
                
                   if (control.header && control.headerPositioning === ListView.PullBackHeader)
                    {
                        oldHHeight = control.header.height              
                        control.header.height = Math.max(0,
                                                      Math.min(control.header.implicitHeight,
                                                               control.header.height + oldContentY - control.flickable.contentY));               
                    }
                
            
            //if the implicitHeight is changed, use that to simulate scroll
            if ((control.footer && oldFHeight !== control.footer.height) || ( control.header && oldHHeight !== control.header.height))
            {
                updatingContentY = true

                if(control.header && oldHHeight !== control.header.height)
                    control.flickable.contentY -= (oldHHeight - control.header.height) 
                    updatingContentY = false   
            

                    
            } else {
                oldContentY = control.flickable.contentY
            }
        }
        
        onMovementEnded:
        {  
             

          
            
            if (control.headerPositioning === ListView.PullBackHeader  && control.header)
            {  
                    if (control.header.height >= (control.header.implicitHeight/2) || control.flickable.atYBeginning ) 
                    {
                        control.header.height =  control.header.implicitHeight
                        
                    } else 
                    {
                        control.header.height = 0
                    }
                
            }
            
            if (control.footerPositioning === ListView.PullBackFooter  && control.footer)
            {                
                if (control.footer.height >= (control.footer.implicitHeight/2) ||  control.flickable.atYEnd) 
                {
                    if(control.flickable.atYEnd)
                    {
                        control.footer.height =  control.footer.implicitHeight
                        
                        control.flickable.contentY = control.flickable.contentHeight - control.flickable.height
                        oldContentY = control.flickable.contentY
                    }else
                    {
                        control.footer.height =  control.footer.implicitHeight
                        
                    }
                    
                } else 
                {
                    control.footer.height = 0
                }                  
            }
        }
    }
    
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
            sourceComponent: control.title && control.showTitle ? _titleComponent : undefined
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
        onImplicitHeightChanged: height = implicitHeight
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

    
    function returnToBounds()
    {
        if(control.header)
                control.header.height = control.header.implicitHeight
                
                if(control.footer)
                control.footer.height = control.footer.implicitHeight
    }
}
