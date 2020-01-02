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

#include "handy.h"
#include "mauimodel.h"
#include "mauilist.h"
#include "pathlist.h"
#include "mauiapp.h"
#include "fmstatic.h"

#ifdef COMPONENT_ACCOUNTS
#include "mauiaccounts.h"
#endif

#ifdef COMPONENT_FM
#include "fm.h"
#include "placeslist.h"
#include "fmlist.h"
#endif

#ifdef COMPONENT_TAGGING
#include "tagsmodel.h"
#include "tagslist.h"
#endif

#ifdef COMPONENT_STORE
#include "storemodel.h"
#include "storelist.h"
#endif

#ifdef COMPONENT_EDITOR
#include "documenthandler.h"
#include "syntaxhighlighterutil.h"
#include "kquicksyntaxhighlighter/kquicksyntaxhighlighter.h"
#endif

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#elif defined Q_OS_LINUX
#include "mauikde.h"
#endif

#if defined MAUIKIT_STYLE
#include <QIcon>
#include <QQuickStyle>
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

    qmlRegisterSingletonType(componentUrl(QStringLiteral("Style.qml")), uri, 1, 0, "Style");
    qmlRegisterType(componentUrl(QStringLiteral("ToolBar.qml")), uri, 1, 0, "ToolBar");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationWindow.qml")), uri, 1, 0, "ApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("Page.qml")), uri, 1, 0, "Page");
    qmlRegisterType(componentUrl(QStringLiteral("ShareDialog.qml")), uri, 1, 0, "ShareDialog");
    qmlRegisterType(componentUrl(QStringLiteral("PieButton.qml")), uri, 1, 0, "PieButton");
    qmlRegisterType(componentUrl(QStringLiteral("SideBar.qml")), uri, 1, 0, "SideBar");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractSideBar.qml")), uri, 1, 0, "AbstractSideBar");
    qmlRegisterType(componentUrl(QStringLiteral("Holder.qml")), uri, 1, 0, "Holder");
    qmlRegisterType(componentUrl(QStringLiteral("GlobalDrawer.qml")), uri, 1, 0, "GlobalDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("ListDelegate.qml")), uri, 1, 0, "ListDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("ListBrowserDelegate.qml")), uri, 1, 0, "ListBrowserDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("SwipeItemDelegate.qml")), uri, 1, 0, "SwipeItemDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("SwipeBrowserDelegate.qml")), uri, 1, 0, "SwipeBrowserDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("ItemDelegate.qml")), uri, 1, 0, "ItemDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("GridBrowserDelegate.qml")), uri, 1, 0, "GridBrowserDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("SelectionBar.qml")), uri, 1, 0, "SelectionBar");
    qmlRegisterType(componentUrl(QStringLiteral("LabelDelegate.qml")), uri, 1, 0, "LabelDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("NewDialog.qml")), uri, 1, 0, "NewDialog");
    qmlRegisterType(componentUrl(QStringLiteral("Dialog.qml")), uri, 1, 0, "Dialog");
    qmlRegisterType(componentUrl(QStringLiteral("AboutDialog.qml")), uri, 1, 0, "AboutDialog");
    qmlRegisterType(componentUrl(QStringLiteral("Popup.qml")), uri, 1, 0, "Popup");
    qmlRegisterType(componentUrl(QStringLiteral("TextField.qml")), uri, 1, 0, "TextField");
    qmlRegisterType(componentUrl(QStringLiteral("Badge.qml")), uri, 1, 0, "Badge");
    qmlRegisterType(componentUrl(QStringLiteral("GridView.qml")), uri, 1, 0, "GridView");
    qmlRegisterType(componentUrl(QStringLiteral("ColorsBar.qml")), uri, 1, 0, "ColorsBar");
    qmlRegisterType(componentUrl(QStringLiteral("ImageViewer.qml")), uri, 1, 0, "ImageViewer");
    qmlRegisterType(componentUrl(QStringLiteral("TabBar.qml")), uri, 1, 0, "TabBar");
    qmlRegisterType(componentUrl(QStringLiteral("TabButton.qml")), uri, 1, 0, "TabButton");
    qmlRegisterType(componentUrl(QStringLiteral("ActionGroup.qml")), uri, 1, 0, "ActionGroup");
    qmlRegisterType(componentUrl(QStringLiteral("ActionSideBar.qml")), uri, 1, 0, "ActionSideBar");
    qmlRegisterType(componentUrl(QStringLiteral("ToolActions.qml")), uri, 1, 0, "ToolActions");
    qmlRegisterType(componentUrl(QStringLiteral("ToolButtonMenu.qml")), uri, 1, 0, "ToolButtonMenu");
    qmlRegisterType(componentUrl(QStringLiteral("ListItemTemplate.qml")), uri, 1, 0, "ListItemTemplate");
    qmlRegisterType(componentUrl(QStringLiteral("GridItemTemplate.qml")), uri, 1, 0, "GridItemTemplate");

    qmlRegisterType(componentUrl(QStringLiteral("FloatingButton.qml")), uri, 1, 0, "FloatingButton");

    qmlRegisterType(componentUrl(QStringLiteral("PathBar.qml")), uri, 1, 0, "PathBar");
    qmlRegisterType<PathList>(uri, 1, 0, "PathList");
    
    /** 1.1 **/
    qmlRegisterType(componentUrl(QStringLiteral("labs/SelectionBar.qml")), uri, 1, 1, "SelectionBar");


    /** STORE CONTROLS, MODELS AND INTERFACES **/
#ifdef COMPONENT_STORE
    qmlRegisterType<StoreList>("StoreList", 1, 0, "StoreList");
    qmlRegisterType<StoreModel>("StoreModel", 1, 0, "StoreModel");
    qmlRegisterType(componentUrl(QStringLiteral("private/StoreDelegate.qml")), uri, 1, 0, "StoreDelegate");
    qmlRegisterType(componentUrl(QStringLiteral("Store.qml")), uri, 1, 0, "Store");
#endif

    /** BROWSING CONTROLS **/
    qmlRegisterType(componentUrl(QStringLiteral("ListBrowser.qml")), uri, 1, 0, "ListBrowser");
    qmlRegisterType(componentUrl(QStringLiteral("GridBrowser.qml")), uri, 1, 0, "GridBrowser");

    /** FM CONTROLS, MODELS AND INTERFACES **/
#ifdef COMPONENT_FM
    qmlRegisterType<PlacesList>(uri, 1, 0, "PlacesList");
    qmlRegisterType<FMList>(uri, 1, 0, "FMList");
    qmlRegisterSingletonType<FMStatic>(uri, 1, 0, "FM",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new FMStatic;
    });

    qmlRegisterType(componentUrl(QStringLiteral("FileBrowser.qml")), uri, 1, 0, "FileBrowser");
    qmlRegisterType(componentUrl(QStringLiteral("PlacesSidebar.qml")), uri, 1, 0, "PlacesSidebar");
    qmlRegisterType(componentUrl(QStringLiteral("PlacesListBrowser.qml")), uri, 1, 0, "PlacesListBrowser");
    qmlRegisterType(componentUrl(QStringLiteral("FilePreviewer.qml")), uri, 1, 0, "FilePreviewer");
    qmlRegisterType(componentUrl(QStringLiteral("FileDialog.qml")), uri, 1, 0, "FileDialog");
#endif

#ifdef COMPONENT_EDITOR	
    /** EDITOR CONTROLS **/
    qmlRegisterType<DocumentHandler>(uri, 1, 0, "DocumentHandler");
    qmlRegisterType<SyntaxHighlighterUtil>();
    qmlRegisterType(componentUrl(QStringLiteral("Editor.qml")), uri, 1, 0, "Editor");
    qmlRegisterType(componentUrl(QStringLiteral("private/DocumentPreview.qml")), uri, 1, 0, "DocumentPreview");
    qmlRegisterType<KQuickSyntaxHighlighter>("org.maui.kquicksyntaxhighlighter", 0, 1, "KQuickSyntaxHighlighter");
#endif 

    /** PLATFORMS SPECIFIC CONTROLS **/
#ifdef Q_OS_ANDROID
    qmlRegisterSingletonType<MAUIAndroid>(uri, 1, 0, "Android",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new MAUIAndroid;
    });
#elif defined Q_OS_LINUX
    qmlRegisterType(componentUrl(QStringLiteral("Terminal.qml")), uri, 1, 0, "Terminal");
    qmlRegisterSingletonType<MAUIKDE>(uri, 1, 0, "KDE",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new MAUIKDE;
    });
#elif defined Q_OS_WIN32
    //here window platform integration interfaces
#endif

    /** DATA MODELING TEMPLATED INTERFACES **/
    qmlRegisterType<MauiList>(); //ABSTRACT BASE LIST
    qmlRegisterType<MauiModel>(uri, 1, 0, "BaseModel"); //BASE MODEL

    /** TAGGING INTERFACES AND MODELS **/
    qmlRegisterType<TagsList>("TagsList", 1, 0, "TagsList");
    qmlRegisterType<TagsModel>("TagsModel", 1, 0, "TagsModel");
    qmlRegisterType(componentUrl(QStringLiteral("private/TagList.qml")), uri, 1, 0, "TagList");
    qmlRegisterType(componentUrl(QStringLiteral("TagsBar.qml")), uri, 1, 0, "TagsBar");
    qmlRegisterType(componentUrl(QStringLiteral("TagsDialog.qml")), uri, 1, 0, "TagsDialog");

    /** MAUI APPLICATION SPECIFIC PROPS **/

#ifdef COMPONENT_ACCOUNTS
    qmlRegisterType<MauiAccounts>();
    qmlRegisterType(componentUrl(QStringLiteral("SyncDialog.qml")), uri, 1, 0, "SyncDialog"); //to be rename to accountsDialog
#endif
    qmlRegisterUncreatableType<MauiApp>(uri, 1, 0, "App", "Cannot be created App");

    /** HELPERS **/
    qmlRegisterSingletonType<Handy>(uri, 1, 0, "Handy",
                                    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new Handy;
    });

#if defined MAUIKIT_STYLE
    this->initResources();
#endif

    qmlProtectModule(uri, 1);
}

void MauiKit::initResources()
{
#if defined QICON_H && defined QQUICKSTYLE_H
    Q_INIT_RESOURCE(mauikit);
#ifdef ICONS_PNG
    Q_INIT_RESOURCE(icons_png);
#else
    Q_INIT_RESOURCE(icons);
#endif
    Q_INIT_RESOURCE(style);
    QIcon::setThemeSearchPaths({":/icons/luv-icon-theme"});
    QIcon::setThemeName("Luv");
    QQuickStyle::setStyle(":/style");
#endif
}

//#include "moc_mauikit.cpp"
