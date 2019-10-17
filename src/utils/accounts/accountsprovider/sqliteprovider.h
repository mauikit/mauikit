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


#ifndef ACCOUNTSPROVIDER_SQLITEPROVIDER_H
#define ACCOUNTSPROVIDER_SQLITEPROVIDER_H

#include <QObject>
#include "accountsprovider.h"
#include "fmh.h"

class AccountsDB; 
class SQLiteProvider : public AccountsProvider
{
	Q_OBJECT
	
public:
	explicit SQLiteProvider(QObject *parent = nullptr);	
	FMH::MODEL_LIST getAccounts(QString service, bool includeDisabled=false) override final;	
	
	bool addAccount(const QString &server, const QString &user, const QString &password) override final;
	bool removeAccount(const QString &server, const QString &user) override final;
	
private:
	AccountsDB *db;
	
	QVariantList get(const QString &queryTxt);
	
	
};

#endif
