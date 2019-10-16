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
#include "sqliteprovider.h"

#include "accountsdb.h"

SQLiteProvider::SQLiteProvider(QObject* parent) : AccountsProvider(parent),
db(new AccountsDB(parent))
{}

FMH::MODEL_LIST SQLiteProvider::getAccounts(QString service, bool includeDisabled)
{
	auto accounts = this->get("select * from cloud");
	FMH::MODEL_LIST res;
	for(const auto &account : accounts)
	{
		auto map = account.toMap();
		res << FMH::MODEL {
			{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::ICON, "folder-cloud"},
			{FMH::MODEL_KEY::LABEL, map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::USER, map[FMH::MODEL_NAME[FMH::MODEL_KEY::USER]].toString()},
			{FMH::MODEL_KEY::SERVER, map[FMH::MODEL_NAME[FMH::MODEL_KEY::SERVER]].toString()},
			{FMH::MODEL_KEY::PASSWORD, map[FMH::MODEL_NAME[FMH::MODEL_KEY::PASSWORD]].toString()},
			{FMH::MODEL_KEY::TYPE,  FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::CLOUD_PATH]}};
	}
	
	return res;
}


QVariantList SQLiteProvider::get(const QString &queryTxt)
{
	QVariantList mapList;
	
	auto query = this->db->getQuery(queryTxt);
	
	if(query.exec())
	{
		while(query.next())
		{
			QVariantMap data;
			for(auto key : FMH::MODEL_NAME.keys())
				if(query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
					data[FMH::MODEL_NAME[key]] = query.value(FMH::MODEL_NAME[key]).toString();
				
				mapList<< data;
			
		}
		
	}else qDebug()<< query.lastError()<< query.lastQuery();
	
	return mapList;
}

bool SQLiteProvider::addAccount(const QString &server, const QString &user, const QString &password)
{
	const QVariantMap account = {
		{FMH::MODEL_NAME[FMH::MODEL_KEY::SERVER], server},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::USER], user},
		{FMH::MODEL_NAME[FMH::MODEL_KEY::PASSWORD], password}
	};
	
	if(this->db->insert("cloud", account))
	{
		emit this->accountAdded(account);
		return true;
	}
	
	return false;
}

bool SQLiteProvider::removeAccount(const QString &server, const QString &user)
{
	FMH::MODEL account = {
		{FMH::MODEL_KEY::SERVER, server},
		{FMH::MODEL_KEY::USER, user},
	};
	
	if(this->db->remove("cloud", account))
	{
		emit this->accountRemoved(FMH::toMap(account));
		return true;
	}
	
	return false;
}
