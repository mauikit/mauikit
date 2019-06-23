/*
    This file is part of KDE.

    Copyright (c) 1999 Matthias Kalle Dalheimer <kalle@kde.org>
    Copyright (c) 2000 Charles Samuels <charles@kde.org>
    Copyright (c) 2005 Joseph Wenninger <kde@jowenn.at>
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

#include "postfiledata.h"

#include <QDebug>
#include <QDateTime>

namespace Attica
{
class PostFileDataPrivate
{
public:
    QByteArray buffer;
    QByteArray boundary;
    QUrl url;
    bool finished;

    PostFileDataPrivate()
        : finished(false)
    {
    }
};

PostFileData::PostFileData(const QUrl &url)
    : d(new PostFileDataPrivate)
{
    d->url = url;
    qsrand(QTime::currentTime().secsTo(QTime(0, 0, 0)));
    d->boundary = "----------" + randomString(42 + 13).toLatin1();
}

PostFileData::~PostFileData()
{
    delete d;
}

QString PostFileData::randomString(int length)
{
    if (length <= 0) {
        return QString();
    }

    QString str; str.resize(length);
    int i = 0;
    while (length--) {
        int r = qrand() % 62;
        r += 48;
        if (r > 57) {
            r += 7;
        }
        if (r > 90) {
            r += 6;
        }
        str[i++] =  char(r);
    }
    return str;
}

void PostFileData::addArgument(const QString &key, const QString &value)
{
    if (d->finished) {
        qWarning() << "PostFileData::addFile: should not add data after calling request() or data()";
    }
    QByteArray data(
        "--" + d->boundary + "\r\n"
        "Content-Disposition: form-data; name=\"" + key.toLatin1() +
        "\"\r\n\r\n" + value.toUtf8() + "\r\n");

    d->buffer.append(data);
}

/*
void PostFileData::addFile(const QString& fileName, QIODevice* file, const QString& mimeType)
{
    if (d->finished) {
        qCDebug(ATTICA) << "PostFileData::addFile: should not add data after calling request() or data()";
    }
    QByteArray data = file->readAll();
    addFile(fileName, data, mimeType);
}
*/

void PostFileData::addFile(const QString &fileName, const QByteArray &file, const QString &mimeType, const QString &fieldName)
{
    if (d->finished) {
        qWarning() << "PostFileData::addFile: should not add data after calling request() or data()";
    }

    QByteArray data(
        "--" + d->boundary + "\r\n"
        "Content-Disposition: form-data; name=\"");
    data.append(fieldName.toLatin1());
    data.append("\"; filename=\"" + fileName.toUtf8()
                + "\"\r\nContent-Type: " + mimeType.toLatin1() + "\r\n\r\n");

    d->buffer.append(data);
    d->buffer.append(file + QByteArray("\r\n"));
}

QNetworkRequest PostFileData::request()
{
    if (!d->finished) {
        finish();
    }
    QNetworkRequest request;
    request.setUrl(d->url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, QByteArray("multipart/form-data; boundary=" + d->boundary));
    request.setHeader(QNetworkRequest::ContentLengthHeader, d->buffer.length());
    return request;
}

QByteArray PostFileData::data()
{
    if (!d->finished) {
        finish();
    }
    return d->buffer;
}

void PostFileData::finish()
{
    Q_ASSERT(!d->finished);
    d->finished = true;
    d->buffer.append("--" + d->boundary + "--");
}

}
