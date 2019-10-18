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

#ifndef ACCOUNTSPROVIDER_ACCOUNTSPROVIDER_H
#define ACCOUNTSPROVIDER_ACCOUNTSPROVIDER_H

#include <QObject>
#include "fmh.h"

class AccountsProvider : public QObject {
    Q_OBJECT
public:
    AccountsProvider(QObject* parent=nullptr) : QObject(parent) {}

    virtual FMH::MODEL_LIST getAccounts(QString service, bool includeDisabled=false) = 0;
	virtual bool addAccount(const QString &server, const QString &user, const QString &password) = 0;
    virtual bool removeAccount(FMH::MODEL account) = 0;
	
signals:
	void accountAdded(QVariantMap account);
	void accountRemoved(QVariantMap account);
};

#endif
