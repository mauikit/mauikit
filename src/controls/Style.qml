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

import QtQuick 2.4
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

QtObject
{
	id: style
	readonly property bool isAndroid: Qt.platform.os == "android"
	readonly property bool isMobile : Kirigami.Settings.isMobile

	property int unit : Kirigami.Units.devicePixelRatio
    property int radiusV : Maui.Handy.isWindows ? 2 : 4
	
	readonly property int rowHeight: iconSizes.big * 0.95
	readonly property int rowHeightAlt: rowHeight * 0.8
	readonly property int contentMargins: space.medium
	
    readonly property int toolBarHeight: (iconSizes.medium * 2)
	readonly property int toolBarHeightAlt: toolBarHeight * 0.9
	
	readonly property int defaultFontSize: Kirigami.Theme.defaultFont.pointSize
	readonly property var fontSizes: ({
		tiny: defaultFontSize * 0.7,
		
		small: (isMobile ? defaultFontSize * 0.7 :
		defaultFontSize * 0.8),
		
		medium: (isMobile ? defaultFontSize * 0.8 :
		defaultFontSize * 0.9),
		
		default: (isMobile ? defaultFontSize * 0.9 :
			defaultFontSize),
			
			big: (isMobile ? defaultFontSize :
			defaultFontSize * 1.1),
			
			large: (isMobile ? defaultFontSize * 1.1 :
			defaultFontSize * 1.2),
			
			huge: (isMobile ? defaultFontSize * 1.2 :
			defaultFontSize * 1.3),
			
			enormous: (isMobile ? defaultFontSize * 1.3 :
			defaultFontSize * 1.4)
	})
	
	readonly property var space : ({
		tiny: Kirigami.Units.smallSpacing,
		small: Kirigami.Units.smallSpacing*2,
		medium: Kirigami.Units.largeSpacing,
		big: Kirigami.Units.largeSpacing*2,
		large: Kirigami.Units.largeSpacing*3,
		huge: Kirigami.Units.largeSpacing*4,
		enormous: Kirigami.Units.largeSpacing*5
	})
	
	readonly property var iconSizes : ({
		tiny : 8,
        small :  Kirigami.Units.iconSizes.small / (isMobile ? 1.5 : 1),
        medium : Kirigami.Units.iconSizes.smallMedium / (isMobile ? 1.5 : 1),
        big:  Kirigami.Units.iconSizes.medium / (isMobile ? 1.5 : 1),
        large: Kirigami.Units.iconSizes.large / (isMobile ? 1.5 : 1),
        huge: Kirigami.Units.iconSizes.huge / (isMobile ? 1.5 : 1),
        enormous: Kirigami.Units.iconSizes.enormous / (isMobile ? 1.5 : 1)		
	})	
    
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
