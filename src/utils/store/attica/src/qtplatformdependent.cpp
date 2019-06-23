/*
    This file is part of KDE.

    Copyright (c) 2009 Eckhart Wörner <ewoerner@kde.org>
    Copyright (c) 2011 Laszlo Papp <djszapi@archlinux.us>
    Copyright (c) 2012 Jeff Mitchell <mitchell@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Fo1undation; either
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

#include "qtplatformdependent_p.h"

#include <QUrl>
#include <QStringList>
#include <QDebug>

using namespace Attica;

QtPlatformDependent::QtPlatformDependent()
{
    m_threadNamHash[ QThread::currentThread() ] = new QNetworkAccessManager();
    m_ourNamSet.insert(QThread::currentThread());
}

QtPlatformDependent::~QtPlatformDependent()
{
    QThread *currThread = QThread::currentThread();
    if (m_threadNamHash.contains(currThread)) {
        if (m_ourNamSet.contains(currThread)) {
            delete m_threadNamHash[ currThread ];
        }
        m_threadNamHash.remove(currThread);
        m_ourNamSet.remove(currThread);
    }
}

void QtPlatformDependent::setNam(QNetworkAccessManager *nam)
{
    if (!nam) {
        return;
    }

    QMutexLocker l(&m_accessMutex);
    QThread *currThread = QThread::currentThread();
    QNetworkAccessManager *oldNam = nullptr;
    if (m_threadNamHash.contains(currThread) && m_ourNamSet.contains(currThread)) {
        oldNam = m_threadNamHash[ currThread ];
    }

    if (oldNam == nam) {
        // If we're being passed back our own NAM, assume they want to
        // ensure that we don't delete it out from under them
        m_ourNamSet.remove(currThread);
        return;
    }

    m_threadNamHash[ currThread ] = nam;
    m_ourNamSet.remove(currThread);

    if (oldNam) {
        delete oldNam;
    }
}

QNetworkAccessManager *QtPlatformDependent::nam()
{
    QMutexLocker l(&m_accessMutex);
    QThread *currThread = QThread::currentThread();
    if (!m_threadNamHash.contains(currThread)) {
        QNetworkAccessManager *newNam = new QNetworkAccessManager();
        m_threadNamHash[ currThread ] = newNam;
        m_ourNamSet.insert(currThread);
        return newNam;
    }

    return m_threadNamHash[ currThread ];
}

// TODO actually save and restore providers!
QList<QUrl> Attica::QtPlatformDependent::getDefaultProviderFiles() const
{
    return QList<QUrl>();
}

void QtPlatformDependent::addDefaultProviderFile(const QUrl &)
{
    qWarning() << "attica-qt does not support default providers yet";
}

void QtPlatformDependent::removeDefaultProviderFile(const QUrl &)
{
}

void QtPlatformDependent::enableProvider(const QUrl &baseUrl, bool enabled) const
{
    Q_UNUSED(baseUrl)
    Q_UNUSED(enabled)
    qWarning() << "attica-qt does not support disabling of providers yet";
}

bool QtPlatformDependent::isEnabled(const QUrl &baseUrl) const
{
    Q_UNUSED(baseUrl)
    return true;
}

QNetworkReply *QtPlatformDependent::post(const QNetworkRequest &request, const QByteArray &data)
{
    return nam()->post(request, data);
}

QNetworkReply *QtPlatformDependent::post(const QNetworkRequest &request, QIODevice *data)
{
    return nam()->post(request, data);
}

QNetworkReply *QtPlatformDependent::put(const QNetworkRequest &request, const QByteArray &data)
{
    return nam()->put(request, data);
}

QNetworkReply *QtPlatformDependent::put(const QNetworkRequest &request, QIODevice *data)
{
    return nam()->put(request, data);
}

QNetworkReply *QtPlatformDependent::get(const QNetworkRequest &request)
{
    return nam()->get(request);
}

QNetworkReply *QtPlatformDependent::deleteResource(const QNetworkRequest &request)
{
    return nam()->deleteResource(request);
}

bool QtPlatformDependent::hasCredentials(const QUrl &baseUrl) const
{
    return m_passwords.contains(baseUrl.toString());
}

bool QtPlatformDependent::saveCredentials(const QUrl &baseUrl, const QString &user, const QString &password)
{
    m_passwords[baseUrl.toString()] = QPair<QString, QString> (user, password);
    return true;
}

bool QtPlatformDependent::loadCredentials(const QUrl &baseUrl, QString &user, QString &password)
{
    if (!hasCredentials(baseUrl)) {
        return false;
    }
    QPair<QString, QString> userPass = m_passwords.value(baseUrl.toString());
    user = userPass.first;
    password = userPass.second;
    return true;
}

bool Attica::QtPlatformDependent::askForCredentials(const QUrl &baseUrl, QString &user, QString &password)
{
    Q_UNUSED(baseUrl)
    Q_UNUSED(user)
    Q_UNUSED(password)
    return false;
}

