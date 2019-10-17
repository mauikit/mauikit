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

#ifndef ONLINE_ACCOUNTS_ACCOUNT_H
#define ONLINE_ACCOUNTS_ACCOUNT_H

#include <QList>
#include <QObject>
#include <QPointer>
#include <QVariantMap>

namespace Accounts {
    class Account;
    class AccountService;
};

namespace SignOn {
    class Identity;
};

namespace OnlineAccounts {

class Account: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *objectHandle READ objectHandle \
               WRITE setObjectHandle NOTIFY objectHandleChanged)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(QVariantMap provider READ provider NOTIFY objectHandleChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
    Q_PROPERTY(uint accountId READ accountId NOTIFY accountIdChanged)
    Q_PROPERTY(QObject *accountServiceHandle READ accountServiceHandle \
               NOTIFY objectHandleChanged)

public:
    enum RemovalOption {
        RemoveAccountOnly = 0x0,
        RemoveCredentials = 0x1,
    };
    Q_DECLARE_FLAGS(RemovalOptions, RemovalOption)
    Q_FLAGS(RemovalOption RemovalOptions)

    Account(QObject *parent = 0);
    ~Account();

    void setObjectHandle(QObject *object);
    QObject *objectHandle() const;

    bool enabled() const;
    QVariantMap provider() const;
    QString displayName() const;
    uint accountId() const;
    QObject *accountServiceHandle() const;

    Q_INVOKABLE void updateDisplayName(const QString &displayName);
    Q_INVOKABLE void updateEnabled(bool enabled);
    Q_INVOKABLE void sync();
    Q_INVOKABLE void remove(RemovalOptions options = RemoveCredentials);

Q_SIGNALS:
    void objectHandleChanged();
    void accountIdChanged();
    void enabledChanged();
    void displayNameChanged();
    void synced();
    void removed();

private Q_SLOTS:
    void onRemoved();
    void onIdentityRemoved();

private:
    QPointer<Accounts::Account> account;
    QPointer<Accounts::AccountService> accountService;
    QList<SignOn::Identity *> identities;
};

}; // namespace

Q_DECLARE_OPERATORS_FOR_FLAGS(OnlineAccounts::Account::RemovalOptions)

#endif // ONLINE_ACCOUNTS_ACCOUNT_H
