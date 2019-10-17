/*
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Alberto Mardegan <alberto.mardegan@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.1.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ONLINE_ACCOUNTS_MANAGER_H
#define ONLINE_ACCOUNTS_MANAGER_H

#include <QObject>
#include <QSharedPointer>

namespace Accounts {
    class Manager;
};

namespace OnlineAccounts {

class SharedManager
{
public:
    static QSharedPointer<Accounts::Manager> instance();
};

class Manager: public QObject
{
    Q_OBJECT

public:
    Manager(QObject *parent = 0);
    ~Manager();

    Q_INVOKABLE QObject *loadAccount(uint accountId);
    Q_INVOKABLE QObject *createAccount(const QString &providerName);

private:
    QSharedPointer<Accounts::Manager> manager;
};

}; // namespace

#endif // ONLINE_ACCOUNTS_MANAGER_H
