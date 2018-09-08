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


#include "notify.h"

Notify::Notify(QObject *parent) : QObject(parent)
{}

Notify::~Notify()
{
    qDebug()<<"DELETING KNOTIFY";
}

void Notify::notify(const QString &title, const QString &body)
{
    // notification->setComponentName(QStringLiteral("Babe"));
    auto notification = new KNotification(QStringLiteral("Notify"),KNotification::CloseOnTimeout, this);
    connect(notification, &KNotification::closed, notification, &KNotification::deleteLater);
    notification->setTitle(QStringLiteral("%1").arg(title));
    notification->setText(QStringLiteral("%1").arg(body));
    notification->sendEvent();
}
