#include "mauikit.h"

#include <QDebug>
#include <QQuickStyle>
#include "fm.h"

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
    const QString style = QQuickStyle::name();

#ifdef Q_OS_ANDROID
    QIcon::setThemeSearchPaths({":/icons/luv-icon-theme"});
    QIcon::setThemeName("Luv");
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
    qmlRegisterType(componentUrl(QStringLiteral("TagsBar.qml")), uri, 1, 0, "TagsBar");
    qmlRegisterType(componentUrl(QStringLiteral("private/TagList.qml")), uri, 1, 0, "TagList");

    /** BROWSING CONTROLS **/
    qmlRegisterType(componentUrl(QStringLiteral("ListBrowser.qml")), uri, 1, 0, "ListBrowser");
    qmlRegisterType(componentUrl(QStringLiteral("GridBrowser.qml")), uri, 1, 0, "GridBrowser");

    /** FM CONTROLS **/
    qmlRegisterType(componentUrl(QStringLiteral("FileDialog.qml")), uri, 1, 0, "FileDialog");
    qmlRegisterType(componentUrl(QStringLiteral("PathBar.qml")), uri, 1, 0, "PathBar");


#ifdef Q_OS_ANDROID
    qmlRegisterSingletonType<MAUIAndroid>(uri, 1, 0, "Android",
                                          [](QQmlEngine*, QJSEngine*) -> QObject* {
        MAUIAndroid *android = new MAUIAndroid;
        return android;
    });
#else
    qmlRegisterSingletonType<MAUIKDE>(uri, 1, 0, "KDE",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
        MAUIKDE *kde = new MAUIKDE;
        return kde;
    });
#endif

    qmlRegisterSingletonType<FM>(uri, 1, 0, "FM",
                                      [](QQmlEngine*, QJSEngine*) -> QObject* {
       auto fm = new FM;
        return fm;
    });

    qmlProtectModule(uri, 1);
}

