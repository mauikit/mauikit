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
#include "accounts-qml-module/src/account.h"

#include <QDebug>

KAccountsProvider::KAccountsProvider(QObject *parent) : AccountsProvider(parent)
{
    accountsModel = new OnlineAccounts::AccountServiceModel();
}

FMH::MODEL_LIST KAccountsProvider::getAccounts(QString service, bool includeDisabled)
{
    FMH::MODEL_LIST res;
    accountsModel->componentComplete();
    accountsModel->setService(service);
    accountsModel->setIncludeDisabled(includeDisabled);

    for (int i = 0; i<accountsModel->rowCount(); i++) {
        int row = accountsModel->index(i, 0).data().toInt();

        res << FMH::MODEL {
            {FMH::MODEL_KEY::ICON, "folder-cloud"},
            {FMH::MODEL_KEY::LABEL, accountsModel->get(row, accountsModel->roleNames()[OnlineAccounts::AccountServiceModel::Roles::DisplayNameRole]).toString()},
            {FMH::MODEL_KEY::ACCOUNT, accountsModel->get(row, accountsModel->roleNames()[OnlineAccounts::AccountServiceModel::Roles::AccountHandleRole]).toString()}
        };
    }

    return res;
}

bool KAccountsProvider::addAccount(const QString& server, const QString& user, const QString& password)
{
	return false;
}

bool KAccountsProvider::removeAccount(FMH::MODEL account)
{
    OnlineAccounts::Account _account;

    // FIXME : This setObjectHandle requires the objectHandle which is of type QObject*
    //         Since FMH::MODEL doesn't support QObject *, accounts cannot be removed yet
    //         See line 43, the data needs to be stored as an QObject.
    //_account.setObjectHandle(account[FMH::MODEL_KEY::ACCOUNT]);
    _account.remove();

	return false;
}


