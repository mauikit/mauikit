/*
 *   Copyright 2019 Camilo Higuita <milo.h@aol.com> and Anupam Basak <anupam.basak27@gmail.com>
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

#include "kaccountsprovider.h"

#include <QDebug>

KAccountsProvider::KAccountsProvider(QObject *parent) : AccountsProvider(parent)
{
    accountsModel = new OnlineAccounts::AccountServiceModel();
}

QVariant KAccountsProvider::getAccounts(QString service, bool includeDisabled)
{
	accountsModel->componentComplete();
	accountsModel->setService(service);
	accountsModel->setIncludeDisabled(includeDisabled);

    QVector<int> v;

    const int nbRow = accountsModel->rowCount();
    v.reserve(nbRow);

    qDebug() << "###";
    qDebug() << nbRow;

    for (int i = 0; i < nbRow; ++i)
    {
        int row = accountsModel->index(i, 0).data().toInt();
        QVariant account = accountsModel->get(row, "displayName");

        qDebug() << account;
    }

//    qDebug() << count;

//    while (count > 0) {
//        QString roleName;


//        count--;
//    }

    qDebug() << "###";

    return QVariant();
}
