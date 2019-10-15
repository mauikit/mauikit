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

#include <QAbstractListModel>
#include <QQmlParserStatus>
#include <QString>
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

namespace OnlineAccounts {

class AccountServiceModelPrivate;

class AccountServiceModel: public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool includeDisabled READ includeDisabled \
               WRITE setIncludeDisabled NOTIFY includeDisabledChanged)
    Q_PROPERTY(quint32 accountId READ accountId WRITE setAccountId \
               NOTIFY accountIdChanged)
    Q_PROPERTY(QObject *account READ account WRITE setAccount \
               NOTIFY accountChanged)
    Q_PROPERTY(QString applicationId READ applicationId \
               WRITE setApplicationId NOTIFY applicationIdChanged)
    Q_PROPERTY(QString provider READ provider WRITE setProvider \
               NOTIFY providerChanged)
    Q_PROPERTY(QString serviceType READ serviceType WRITE setServiceType \
               NOTIFY serviceTypeChanged)
    Q_PROPERTY(QString service READ service WRITE setService \
               NOTIFY serviceChanged)

public:
    AccountServiceModel(QObject *parent = 0);
    ~AccountServiceModel();

    enum Roles {
        DisplayNameRole = Qt::UserRole + 1,
        ProviderNameRole,
        ServiceNameRole,
        EnabledRole,
        AccountServiceHandleRole,
        AccountServiceRole, // deprecated
        AccountIdRole,
        AccountHandleRole,
        AccountRole, // deprecated
    };

    void setIncludeDisabled(bool includeDisabled);
    bool includeDisabled() const;

    void setAccountId(quint32 accountId);
    quint32 accountId() const;

    void setAccount(QObject *account);
    QObject *account() const;

    void setApplicationId(const QString &applicationId);
    QString applicationId() const;

    void setProvider(const QString &providerId);
    QString provider() const;

    void setServiceType(const QString &serviceTypeId);
    QString serviceType() const;

    void setService(const QString &serviceId);
    QString service() const;

    Q_INVOKABLE QVariant get(int row, const QString &roleName) const;

    // reimplemented virtual methods
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    void classBegin();
    void componentComplete();

Q_SIGNALS:
    void countChanged();
    void includeDisabledChanged();
    void accountIdChanged();
    void accountChanged();
    void applicationIdChanged();
    void providerChanged();
    void serviceTypeChanged();
    void serviceChanged();

private:
    AccountServiceModelPrivate *d_ptr;
    Q_DECLARE_PRIVATE(AccountServiceModel)
};

}; // namespace

class KAccountsProvider : public AccountsProvider {
    Q_OBJECT
public:
    KAccountsProvider(QObject* parent = nullptr);
    QVariant getAccounts(QString service, bool includeDisabled = false) override final;

private:
    OnlineAccounts::AccountServiceModel *accountsModel;
};

#endif

