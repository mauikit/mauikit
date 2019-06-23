/*
    This file is part of KDE.

    Copyright (c) 2011 Dan Leinir Turthra Jensen <admin@leinir.dk>

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

#include "publisherfield.h"

using namespace Attica;

class PublisherField::Private : public QSharedData
{
public:
    QString name;
    QString type;
    QString data;

    Private()
    {
    }
};

PublisherField::PublisherField()
    : d(new Private)
{
}

PublisherField::PublisherField(const PublisherField &other)
    : d(other.d)
{
}

PublisherField &PublisherField::operator=(const Attica::PublisherField &other)
{
    d = other.d;
    return *this;
}

PublisherField::~PublisherField()
{
}

void PublisherField::setName(const QString &value)
{
    d->name = value;
}

QString PublisherField::name() const
{
    return d->name;
}

void PublisherField::setType(const QString &value)
{
    d->type = value;
}

QString PublisherField::type() const
{
    return d->type;
}

void PublisherField::setData(const QString &value)
{
    d->data = value;
}

QString PublisherField::data() const
{
    return d->data;
}

bool PublisherField::isValid() const
{
    return true;
}
