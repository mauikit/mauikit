/*
    This file is part of KDE.

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

#ifndef POSTFILEDATA_H
#define POSTFILEDATA_H

#include <QByteArray>
#include <QIODevice>
#include <QNetworkRequest>

namespace Attica
{
class PostFileDataPrivate;

class PostFileData
{
public:
    /**
     * Prepare a QNetworkRequest and QByteArray for sending a HTTP POST.
     * Parameters and files can be added with addArgument() and addFile()
     * Do not add anything after calling request or data for the first time.
     */
    PostFileData(const QUrl &url);
    ~PostFileData();

    void addArgument(const QString &key, const QString &value);
    void addFile(const QString &fileName, QIODevice *file, const QString &mimeType);
    void addFile(const QString &fileName, const QByteArray &file, const QString &mimeType, const QString &fieldName = QLatin1String("localfile"));

    QNetworkRequest request();
    QByteArray data();

private:
    void finish();
    QString randomString(int length);
    PostFileDataPrivate *d;
    Q_DISABLE_COPY(PostFileData)
};

}

#endif // POSTFILEDATA_H
