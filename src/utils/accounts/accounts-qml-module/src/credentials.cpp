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


#include "credentials.h"
#include "debug.h"

using namespace OnlineAccounts;

/*!
 * \qmltype Credentials
 * \inqmlmodule Ubuntu.OnlineAccounts 0.1
 * \ingroup Ubuntu
 *
 * \brief Holds the account's credentials
 *
 * The Credentials element contains the information about an account's
 * credentials. Informations like user name and password are stored into the
 * account's secret storage via this object.
 * If the \l credentialsId property is set to a valid credentials ID (which can
 * be obtained via the AccountService's \l
 * {AccountService::authData}{authData.credentialsId} property) the Credentials
 * element will load the informations stored in the secrets database, with the
 * notable exception of the \l secret field, which cannot be read back via this
 * interface (but only via the \l AccountService::authenticate method); if the
 * \l credentialsId field is not set, then this interface can be used to create
 * a new record in the secrets storage, by calling the \l sync() method once
 * all the desired fields have been set.
 */
Credentials::Credentials(QObject *parent):
    QObject(parent),
    m_credentialsId(0),
    identity(0)
{
}

Credentials::~Credentials()
{
}

/*!
 * \qmlproperty quint32 Credentials::credentialsId
 * Numeric identifier of the credentials record in the secret storage database.
 * A value of \a 0 means that this object has not been stored into the database
 * yet.
 * \sa sync
 */
void Credentials::setCredentialsId(quint32 credentialsId)
{
    if (credentialsId == m_credentialsId) return;

    delete identity;
    if (credentialsId != 0) {
        identity = SignOn::Identity::existingIdentity(credentialsId, this);
        if (identity != 0) {
            setupIdentity();
            identity->queryInfo();
        }
    } else {
        identity = 0; /* We'll instantiate it if/when needed */
    }
    m_credentialsId = credentialsId;
    Q_EMIT credentialsIdChanged();
}

quint32 Credentials::credentialsId() const
{
    return m_credentialsId;
}

/*!
 * \qmlproperty string Credentials::caption
 * A description of the credentials. This could be set to the name of the
 * account provider, for instance.
 */
void Credentials::setCaption(const QString &caption)
{
    if (caption == info.caption()) return;
    info.setCaption(caption);
    Q_EMIT captionChanged();
}

QString Credentials::caption() const
{
    return info.caption();
}

/*!
 * \qmlproperty string Credentials::userName
 * The user name.
 */
void Credentials::setUserName(const QString &userName)
{
    if (userName == info.userName()) return;
    info.setUserName(userName);
    Q_EMIT userNameChanged();
}

QString Credentials::userName() const
{
    return info.userName();
}

/*!
 * \qmlproperty string Credentials::secret
 * The secret information for this credentials; usually this is the user's password.
 * Note that when retrieving a Credentials object from the secrets database,
 * this field will not be retrieved. See the detailed description of the
 * Credentials element for a full explanation of this.
 *
 * \sa credentialsId
 */
void Credentials::setSecret(const QString &secret)
{
    info.setSecret(secret);
    Q_EMIT secretChanged();
}

QString Credentials::secret() const
{
    return info.secret();
}

/*!
 * \qmlproperty bool Credentials::storeSecret
 * Whether the secret should be stored in the secrets storage.
 */
void Credentials::setStoreSecret(bool storeSecret)
{
    if (storeSecret == info.isStoringSecret()) return;
    info.setStoreSecret(storeSecret);
    Q_EMIT storeSecretChanged();
}

bool Credentials::storeSecret() const
{
    return info.isStoringSecret();
}

/*!
 * \qmlproperty list<string> Credentials::acl
 * The ACL (Access Control List) for the credentials. The string \a "*" should
 * be used when no access control needs to be performed.
 */
void Credentials::setAcl(const QStringList &acl)
{
    info.setAccessControlList(acl);
    Q_EMIT aclChanged();
}

QStringList Credentials::acl() const
{
    return info.accessControlList();
}

/*!
 * \qmlproperty jsobject Credentials::methods
 * A dictionary describing the authentication methods and mechanisms which are
 * allowed on the credentials. The keys of the dictionary should be the
 * authentication methods, and the values should be lists of mechanisms.
 * \qml
 * Credentials {
 *     methods: { "oauth2": [ "web_server", "user_agent"], "password": [ "password" ] }
 * }
 * \endqml
 */
void Credentials::setMethods(const QVariantMap &methods)
{
    /* To keep things simple, always delete all existing methods, and then add
     * the new ones. */
    Q_FOREACH (const QString &method, info.methods()) {
        info.removeMethod(method);
    }

    QMapIterator<QString, QVariant> it(methods);
    while (it.hasNext()) {
        it.next();
        info.setMethod(it.key(), it.value().toStringList());
    }
}

QVariantMap Credentials::methods() const
{
    QVariantMap methods;
    Q_FOREACH (const QString &method, info.methods()) {
        QStringList mechanisms = info.mechanisms(method);
        methods.insert(method, mechanisms);
    }
    return methods;
}

/*!
 * \qmlmethod void Credentials::sync()
 *
 * Writes the changes to the secrets storage.
 *
 * \sa synced
 */
void Credentials::sync()
{
    ensureIdentity();
    identity->storeCredentials(info);
}

/*!
 * \qmlmethod void Credentials::remove()
 *
 * Deletes the credentials from the secrets storage.
 *
 * \sa removed
 */
void Credentials::remove()
{
    /* If we don't have an identity object, this means that this object was
     * never stored; we have nothing to do in this case. */
    if (Q_UNLIKELY(identity == 0)) return;
    identity->remove();
}

/*!
 * \qmlsignal Credentials::synced()
 *
 * Emitted when the changes have been stored into the permanent secrets storage.
 */

/*!
 * \qmlsignal Credentials::removed()
 *
 * Emitted when the credentials have been deleted from the secrets storage.
 */

void Credentials::ensureIdentity()
{
    if (identity == 0) {
        identity = SignOn::Identity::newIdentity(info, this);
        setupIdentity();
    }
}

void Credentials::setupIdentity()
{
    QObject::connect(identity, SIGNAL(info(const SignOn::IdentityInfo&)),
                     this, SLOT(onInfo(const SignOn::IdentityInfo&)));
    QObject::connect(identity, SIGNAL(credentialsStored(const quint32)),
                     this, SLOT(onStored(const quint32)));
    QObject::connect(identity, SIGNAL(removed()), this, SIGNAL(removed()));
}

void Credentials::onInfo(const SignOn::IdentityInfo &info)
{
    this->info = info;
    /* Emit the notification signals for all the properties; if this turns out
     * to be an issue, we could just emit the signals for those properties
     * whose value actually changed. */
    Q_EMIT credentialsIdChanged();
    Q_EMIT captionChanged();
    Q_EMIT userNameChanged();
    Q_EMIT secretChanged();
    Q_EMIT storeSecretChanged();
    Q_EMIT aclChanged();
    Q_EMIT methodsChanged();

    Q_EMIT synced();
}

void Credentials::onStored(const quint32 id)
{
    m_credentialsId = id;
    identity->queryInfo();
}
