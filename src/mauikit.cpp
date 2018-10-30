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

#include "mauikit.h"

#include <QDebug>
#include <QQuickStyle>

#include "fm.h"
#include "fmh.h"

#include "fmmodel.h"
#include "fmlist.h"

#include "placeslist.h"
#include "placesmodel.h"

#include "handy.h"
#include "documenthandler.h"

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#include <QIcon>
#else
#include "mauikde.h"
#endif

QUrl MauiKit::componentUrl(const QString &fileName) const
{
#ifdef MAUI_APP
    return QUrl(QStringLiteral("qrc:/maui/kit/") + fileName);
#else
    return QUrl(resolveFileUrl(fileName));
#endif
}

void MauiKit::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.mauikit"));

#ifdef Q_OS_ANDROID
    QIcon::setThemeSearchPaths({":/icons/luv-icon-theme"});
    QIcon::setThemeName("Luv");
    QQuickStyle::setStyle(":/style");
#else
    QQuickStyle::setStyle("maui-style");
#endif

    qmlRegisterSingletonType(componentUrl(QStringLiteral("Style.qml")), uri, 1, 0, "Style");
    qmlRegisterType(componentUrl(QStringLiteral("ToolBar.qml")), uri, 1, 0, "ToolBar");
    qmlRegisterType(componentUrl(QStringLiteral("ToolButton.qml")), uri, 1, 0, "ToolButton");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationWindow.qml")), uri, 1, 0, "ApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("Page.qml")), uri, 1, 0, "Page");
    qmlRegisterType(componentUrl(QStringLiteral("ShareDialog.qml")), uri, 1, 0, "ShareDialog");
    qmlRegisterType(componentUrl(QStringLiteral("PieButton.qml")), uri, 1, 0, "PieButton");
    qmlRegisterType(componentUrl(QStringLiteral("SideBar.qml")), uri, 1, 0, "SideBar");
    qmlRegisterType(componentUrl(QStringLiteral("Holder.qml")), uri, 1, 0, "Holder");
    qmlRegisterType(componentUrl(QStringLiteral("Drawer.qml")), uri, 1, 0, "Drawer");
    qmlRegisterType(componentUrl(QStringLiteral("GlobalDrawer.qml")), uri, 1, 0, "GlobalDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("ListDelegate.qml")), uri, 1, 0, "ListDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("SelectionBar.qml")), uri, 1, 0, "SelectionBar");
    qmlRegisterType(componentUrl(QStringLiteral("IconDelegate.qml")), uri, 1, 0, "IconDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("LabelDelegate.qml")), uri, 1, 0, "LabelDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("NewDialog.qml")), uri, 1, 0, "NewDialog");
    qmlRegisterType(componentUrl(QStringLiteral("Dialog.qml")), uri, 1, 0, "Dialog");
    qmlRegisterType(componentUrl(QStringLiteral("Button.qml")), uri, 1, 0, "Button");
    qmlRegisterType(componentUrl(QStringLiteral("AboutDialog.qml")), uri, 1, 0, "AboutDialog");
    qmlRegisterType(componentUrl(QStringLiteral("Popup.qml")), uri, 1, 0, "Popup");
    qmlRegisterType(componentUrl(QStringLiteral("TextField.qml")), uri, 1, 0, "TextField");
    qmlRegisterType(componentUrl(QStringLiteral("SearchBar.qml")), uri, 1, 0, "SearchBar");
    qmlRegisterType(componentUrl(QStringLiteral("TagsBar.qml")), uri, 1, 0, "TagsBar");
	qmlRegisterType(componentUrl(QStringLiteral("Badge.qml")), uri, 1, 0, "Badge");
	qmlRegisterType(componentUrl(QStringLiteral("GridView.qml")), uri, 1, 0, "GridView");
	qmlRegisterType(componentUrl(QStringLiteral("Item.qml")), uri, 1, 0, "Item");
	qmlRegisterType(componentUrl(QStringLiteral("Menu.qml")), uri, 1, 0, "Menu");
	qmlRegisterType(componentUrl(QStringLiteral("MenuItem.qml")), uri, 1, 0, "MenuItem");
	qmlRegisterType(componentUrl(QStringLiteral("ColorsBar.qml")), uri, 1, 0, "ColorsBar");
	qmlRegisterType(componentUrl(QStringLiteral("private/TagList.qml")), uri, 1, 0, "TagList");

    /** BROWSING CONTROLS **/
	qmlRegisterType(componentUrl(QStringLiteral("ListBrowser.qml")), uri, 1, 0, "ListBrowser");
	qmlRegisterType(componentUrl(QStringLiteral("GridBrowser.qml")), uri, 1, 0, "GridBrowser");

    /** FM CONTROLS **/
	qmlRegisterType(componentUrl(QStringLiteral("FileBrowser.qml")), uri, 1, 0, "FileBrowser");
	qmlRegisterType(componentUrl(QStringLiteral("PlacesSidebar.qml")), uri, 1, 0, "PlacesSidebar");
	qmlRegisterType(componentUrl(QStringLiteral("FilePreviewer.qml")), uri, 1, 0, "FilePreviewer");
	qmlRegisterType(componentUrl(QStringLiteral("FileDialog.qml")), uri, 1, 0, "FileDialog");
    qmlRegisterType(componentUrl(QStringLiteral("PathBar.qml")), uri, 1, 0, "PathBar");
	
	/** EDITOR CONTROLS **/
	qmlRegisterType(componentUrl(QStringLiteral("Editor.qml")), uri, 1, 0, "Editor");
	
#ifdef Q_OS_ANDROID
	qmlRegisterType(componentUrl(QStringLiteral("SyncDialogA.qml")), uri, 1, 0, "SyncDialog");	
    qmlRegisterSingletonType<MAUIAndroid>(uri, 1, 0, "Android",
                                          [](QQmlEngine*, QJSEngine*) -> QObject* {
        MAUIAndroid *android = new MAUIAndroid;
        return android;
    });
#else
	qmlRegisterType(componentUrl(QStringLiteral("SyncDialog.qml")), uri, 1, 0, "SyncDialog");	
	qmlRegisterType(componentUrl(QStringLiteral("Terminal.qml")), uri, 1, 0, "Terminal");	
	
	qmlRegisterSingletonType<MAUIKDE>(uri, 1, 0, "KDE",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
        MAUIKDE *kde = new MAUIKDE;
        return kde;
    });
#endif
	
// 	qmlRegisterUncreatableMetaObject(FMH::staticMetaObject, "FMH", 1, 0, "KEY", "Error");	
	qmlRegisterType<PlacesList>("PlacesList", 1, 0, "PlacesList");
	qmlRegisterType<PlacesModel>("PlacesModel", 1, 0, "PlacesModel");
	qmlRegisterType<FMModel>("FMModel", 1, 0, "FMModel");
	qmlRegisterType<FMList>("FMList", 1, 0, "FMList");
	qmlRegisterType<DocumentHandler>("DocumentHandler", 1, 0, "DocumentHandler");
	
	qmlRegisterSingletonType<FM>(uri, 1, 0, "FM",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
		auto fm = FM::getInstance();
        return fm;
    });
    
     qmlRegisterSingletonType<Handy>(uri, 1, 0, "Handy",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
       auto handy = new Handy;
        return handy;
    });

    qmlProtectModule(uri, 1);
}

