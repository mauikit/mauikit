/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#include "mauikde.h"
#include <KService>
#include <KMimeTypeTrader>
#include <KToolInvocation>
#include <KLocalizedString>
#include <QDebug>
#include <KRun>
#include <QFileInfo>
#include <KService>
#include <KServiceGroup>
#include <QDebug>
#include <KFileItem>
#include <KColorScheme>
#include <KColorSchemeManager>
#include <QModelIndex>

#include "kdeconnect.h"

MAUIKDE::MAUIKDE(QObject *parent) : QObject(parent) {}

MAUIKDE::~MAUIKDE()
{

}

static QVariantMap createActionItem(const QString &label, const QString &actionId, const QVariant &argument = QVariant())
{
    QVariantMap map;

    map["label"] = label;
    map["actionId"] = actionId;

    if (argument.isValid())
        map["actionArgument"] = argument;


    return map;
}

QVariantList MAUIKDE::services(const QUrl &url)
{
    qDebug()<<"trying to get mimes";
    QVariantList list;

    if (url.isValid())
    {
        auto fileItem = new KFileItem(url);
        fileItem->determineMimeType();

        KService::List services = KMimeTypeTrader::self()->query(fileItem->mimetype(), "Application");

        if (!services.isEmpty())
            foreach (const KService::Ptr service, services)
            {
                const QString text = service->name().replace('&', "&&");
                QVariantMap item = createActionItem(text, "_kicker_fileItem_openWith", service->entryPath());
                item["icon"] = service->icon();
                item["serviceExec"] = service->exec();

                list << item;
            }


        list << createActionItem(i18n("Properties"), "_kicker_fileItem_properties");

        return list;
    } else return list;
}

bool MAUIKDE::sendToDevice(const QString &device, const QString &id, const QStringList &urls)
{
    for(auto url : urls)
        KdeConnect::sendToDevice(device, id, url);

    return true;
}

QVariantList MAUIKDE::devices()
{
    return KdeConnect::getDevices();
}

void MAUIKDE::openWithApp(const QString &exec, const QStringList &urls)
{
    KService service(exec);
    KRun::runApplication(service, QUrl::fromStringList(urls), nullptr);
}

void MAUIKDE::attachEmail(const QStringList &urls)
{
    if(urls.isEmpty()) return;

    QFileInfo file(urls[0]);

    KToolInvocation::invokeMailer("", "", "", file.baseName(), "Files shared... ", "", urls);
    //    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
    //    + url));
}

void MAUIKDE::setColorScheme(const QString &schemeName)
{
    KColorSchemeManager manager;
    manager.activateScheme(manager.indexForScheme(schemeName));
}

