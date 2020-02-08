/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "mauiaccounts.h"
#include "accountsdb.h"

MauiAccounts::MauiAccounts() : MauiList(nullptr), 
db(new AccountsDB(nullptr))
{
	this->setAccounts();
}

MauiAccounts::~MauiAccounts()
{
	qDebug() << "DELETING MAUI ACCOUNTS INSTANCE";
	this->db->deleteLater();
	this->db = nullptr;
}

FMH::MODEL_LIST MauiAccounts::items() const
{
	return this->m_data;
}

void MauiAccounts::setAccounts()
{
	emit this->preListChanged();	
    this->m_data = this->getCloudAccounts();
	qDebug()<< "ACCOUNTS LIST"<< this->m_data;	
	
	this->m_count = this->m_data.count();
	emit this->countChanged(this->m_count);
    emit this->postListChanged();
}

FMH::MODEL_LIST MauiAccounts::getCloudAccounts()
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

bool MauiAccounts::addCloudAccount(const QString &server, const QString &user, const QString &password)
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

bool MauiAccounts::removeCloudAccount(const QString &server, const QString &user)
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

QVariantList MauiAccounts::get(const QString &queryTxt)
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

int MauiAccounts::getCurrentAccountIndex() const
{
	return this->m_currentAccountIndex;
}

QVariantMap MauiAccounts::getCurrentAccount() const
{
	return this->m_currentAccount;
}

void MauiAccounts::registerAccount(const QVariantMap& account)
{
	// register the account to the backend needed
	auto model = FMH::toModel(account);	

    if(this->addCloudAccount(model[FMH::MODEL_KEY::SERVER], model[FMH::MODEL_KEY::USER], model[FMH::MODEL_KEY::PASSWORD]))
	{
		this->setAccounts();
	}	
}

void MauiAccounts::setCurrentAccountIndex(const int& index)
{
	if(index >= this->m_data.size() || index < 0)
		return;	
	
	if(index == this->m_currentAccountIndex)
		return;	

	//make sure the account exists
	this->m_currentAccountIndex = index;	
	this->m_currentAccount = FMH::toMap(this->m_data.at(m_currentAccountIndex));
	
	emit this->currentAccountChanged(this->m_currentAccount);
	emit this->currentAccountIndexChanged(this->m_currentAccountIndex);
}

QVariantMap MauiAccounts::get(const int& index) const
{
	if(index >= this->m_data.size() || index < 0)
		return QVariantMap();	
    return FMH::toMap(this->m_data.at(index));
}

QVariantList MauiAccounts::getCloudAccountsList()
{
    QVariantList res;

    const auto data = this->getCloudAccounts();
    for(const auto &item : data)
        res << FMH::toMap(item);

    return res;
}

uint MauiAccounts::getCount() const
{
	return this->m_count;
}

void MauiAccounts::refresh()
{
	this->setAccounts();
}

void MauiAccounts::removeAccount(const int& index)
{
	if(index >= this->m_data.size() || index < 0)
		return;
	
    if(this->removeCloudAccount(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]))
	{
		this->refresh();
	}
}

void MauiAccounts::removeAccountAndFiles(const int& index)
{
	if(index >= this->m_data.size() || index < 0)
		return;
	
    if(this->removeCloudAccount(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]))
	{
		this->refresh();
	}	
	
//    FM_STATIC::removeDir(FM::resolveUserCloudCachePath(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]));
}

