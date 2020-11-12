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

pragma Singleton

import QtQuick 2.14
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

/**
 * Style
 * A global sidebar for the application window that can be collapsed.
 *
 *
 *
 *
 *
 *
 */
QtObject
{
    id: style
    
    /**
     * 
     */
    readonly property bool isAndroid: Qt.platform.os == "android" //TODO remove
    
    /**
     * 
     */
    readonly property bool isMobile : Kirigami.Settings.isMobile //TODO remove
    
    /**
     * unit : int
     */
    property int unit : Kirigami.Units.devicePixelRatio
    
    /**
     * radiusV : int
     */
    property int radiusV : Maui.Handy.isWindows ? 2 : 4
    
    /**
     * rowHeight : int
     */
    readonly property int rowHeight: Math.round(iconSizes.big)
    
    /**
     * rowHeightAlt : int
     */
    readonly property int rowHeightAlt: Math.round(rowHeight * 0.8)
    
    /**
     * contentMargins : int
     */
    readonly property int contentMargins: space.medium
    
    /**
     * toolBarHeight : int
     */
    readonly property int toolBarHeight: Math.round(iconSizes.medium * 2) * unit
    
    /**
     * toolBarHeightAlt : int
     */
    readonly property int toolBarHeightAlt: Math.round(toolBarHeight * 0.9)
    
    /**
     * defaultFontSize : int
     */
    readonly property int defaultFontSize: Kirigami.Theme.defaultFont.pointSize
    
    /**
     * fontSizes : var
     */
    readonly property var fontSizes: ({
        tiny: Math.round(defaultFontSize * 0.7),
                                      
                                      small: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 0.7 :
                                      defaultFontSize * 0.8),
                                      
                                      medium: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 0.8 :
                                      defaultFontSize * 0.9),
                                      
                                      default: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 0.9 :
                                          defaultFontSize),
                                      
                                      big: Math.round(Maui.Handy.isAndroid ? defaultFontSize :
                                      defaultFontSize * 1.1),
                                      
                                      large: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 1.1 :
                                      defaultFontSize * 1.2),
                                      
                                      huge: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 1.2 :
                                      defaultFontSize * 1.3),
                                      
                                      enormous: Math.round(Maui.Handy.isAndroid ? defaultFontSize * 1.3 :
                                      defaultFontSize * 1.4)
    })
    
    /**
     * space : var
     */
    readonly property var space : ({
        tiny: Kirigami.Units.smallSpacing,
        small: Kirigami.Units.smallSpacing*2,
        medium: Kirigami.Units.largeSpacing,
        big: Kirigami.Units.largeSpacing*2,
        large: Kirigami.Units.largeSpacing*3,
        huge: Kirigami.Units.largeSpacing*4,
        enormous: Kirigami.Units.largeSpacing*5
    })
    
    /**
     * iconSizes : var
     */
    readonly property var iconSizes : ({
        tiny : 8,
        small :  Kirigami.Units.iconSizes.small / (isMobile ? 1.5 : 1),
                                       medium : Kirigami.Units.iconSizes.smallMedium / (isMobile ? 1.5 : 1),
                                       big:  Kirigami.Units.iconSizes.medium / (isMobile ? 1.5 : 1),
                                       large: Kirigami.Units.iconSizes.large / (isMobile ? 1.5 : 1),
                                       huge: Kirigami.Units.iconSizes.huge / (isMobile ? 1.5 : 1),
                                       enormous: Kirigami.Units.iconSizes.enormous / (isMobile ? 1.5 : 1)
    })
    
    /**
     * 
     */
    function mapToIconSizes(size)
    {
        const values = Object.values(iconSizes);
        
        var closest = values.reduce(function(prev, curr) {
            return (Math.abs(curr - size) < Math.abs(prev - size) ? curr : prev);
        });
        console.log(size, closest, values)
        return closest;
    }
}
