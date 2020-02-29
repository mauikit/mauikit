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

import QtQml 2.1
import org.kde.mauikit 1.0 as Maui

QtObject 
{
    property var filters : []
    property int filterType : Maui.FMList.NONE
    property bool onlyDirs : false
    property int sortBy : Maui.FM.loadSettings("SortBy", "SETTINGS", Maui.FMList.LABEL)
    property bool trackChanges : false
    property bool saveDirProps : false 
    property bool showThumbnails: true
    property bool showHiddenFiles: false
    property bool group : false
    property int viewType : 0    
}

