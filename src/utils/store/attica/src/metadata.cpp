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

#include "metadata.h"

#include <QSharedData>

using namespace Attica;

class Metadata::Private : public QSharedData
{
public:
    Error error;

    /// The status of the job, for example "Ok"
    QString statusString;
    /// The status as int, for easier interpretation.
    /// 100 means "Ok", for other codes refer to http://www.freedesktop.org/wiki/Specifications/open-collaboration-services
    int statusCode;

    /// An optional additional message from the server
    QString message;

    /// The number of items returned by this job (only relevant for list jobs)
    int totalItems;
    /// The number of items per page the server was asked for
    int itemsPerPage;

    QString resultingId;

    Private()
    // values that make sense for single item jobs
        : error(NoError)
        , statusCode(0)
        , totalItems(1)
        , itemsPerPage(1)
    {
    }
};

Metadata::Metadata()
    : d(new Private)
{
}

Metadata::~Metadata()
{
}

Metadata::Metadata(const Attica::Metadata &other)
    : d(other.d)
{
}

Metadata &Metadata::operator=(const Attica::Metadata &other)
{
    d = other.d;
    return *this;
}

Metadata::Error Metadata::error() const
{
    return d->error;
}

void Metadata::setError(Metadata::Error error)
{
    d->error = error;
}

QString Metadata::message()
{
    return d->message;
}

void Metadata::setMessage(const QString &message)
{
    d->message = message;
}

QString Metadata::resultingId()
{
    return d->resultingId;
}

void Metadata::setResultingId(const QString &id)
{
    d->resultingId = id;
}

int Metadata::statusCode() const
{
    return d->statusCode;
}

void Metadata::setStatusCode(int code)
{
    d->statusCode = code;
}

QString Metadata::statusString() const
{
    return d->statusString;
}

void Metadata::setStatusString(const QString &status)
{
    d->statusString = status;
}

int Metadata::totalItems()
{
    return d->totalItems;
}

void Metadata::setTotalItems(int items)
{
    d->totalItems = items;
}

int Metadata::itemsPerPage()
{
    return d->itemsPerPage;
}

void Metadata::setItemsPerPage(int itemsPerPage)
{
    d->itemsPerPage = itemsPerPage;
}

