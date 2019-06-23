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

#include "buildservice.h"

using namespace Attica;

class BuildService::Private : public QSharedData
{
public:
    QString id;
    QString name;
    QString url;
    //QStringList targets;
    QList<Target> targets;

    Private()
    {
    }
};

BuildService::BuildService()
    : d(new Private)
{
}

BuildService::BuildService(const BuildService &other)
    : d(other.d)
{
}

BuildService &BuildService::operator=(const Attica::BuildService &other)
{
    d = other.d;
    return *this;
}

BuildService::~BuildService()
{
}

void BuildService::setId(const QString &u)
{
    d->id = u;
}

QString BuildService::id() const
{
    return d->id;
}

void BuildService::setName(const QString &u)
{
    d->name = u;
}

QString BuildService::name() const
{
    return d->name;
}

void BuildService::addTarget(const Target &t)
{
    d->targets << t;
}

QList<Target> BuildService::targets() const
{
    return d->targets;
}

void BuildService::setUrl(const QString &u)
{
    d->url = u;
}

QString BuildService::url() const
{
    return d->url;
}

bool BuildService::isValid() const
{
    return !(d->id.isEmpty());
}
