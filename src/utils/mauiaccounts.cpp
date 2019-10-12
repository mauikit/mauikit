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

#include "utils/mauiaccounts.h"
#include "fm.h"

MauiAccounts::MauiAccounts(QObject *parent) : MauiList(parent), 
fm(new FM(this))
{
	this->setAccounts();
}

MauiAccounts::~MauiAccounts()
{
}

FMH::MODEL_LIST MauiAccounts::items() const
{
	return this->m_data;
}

void MauiAccounts::setAccounts()
{
	emit this->preListChanged();	
	this->m_data = this->fm->getCloudAccounts();
	qDebug()<< "ACCOUNTS LIST"<< this->m_data;	
	
	this->m_count = this->m_data.count();
	emit this->countChanged(this->m_count);
	emit this->postListChanged();
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
	
	if(this->fm->addCloudAccount(model[FMH::MODEL_KEY::SERVER], model[FMH::MODEL_KEY::USER], model[FMH::MODEL_KEY::PASSWORD]))
	{
		this->setAccounts();
	}	
}

void MauiAccounts::setCurrentAccountIndex(const int& index)
{
	if(index >= this->m_data.size() || index < 0)
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
	
	if(this->fm->removeCloudAccount(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]))
	{
		this->refresh();
	}
}

void MauiAccounts::removeAccountAndFiles(const int& index)
{
	if(index >= this->m_data.size() || index < 0)
		return;
	
	if(this->fm->removeCloudAccount(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]))
	{
		this->refresh();
	}	
	
    FM_STATIC::removeDir(FM::resolveUserCloudCachePath(this->m_data.at(index)[FMH::MODEL_KEY::SERVER], this->m_data.at(index)[FMH::MODEL_KEY::USER]));
}

