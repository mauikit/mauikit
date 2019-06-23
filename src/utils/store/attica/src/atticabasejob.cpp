/*
    This file is part of KDE.

    Copyright (c) 2008 Cornelius Schumacher <schumacher@kde.org>

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

#include "atticabasejob.h"

#include <QDebug>
#include <QTimer>
#include <QNetworkReply>
#include <QAuthenticator>

#ifndef STATIC_MAUIKIT
#include <attica_debug.h>
#endif

#include "atticautils.h"
#include "platformdependent.h"

using namespace Attica;

class BaseJob::Private
{
public:
    Metadata m_metadata;
    PlatformDependent *m_internals;
    QNetworkReply *m_reply;

    Private(PlatformDependent *internals)
        : m_internals(internals), m_reply(nullptr)
    {
    }

    bool redirection(QUrl &newUrl) const
    {
        if (m_reply == nullptr || m_reply->error() != QNetworkReply::NoError) {
            return false;
        }

        int httpStatusCode = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (httpStatusCode == 301 || // Moved Permanently
                httpStatusCode == 302 || // Found
                httpStatusCode == 303 || // See Other
                httpStatusCode == 307) { // Temporary Redirect
            QNetworkRequest request = m_reply->request();
            QUrl redirectUrl(m_reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl());
            if (redirectUrl.isRelative()) {
                QUrl baseUrl(request.url());
                newUrl = baseUrl.resolved(redirectUrl);
//                //qCDebug(ATTICA) << "resolving relative URL redirection to" << newUrl.toString();
            } else {
                newUrl = redirectUrl;
//                //qCDebug(ATTICA) << "resolving absolute URL redirection to" << newUrl.toString();
            }
            return true;
        }

        return false;
    }
};

BaseJob::BaseJob(PlatformDependent *internals)
    : d(new Private(internals))
{
}

BaseJob::~BaseJob()
{
    delete d;
}

void BaseJob::dataFinished()
{
    if (!d->m_reply) {
        return;
    }

    bool error = (d->m_reply->error() != QNetworkReply::NoError);

    // handle redirections automatically
    QUrl newUrl;
    if (d->redirection(newUrl)) {
        ////qCDebug(ATTICA) << "BaseJob::dataFinished" << newUrl;
        QNetworkRequest request = d->m_reply->request();
        QNetworkAccessManager::Operation operation = d->m_reply->operation();
        if (newUrl.isValid() && operation == QNetworkAccessManager::GetOperation) {
            d->m_reply->deleteLater();
            // reissue same request with different Url
            request.setUrl(newUrl);
            d->m_reply = internals()->get(request);
            connect(d->m_reply, SIGNAL(finished()), SLOT(dataFinished()));
            return;
        } else {
            error = true;
        }
    }

    if (!error) {
        QByteArray data = d->m_reply->readAll();
        ////qCDebug(ATTICA) << "XML Returned:\n" << data;
        parse(QString::fromUtf8(data.constData()));
        if (d->m_metadata.statusCode() == 100) {
            d->m_metadata.setError(Metadata::NoError);
        } else {
            d->m_metadata.setError(Metadata::OcsError);
        }
    } else {
        d->m_metadata.setError(Metadata::NetworkError);
        d->m_metadata.setStatusCode(d->m_reply->error());
        d->m_metadata.setStatusString(d->m_reply->errorString());
    }
    emit finished(this);

    d->m_reply->deleteLater();
    deleteLater();
}

void BaseJob::start()
{
    QTimer::singleShot(0, this, SLOT(doWork()));
}

void BaseJob::doWork()
{
    d->m_reply = executeRequest();
    //qCDebug(ATTICA) << "executing" << Utils::toString(d->m_reply->operation()) << "request for" << d->m_reply->url();
    connect(d->m_reply, SIGNAL(finished()), SLOT(dataFinished()));
    connect(d->m_reply->manager(), SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)),
            this, SLOT(authenticationRequired(QNetworkReply*,QAuthenticator*)));
    connect(d->m_reply, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error),
      [](QNetworkReply::NetworkError code){
          //qCDebug(ATTICA) << "error found" << code;
    });
}

void BaseJob::authenticationRequired(QNetworkReply *reply, QAuthenticator *auth)
{
    auth->setUser(reply->request().attribute((QNetworkRequest::Attribute) BaseJob::UserAttribute).toString());
    auth->setPassword(reply->request().attribute((QNetworkRequest::Attribute) BaseJob::PasswordAttribute).toString());
}

void BaseJob::abort()
{
    if (d->m_reply) {
        d->m_reply->abort();
        d->m_reply->deleteLater();
    }
    deleteLater();
}

PlatformDependent *BaseJob::internals()
{
    return d->m_internals;
}

Metadata BaseJob::metadata() const
{
    return d->m_metadata;
}

void BaseJob::setMetadata(const Attica::Metadata &data) const
{
    d->m_metadata = data;
}

