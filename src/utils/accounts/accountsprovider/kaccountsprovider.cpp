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
#include <Accounts/Account>
#include <Accounts/AccountService>
#include <Accounts/Application>
#include <Accounts/Manager>

#include <QDebug>

KAccountsProvider::KAccountsProvider(QObject *parent) : AccountsProvider(parent)
{
}

FMH::MODEL_LIST KAccountsProvider::getAccounts(QString service, bool includeDisabled)
{


    qDebug() << "###";
	
	auto manager = new Accounts::Manager();
	QList<Accounts::Account *> accounts;
	
		foreach (Accounts::AccountId accountId, manager->accountList()) {
			Accounts::Account *account = manager->account(accountId);
			accounts.append(account);
		}
	


	qDebug() << accounts.size() << accounts;

//    while (count > 0) {
//        QString roleName;


//        count--;
//    }

    qDebug() << "###";

	return FMH::MODEL_LIST();
}

bool KAccountsProvider::addAccount(const QString& server, const QString& user, const QString& password)
{
	return false;
}

bool KAccountsProvider::removeAccount(const QString& server, const QString& user)
{
	return false;
}


