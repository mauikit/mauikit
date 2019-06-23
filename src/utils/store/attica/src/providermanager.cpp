/*
    This file is part of KDE.

    Copyright (c) 2009 Eckhart Wörner <ewoerner@kde.org>
    Copyright (c) 2009 Frederik Gladhorn <gladhorn@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "providermanager.h"

#ifndef STATIC_MAUIKIT
#include "attica_debug.h"
#endif
#include "atticautils.h"

#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QPluginLoader>
#include <QSet>
#include <QSignalMapper>
#include <QTimer>
#include <QProcess>
#include <QAuthenticator>
#include <QNetworkReply>
#include <QNetworkProxy>
#include <QXmlStreamReader>
#include <QSignalMapper>

#include "platformdependent.h"
#include "qtplatformdependent_p.h"
#include <QLibraryInfo>

using namespace Attica;

class ProviderManager::Private
{
public:
    PlatformDependent *m_internals;
    QHash<QUrl, Provider> m_providers;
    QHash<QUrl, QUrl> m_providerTargets;
    QSignalMapper m_downloadMapping;
    QHash<QString, QNetworkReply *> m_downloads;
    bool m_authenticationSuppressed;

    Private()
        : m_internals(nullptr)
        , m_authenticationSuppressed(false)
    {
    }
    ~Private()
    {
        // do not delete m_internals: it is the root component of a plugin!
    }
};

PlatformDependent *ProviderManager::loadPlatformDependent(const ProviderFlags &flags)
{
    if (flags & ProviderManager::DisablePlugins) {
        return new QtPlatformDependent;
    }

    QPluginLoader loader(QStringLiteral("attica_kde"));
    PlatformDependent * ret = qobject_cast<PlatformDependent *>(loader.instance());

    return ret ? ret : new QtPlatformDependent;
}

ProviderManager::ProviderManager(const ProviderFlags &flags)
    : d(new Private)
{
    d->m_internals = loadPlatformDependent(flags);
    connect(d->m_internals->nam(), SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)), SLOT(authenticate(QNetworkReply*,QAuthenticator*)));
    connect(&d->m_downloadMapping, SIGNAL(mapped(QString)), SLOT(fileFinished(QString)));
}

void ProviderManager::loadDefaultProviders()
{
    QTimer::singleShot(0, this, SLOT(slotLoadDefaultProvidersInternal()));
}

void ProviderManager::setAuthenticationSuppressed(bool suppressed)
{
    d->m_authenticationSuppressed = suppressed;
}

void ProviderManager::clear()
{
    d->m_providerTargets.clear();
    d->m_providers.clear();
}

void ProviderManager::slotLoadDefaultProvidersInternal()
{
    foreach (const QUrl &url, d->m_internals->getDefaultProviderFiles()) {
        addProviderFile(url);
    }
    if (d->m_downloads.isEmpty()) {
        emit defaultProvidersLoaded();
    }
}

QList<QUrl> ProviderManager::defaultProviderFiles()
{
    return d->m_internals->getDefaultProviderFiles();
}

ProviderManager::~ProviderManager()
{
    delete d;
}

void ProviderManager::addProviderFileToDefaultProviders(const QUrl &url)
{
    d->m_internals->addDefaultProviderFile(url);
    addProviderFile(url);
}

void ProviderManager::removeProviderFileFromDefaultProviders(const QUrl &url)
{
    d->m_internals->removeDefaultProviderFile(url);
}

void ProviderManager::addProviderFile(const QUrl &url)
{
    if (url.isLocalFile()) {
        QFile file(url.toLocalFile());
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "ProviderManager::addProviderFile: could not open provider file: " << url.toString();
            return;
        }
        parseProviderFile(QLatin1String(file.readAll()), url);
    } else {
        if (!d->m_downloads.contains(url.toString())) {
            QNetworkRequest req(url);
            req.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
            QNetworkReply *reply = d->m_internals->get(req);
            //qCDebug(ATTICA) << "executing" << Utils::toString(reply->operation()) << "for" << reply->url();
            connect(reply, SIGNAL(finished()), &d->m_downloadMapping, SLOT(map()));
            d->m_downloadMapping.setMapping(reply, url.toString());
            d->m_downloads.insert(url.toString(), reply);
        }
    }
}

void ProviderManager::fileFinished(const QString &url)
{
    QNetworkReply *reply = d->m_downloads.take(url);
    parseProviderFile(QLatin1String(reply->readAll()), QUrl(url));
    reply->deleteLater();
}

void ProviderManager::addProviderFromXml(const QString &providerXml)
{
    parseProviderFile(providerXml, QUrl());
}

void ProviderManager::parseProviderFile(const QString &xmlString, const QUrl &url)
{
    QXmlStreamReader xml(xmlString);
    while (!xml.atEnd() && xml.readNext()) {
        if (xml.isStartElement() && xml.name() == QLatin1String("provider")) {
            QUrl baseUrl;
            QString name;
            QUrl icon;
            QString person;
            QString friendV;
            QString message;
            QString achievement;
            QString activity;
            QString content;
            QString fan;
            QString forum;
            QString knowledgebase;
            QString event;
            QString comment;
            QString registerUrl;

            while (!xml.atEnd() && xml.readNext()) {
                if (xml.isStartElement()) {
                    if (xml.name() == QLatin1String("location")) {
                        baseUrl = QUrl(xml.readElementText());
                    } else if (xml.name() == QLatin1String("name")) {
                        name = xml.readElementText();
                    } else if (xml.name() == QLatin1String("icon")) {
                        icon = QUrl(xml.readElementText());
                    } else if (xml.name() == QLatin1String("person")) {
                        person = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("friend")) {
                        friendV = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("message")) {
                        message = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("achievement")) {
                        achievement = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("activity")) {
                        activity = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("content")) {
                        content = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("fan")) {
                        fan = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("forum")) {
                        forum = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("knowledgebase")) {
                        knowledgebase = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("event")) {
                        event = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("comment")) {
                        comment = xml.attributes().value(QLatin1String("ocsversion")).toString();
                    } else if (xml.name() == QLatin1String("register")) {
                        registerUrl = xml.readElementText();
                    }
                } else if (xml.isEndElement() && xml.name() == QLatin1String("provider")) {
                    break;
                }
            }
            if (!baseUrl.isEmpty()) {
                ////qCDebug(ATTICA) << "Adding provider" << baseUrl;
                d->m_providers.insert(baseUrl, Provider(d->m_internals, baseUrl, name, icon,
                                                        person, friendV, message, achievement, activity, content, fan, forum, knowledgebase,
                                                        event, comment, registerUrl));
                d->m_providerTargets[url] = baseUrl;
                emit providerAdded(d->m_providers.value(baseUrl));
            }
        }
    }

    if (xml.error() != QXmlStreamReader::NoError) {
        //qCDebug(ATTICA) << "error:" << xml.errorString() << "in" << url;
    }

    if (d->m_downloads.isEmpty()) {
        emit defaultProvidersLoaded();
    }
}

Provider ProviderManager::providerFor(const QUrl &url) const
{
    return providerByUrl(d->m_providerTargets.value(url));
}

Provider ProviderManager::providerByUrl(const QUrl &url) const
{
    return d->m_providers.value(url);
}

QList<Provider> ProviderManager::providers() const
{
    return d->m_providers.values();
}

bool ProviderManager::contains(const QString &provider) const
{
    return d->m_providers.contains(QUrl(provider));
}

QList<QUrl> ProviderManager::providerFiles() const
{
    return d->m_providerTargets.keys();
}

void ProviderManager::authenticate(QNetworkReply *reply, QAuthenticator *auth)
{
    QUrl baseUrl;
    QList<QUrl> urls = d->m_providers.keys();
    foreach (const QUrl &url, urls) {
        if (url.isParentOf(reply->url())) {
            baseUrl = url;
            break;
        }
    }

    ////qCDebug(ATTICA) << "ProviderManager::authenticate" << baseUrl;

    QString user;
    QString password;
    if (auth->user().isEmpty() && auth->password().isEmpty()) {
        if (d->m_internals->hasCredentials(baseUrl)) {
            if (d->m_internals->loadCredentials(baseUrl, user, password)) {
                ////qCDebug(ATTICA) << "ProviderManager::authenticate: loading authentication";
                auth->setUser(user);
                auth->setPassword(password);
                return;
            }
        }
    }

    if (!d->m_authenticationSuppressed && d->m_internals->askForCredentials(baseUrl, user, password)) {
        ////qCDebug(ATTICA) << "ProviderManager::authenticate: asking internals for new credentials";
        //auth->setUser(user);
        //auth->setPassword(password);
        return;
    }

    qWarning() << "ProviderManager::authenticate: No authentication credentials provided, aborting." << reply->url().toString();
    emit authenticationCredentialsMissing(d->m_providers.value(baseUrl));
    reply->abort();
}

void ProviderManager::proxyAuthenticationRequired(const QNetworkProxy &proxy, QAuthenticator *authenticator)
{
    Q_UNUSED(proxy)
    Q_UNUSED(authenticator)
}

void ProviderManager::initNetworkAccesssManager()
{
    connect(d->m_internals->nam(), SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)), this, SLOT(authenticate(QNetworkReply*,QAuthenticator*)));
    connect(d->m_internals->nam(), SIGNAL(proxyAuthenticationRequired(QNetworkProxy,QAuthenticator*)), this, SLOT(proxyAuthenticationRequired(QNetworkProxy,QAuthenticator*)));
}

