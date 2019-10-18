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

#ifndef ACCOUNTSPROVIDER_KACCOUNTSPROVIDER_H
#define ACCOUNTSPROVIDER_KACCOUNTSPROVIDER_H

#include "accountsprovider.h"
#include "accounts-qml-module/src/account-service-model.h"

#include <QAbstractListModel>
#include <QQmlParserStatus>
#include <QString>
#include <QList>
#include <QObject>
#include <QPointer>
#include <QVariantMap>

class KAccountsProvider : public AccountsProvider {
    Q_OBJECT
public:
    KAccountsProvider(QObject* parent = nullptr);
	FMH::MODEL_LIST getAccounts(QString service, bool includeDisabled = false) override final;

	bool addAccount(const QString &server, const QString &user, const QString &password) override final;
    bool removeAccount(FMH::MODEL account) override final;

private:
    OnlineAccounts::AccountServiceModel *accountsModel;
};

#endif

