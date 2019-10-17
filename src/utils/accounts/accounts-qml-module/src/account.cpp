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


#include "account.h"
#include "debug.h"

#include <Accounts/Account>
#include <Accounts/AccountService>
#include <Accounts/Provider>
#include <SignOn/Identity>

using namespace OnlineAccounts;

/*!
 * \qmltype Account
 * \inqmlmodule Ubuntu.OnlineAccounts 0.1
 * \ingroup Ubuntu
 *
 * \brief Represents an instance of an online account.
 *
 * The Account element represents an online account. It is functional only if
 * its \a objectHandle property is set to a valid account, which can be
 * obtained with Manager.loadAccount() or Manager.createAccount().
 */
Account::Account(QObject *parent):
    QObject(parent),
    account(0),
    accountService(0)
{
}

Account::~Account()
{
}

/*!
 * \qmlproperty object Account::objectHandle
 * An opaque handle to the underlying C++ object. Until the property is set,
 * the Account element is uninitialized. Similarly, if the C++ object is
 * destroyed, expect the Account to become invalid.
 */
void Account::setObjectHandle(QObject *object)
{
    DEBUG() << object;
    Accounts::Account *a = qobject_cast<Accounts::Account*>(object);
    if (Q_UNLIKELY(a == 0)) return;

    if (a == account) return;
    account = a;
    QObject::connect(account, SIGNAL(displayNameChanged(const QString &)),
                     this, SIGNAL(displayNameChanged()));
    QObject::connect(account, SIGNAL(synced()), this, SIGNAL(synced()));
    QObject::connect(account, SIGNAL(removed()), this, SLOT(onRemoved()));

    /* Setup an AccountService object to monitor the settings of the global
     * account. */
    delete accountService;
    accountService = new Accounts::AccountService(account, Accounts::Service(),
                                                  account);
    QObject::connect(accountService, SIGNAL(enabled(bool)),
                     this, SIGNAL(enabledChanged()));
    Q_EMIT objectHandleChanged();

    /* Emit the changed signals for all other properties, to make sure
     * that all bindings are updated. */
    Q_EMIT accountIdChanged();
    Q_EMIT enabledChanged();
    Q_EMIT displayNameChanged();
}

QObject *Account::objectHandle() const
{
    return account;
}

/*!
 * \qmlproperty bool Account::enabled
 * This read-only property tells whether the Account is enabled. An
 * application shouldn't use an Account which is disabled.
 */
bool Account::enabled() const
{
    if (Q_UNLIKELY(accountService == 0)) return false;
    return accountService->enabled();
}

/*!
 * \qmlproperty jsobject Account::provider
 * An immutable object representing the provider which provides the account.
 * The returned object will have at least these members:
 * \list
 * \li \c id is the unique identified for this provider
 * \li \c displayName
 * \li \c iconName
 * \endlist
 */
QVariantMap Account::provider() const
{
    QVariantMap map;
    if (Q_UNLIKELY(account == 0)) return map;

    Accounts::Provider provider = account->provider();
    map.insert("id", provider.name());
    map.insert("displayName", provider.displayName());
    map.insert("iconName", provider.iconName());
    return map;
}

/*!
 * \qmlproperty string Account::displayName
 * The account's display name (usually the user's login or ID).
 */
QString Account::displayName() const
{
    if (Q_UNLIKELY(account == 0)) return QString();
    return account->displayName();
}

/*!
 * \qmlproperty string Account::accountId
 * The account's numeric ID. This is 0 until the account has been stored into the DB.
 */
uint Account::accountId() const
{
    if (Q_UNLIKELY(account == 0)) return 0;
    return account->id();
}

/*!
 * \qmlproperty object Account::accountServiceHandle
 * A C++ object which can be used to instantiate an AccountService by setting
 * it as the value for the \l AccountService::objectHandle property.
 */
QObject *Account::accountServiceHandle() const
{
    return accountService;
}

/*!
 * \qmlmethod void Account::updateDisplayName(string displayName)
 *
 * Changes the display name of the account.
 *
 * \sa sync()
 */
void Account::updateDisplayName(const QString &displayName)
{
    if (Q_UNLIKELY(account == 0)) return;
    account->setDisplayName(displayName);
}

/*!
 * \qmlmethod void Account::updateEnabled(bool enabled)
 *
 * Enables or disables the account.
 *
 * \sa sync()
 */
void Account::updateEnabled(bool enabled)
{
    if (Q_UNLIKELY(account == 0)) return;
    account->selectService();
    account->setEnabled(enabled);
}

/*!
 * \qmlmethod void Account::sync()
 *
 * Writes the changes to the permanent account storage.
 */
void Account::sync()
{
    if (Q_UNLIKELY(account == 0)) return;
    account->sync();
}

/*!
 * \qmlmethod void Account::remove()
 *
 * Deletes the account from the permanent storage. This method accepts an
 * optional parameter, which tells whether the credentials associated with
 * the account should also be removed:
 * \list
 * \li \c Account.RemoveAccountOnly
 * \li \c Account.RemoveCredentials - the default
 * \endlist
 */
void Account::remove(RemovalOptions options)
{
    if (Q_UNLIKELY(account == 0)) return;

    if (options & RemoveCredentials) {
        /* Get all the IDs of the credentials used by this account */
        QList<uint> credentialIds;
        account->selectService();
        uint credentialsId = account->value("CredentialsId").toUInt();
        if (credentialsId != 0)
            credentialIds.append(credentialsId);
        Q_FOREACH (const Accounts::Service &service, account->services()) {
            account->selectService(service);
            credentialsId = account->value("CredentialsId").toUInt();
            if (credentialsId != 0)
                credentialIds.append(credentialsId);
        }

        /* Instantiate an Identity object for each of them */
        Q_FOREACH (uint credentialsId, credentialIds) {
            SignOn::Identity *identity =
                SignOn::Identity::existingIdentity(credentialsId, this);
            QObject::connect(identity, SIGNAL(removed()),
                             this, SLOT(onIdentityRemoved()));
            /* Since we don't do any error handling in case the removal of the
             * identity failed, we connect to the same slot. */
            QObject::connect(identity, SIGNAL(error(const SignOn::Error&)),
                             this, SLOT(onIdentityRemoved()));
            identities.append(identity);
        }
    }

    account->remove();
    account->sync();
}

/*!
 * \qmlsignal Account::synced()
 *
 * Emitted when the account changes have been stored into the permanent storage.
 */

void Account::onRemoved()
{
    Q_FOREACH (SignOn::Identity *identity, identities) {
        /* Remove the associated credentials */
        identity->remove();
    }

    /* Don't emit the removed() signal until all associated Identity objects
     * have been removed */
    if (identities.isEmpty()) {
        Q_EMIT removed();
    }
}

void Account::onIdentityRemoved()
{
    SignOn::Identity *identity = qobject_cast<SignOn::Identity *>(sender());
    identities.removeAll(identity);
    identity->deleteLater();

    if (identities.isEmpty()) {
        Q_EMIT removed();
    }
}
