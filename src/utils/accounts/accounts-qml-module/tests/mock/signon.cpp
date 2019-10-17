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

#include "signon.h"

#include <QDebug>
#include <QStringList>

using namespace SignOn;

namespace SignOn {

class IdentityInfoImpl {
private:
    friend class IdentityInfo;
    QVariantMap fields;
};

QHash<quint32,IdentityInfo> storedIdentities;

}; // namespace

IdentityInfo::IdentityInfo():
    impl(new IdentityInfoImpl)
{
}

IdentityInfo::IdentityInfo(const IdentityInfo &other):
    impl(new IdentityInfoImpl)
{
    impl->fields = other.impl->fields;
}

IdentityInfo &IdentityInfo::operator=(const IdentityInfo &other)
{
    impl->fields = other.impl->fields;
    return *this;
}

IdentityInfo::~IdentityInfo()
{
    delete impl;
}

void IdentityInfo::setId(const quint32 id)
{
    impl->fields["id"] = id;
}

quint32 IdentityInfo::id() const
{
    return impl->fields.value("id", 0).toUInt();
}

void IdentityInfo::setSecret(const QString &secret, const bool storeSecret)
{
    impl->fields["secret"] = secret;
    setStoreSecret(storeSecret);
}

QString IdentityInfo::secret() const
{
    return impl->fields.value("secret").toString();
}

bool IdentityInfo::isStoringSecret() const
{
    return impl->fields.value("storeSecret").toBool();
}

void IdentityInfo::setStoreSecret(const bool storeSecret)
{
    impl->fields["storeSecret"] = storeSecret;
}

void IdentityInfo::setUserName(const QString &userName)
{
    impl->fields["userName"] = userName;
}

const QString IdentityInfo::userName() const
{
    return impl->fields.value("userName").toString();
}

void IdentityInfo::setCaption(const QString &caption)
{
    impl->fields["caption"] = caption;
}

const QString IdentityInfo::caption() const
{
    return impl->fields.value("caption").toString();
}

void IdentityInfo::setRealms(const QStringList &realms)
{
    impl->fields["realms"] = realms;
}

QStringList IdentityInfo::realms() const
{
    return impl->fields.value("realms").toStringList();
}

void IdentityInfo::setOwner(const QString &ownerToken)
{
    impl->fields["owner"] = ownerToken;
}

QString IdentityInfo::owner() const
{
    return impl->fields.value("owner").toString();
}

void IdentityInfo::setAccessControlList(const QStringList &accessControlList)
{
    impl->fields["accessControlList"] = accessControlList;
}

QStringList IdentityInfo::accessControlList() const
{
    return impl->fields.value("accessControlList").toStringList();
}

void IdentityInfo::setMethod(const MethodName &method,
                             const MechanismsList &mechanismsList)
{
    QVariantMap methods = impl->fields["methods"].toMap();
    methods[method] = mechanismsList;
    impl->fields["methods"] = methods;
}

void IdentityInfo::removeMethod(const MethodName &method)
{
    QVariantMap methods = impl->fields["methods"].toMap();
    methods.remove(method);
    impl->fields["methods"] = methods;
}

QList<MethodName> IdentityInfo::methods() const
{
    QVariantMap methods = impl->fields["methods"].toMap();
    return methods.keys();
}

MechanismsList IdentityInfo::mechanisms(const MethodName &method) const
{
    QVariantMap methods = impl->fields["methods"].toMap();
    return methods[method].toStringList();
}

void IdentityInfo::setType(CredentialsType type)
{
    impl->fields["type"] = type;
}

IdentityInfo::CredentialsType IdentityInfo::type() const
{
    return CredentialsType(impl->fields["type"].toInt());
}

quint32 Identity::lastId = 1;

Identity::Identity(const quint32 id, QObject *parent):
    QObject(parent),
    m_id(id)
{
    m_storeTimer.setSingleShot(true);
    m_storeTimer.setInterval(50);
    QObject::connect(&m_storeTimer, SIGNAL(timeout()),
                     this, SLOT(emitCredentialsStored()));

    m_infoTimer.setSingleShot(true);
    m_infoTimer.setInterval(20);
    QObject::connect(&m_infoTimer, SIGNAL(timeout()),
                     this, SLOT(emitInfo()));

    m_removeTimer.setSingleShot(true);
    m_removeTimer.setInterval(40);
    QObject::connect(&m_removeTimer, SIGNAL(timeout()),
                     this, SLOT(emitRemoved()));
}

Identity::~Identity()
{
}

Identity *Identity::newIdentity(const IdentityInfo &info, QObject *parent)
{
    Identity *identity = new Identity(0, parent);
    identity->m_info = info;
    return identity;
}

Identity *Identity::existingIdentity(const quint32 id, QObject *parent)
{
    if (id != 0 && !storedIdentities.contains(id)) return 0;

    Identity *identity = new Identity(id, parent);
    identity->m_info = storedIdentities.value(id);
    return identity;
}

AuthSessionP Identity::createSession(const QString &methodName)
{
    return new AuthSession(m_id, methodName, this);
}

void Identity::storeCredentials(const IdentityInfo &info)
{
    if (m_id == 0) {
        m_id = lastId++;
    }
    m_info = info;
    m_info.setId(m_id);
    storedIdentities.insert(m_id, m_info);
    m_storeTimer.start();
}

void Identity::remove()
{
    m_removeTimer.start();
}

void Identity::queryInfo()
{
    m_infoTimer.start();
}

void Identity::emitCredentialsStored()
{
    Q_EMIT credentialsStored(m_id);
}

void Identity::emitInfo()
{
    Q_EMIT info(m_info);
}

void Identity::emitRemoved()
{
    if (m_id != 0 && !storedIdentities.contains(m_id)) {
        Q_EMIT error(Error(Error::RemoveFailed, "Identity was not stored"));
        return;
    }
    storedIdentities.remove(m_id);
    Q_EMIT removed();
}

AuthSession::AuthSession(quint32 id, const QString &methodName,
                         QObject *parent):
    QObject(parent),
    m_id(id),
    m_method(methodName)
{
    responseTimer.setSingleShot(true);
    responseTimer.setInterval(10);
    QObject::connect(&responseTimer, SIGNAL(timeout()),
                     this, SLOT(respond()));
}

AuthSession::~AuthSession()
{
}

void AuthSession::process(const SessionData &sessionData,
                          const QString &mechanism)
{
    m_mechanism = mechanism;
    m_sessionData = sessionData.toMap();
    m_sessionData.insert("credentialsId", m_id);

    responseTimer.start();
}

void AuthSession::cancel()
{
    m_sessionData.insert("errorCode", Error::SessionCanceled);
    m_sessionData.insert("errorMessage", QStringLiteral("Session canceled"));
}

void AuthSession::respond()
{
    if (m_sessionData.contains("errorCode")) {
        Error err(m_sessionData["errorCode"].toInt(),
                  m_sessionData["errorMessage"].toString());
        Q_EMIT error(err);
    } else {
        Q_EMIT response(m_sessionData);
    }
}
