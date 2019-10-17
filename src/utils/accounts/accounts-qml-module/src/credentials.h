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

#ifndef ONLINE_ACCOUNTS_CREDENTIALS_H
#define ONLINE_ACCOUNTS_CREDENTIALS_H

#include <QObject>
#include <QPointer>
#include <QStringList>
#include <QVariantMap>

#include <SignOn/Identity>

namespace OnlineAccounts {

class Credentials: public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint32 credentialsId READ credentialsId WRITE setCredentialsId \
               NOTIFY credentialsIdChanged)
    Q_PROPERTY(QString caption READ caption WRITE setCaption \
               NOTIFY captionChanged)
    Q_PROPERTY(QString userName READ userName WRITE setUserName \
               NOTIFY userNameChanged)
    Q_PROPERTY(QString secret READ secret WRITE setSecret NOTIFY secretChanged)
    Q_PROPERTY(bool storeSecret READ storeSecret WRITE setStoreSecret \
               NOTIFY storeSecretChanged)
    Q_PROPERTY(QStringList acl READ acl WRITE setAcl NOTIFY aclChanged)
    Q_PROPERTY(QVariantMap methods READ methods WRITE setMethods NOTIFY methodsChanged)

public:
    Credentials(QObject *parent = 0);
    ~Credentials();

    void setCredentialsId(quint32 credentialsId);
    quint32 credentialsId() const;

    void setCaption(const QString &caption);
    QString caption() const;

    void setUserName(const QString &userName);
    QString userName() const;

    void setSecret(const QString &secret);
    QString secret() const;

    void setStoreSecret(bool storeSecret);
    bool storeSecret() const;

    void setAcl(const QStringList &acl);
    QStringList acl() const;

    void setMethods(const QVariantMap &methods);
    QVariantMap methods() const;

    Q_INVOKABLE void sync();
    Q_INVOKABLE void remove();

Q_SIGNALS:
    void credentialsIdChanged();
    void captionChanged();
    void userNameChanged();
    void secretChanged();
    void storeSecretChanged();
    void aclChanged();
    void methodsChanged();

    void synced();
    void removed();

private:
    void ensureIdentity();
    void setupIdentity();

private Q_SLOTS:
    void onInfo(const SignOn::IdentityInfo &info);
    void onStored(const quint32 id);

private:
    quint32 m_credentialsId;
    SignOn::Identity *identity;
    SignOn::IdentityInfo info;
};

}; // namespace

#endif // ONLINE_ACCOUNTS_CREDENTIALS_H
