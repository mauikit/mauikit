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
import org.kde.kirigami 2.0 as Kirigami


QtObject
{
    id: style
    readonly property bool isAndroid: Qt.platform.os == "android"
    readonly property bool isMobile : Kirigami.Settings.isMobile

    property color warningColor : "#FFB300"
    property color dangerColor : "#D81B60"
    property color infoColor : "#4caf50"
    property color suggestedColor : "#039BE5"

    property int unit : Kirigami.Units.devicePixelRatio

    property color borderColor: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
    property color backgroundColor: Kirigami.Theme.backgroundColor
    property color textColor: Kirigami.Theme.textColor
    property color highlightColor: Kirigami.Theme.highlightColor
    property color highlightedTextColor: Kirigami.Theme.highlightedTextColor
    property color buttonBackgroundColor: isAndroid ? Qt.lighter(Kirigami.Theme.buttonBackgroundColor, 1.07) :  Kirigami.Theme.buttonBackgroundColor
    property color viewBackgroundColor: Kirigami.Theme.viewBackgroundColor
    property color altColor: Kirigami.Theme.complementaryBackgroundColor
    property color altColorText: Kirigami.Theme.complementaryTextColor



    readonly property int rowHeight: Kirigami.Units.iconSizes.medium + space.medium
    readonly property int rowHeightAlt: rowHeight * 0.8

    readonly property int toolBarHeight: (Kirigami.Units.iconSizes.medium * (isMobile ? 1 : 1.5)) /*+  space.tiny*/
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
                                                                               defaultFontSize * 1.3)
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
                                           tiny : Kirigami.Units.iconSizes.small*0.5,

                                           small :  (isMobile ? Kirigami.Units.iconSizes.small*0.5:
                                                                                  Kirigami.Units.iconSizes.small),

                                           medium : (isMobile ? Kirigami.Units.iconSizes.small :
                                                                                  Kirigami.Units.iconSizes.smallMedium),

                                           big:  (isMobile ? Kirigami.Units.iconSizes.smallMedium :
                                                                               Kirigami.Units.iconSizes.medium),

                                           large: (isMobile ? Kirigami.Units.iconSizes.medium :
                                                                                Kirigami.Units.iconSizes.large),

                                           huge: (isMobile ? Kirigami.Units.iconSizes.large :
                                                                               Kirigami.Units.iconSizes.huge),

                                           enormous: (isMobile ? Kirigami.Units.iconSizes.huge :
                                                                                   Kirigami.Units.iconSizes.enormous)

                                       })
}
