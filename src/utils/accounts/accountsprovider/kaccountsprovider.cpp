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
    accountHandlesMap = new QMap<QString, QObject *>();
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
            {FMH::MODEL_KEY::ID, accountsModel->get(row, accountsModel->roleNames()[OnlineAccounts::AccountServiceModel::Roles::AccountIdRole]).toString()}
        };

        accountHandlesMap->insert(
            accountsModel->get(row, accountsModel->roleNames()[OnlineAccounts::AccountServiceModel::Roles::AccountIdRole]).toString(),
            qvariant_cast<QObject*>(accountsModel->get(row, accountsModel->roleNames()[OnlineAccounts::AccountServiceModel::Roles::AccountHandleRole]))
        );
    }

    return res;
}

bool KAccountsProvider::addAccount(const QString& server, const QString& user, const QString& password)
{
    Q_UNUSED(server)
    Q_UNUSED(user)
    Q_UNUSED(password)

    // NOTE : The system() call is not made in another thread and is intentionally blocking UI
    //        because the running application should wait until the account is added to system.
    system("kcmshell5 kcm_kaccounts");

    return true;
}

bool KAccountsProvider::removeAccount(FMH::MODEL account)
{
    OnlineAccounts::Account _account;

    _account.setObjectHandle(accountHandlesMap->value(account[FMH::MODEL_KEY::ID]));
    _account.remove();

    emit this->accountRemoved(FMH::toMap(account));
    return true;
}


