/*
    This file is part of KDE.

    Copyright 2010 Sebastian Kügler <sebas@kde.org>

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

#include "publisher.h"

using namespace Attica;

class Publisher::Private : public QSharedData
{
public:
    QString id;
    QString name;
    QString url;
    QList<Field> fields;
    QList<Target> targets;

    Private()
    {
    }
};

Publisher::Publisher()
    : d(new Private)
{
}

Publisher::Publisher(const Publisher &other)
    : d(other.d)
{
}

Publisher &Publisher::operator=(const Attica::Publisher &other)
{
    d = other.d;
    return *this;
}

Publisher::~Publisher()
{
}

void Publisher::setId(const QString &u)
{
    d->id = u;
}

QString Publisher::id() const
{
    return d->id;
}

void Publisher::setName(const QString &u)
{
    d->name = u;
}

QString Publisher::name() const
{
    return d->name;
}

void Publisher::addField(const Field &t)
{
    d->fields << t;
}

QList<Field> Publisher::fields() const
{
    return d->fields;
}

void Publisher::setUrl(const QString &u)
{
    d->url = u;
}

QString Publisher::url() const
{
    return d->url;
}

void Publisher::addTarget(const Attica::Target &t)
{
    d->targets << t;
}

QList<Target> Publisher::targets() const
{
    return d->targets;
}

bool Publisher::isValid() const
{
    return !(d->id.isEmpty());
}
