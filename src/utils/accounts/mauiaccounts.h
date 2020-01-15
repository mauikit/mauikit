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

#ifndef MAUIACCOUNTS_H
#define MAUIACCOUNTS_H

#include <mauilist.h>

/**
 * MauiAccounts
 * provides an interface to access the system registered accounts,
 * the current active account and a bridge to add account data to the host system backend solution.
 * This properties and functions are exposed to
 * all the Maui Applications that might want to use the accounts
 */
#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

class AccountsDB;
#ifdef STATIC_MAUIKIT
class MauiAccounts : public MauiList
#else
class MAUIKIT_EXPORT MauiAccounts : public MauiList

#endif
{
    Q_OBJECT
    Q_PROPERTY(int currentAccountIndex READ getCurrentAccountIndex WRITE setCurrentAccountIndex NOTIFY currentAccountIndexChanged)
	
	Q_PROPERTY(QVariantMap currentAccount READ getCurrentAccount NOTIFY currentAccountChanged)
	Q_PROPERTY(uint count READ getCount NOTIFY countChanged)

public:
	static MauiAccounts *instance()
	{
		static MauiAccounts accounts;
		return &accounts;
	}
	
	MauiAccounts(const MauiAccounts&) = delete;
	MauiAccounts& operator=(const MauiAccounts &) = delete;
	MauiAccounts(MauiAccounts &&) = delete;
	MauiAccounts & operator=(MauiAccounts &&) = delete;	
	
    FMH::MODEL_LIST items() const final override;
	
	void setCurrentAccountIndex(const int &index);
	int getCurrentAccountIndex() const;  
	
	QVariantMap getCurrentAccount() const;        
	
	uint getCount() const;
	
public slots:	
	QVariantMap get(const int &index) const;
    QVariantList getCloudAccountsList();
    FMH::MODEL_LIST getCloudAccounts();
	void registerAccount(const QVariantMap &account);
	
	void removeAccount(const int &index);
	void removeAccountAndFiles(const int &index);
	void refresh();
	
private:
	MauiAccounts();
	~MauiAccounts();
	
    AccountsDB *db;
	FMH::MODEL_LIST m_data;
	QVariantMap m_currentAccount;
	
	int m_currentAccountIndex = -1;
	uint m_count = 0;	
	
	void setAccounts();

    bool addCloudAccount(const QString &server, const QString &user, const QString &password);
    bool removeCloudAccount(const QString &server, const QString &user);

    QVariantList get(const QString &queryTxt);

signals:
    void accountAdded(QVariantMap account);
    void accountRemoved(QVariantMap account);
	void currentAccountChanged(QVariantMap account);
	void currentAccountIndexChanged(int index);	
	void countChanged(uint count);
};

#endif // MAUIACCOUNTS_H
