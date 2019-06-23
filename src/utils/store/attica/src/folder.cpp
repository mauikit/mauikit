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

#include "folder.h"

using namespace Attica;

class Folder::Private : public QSharedData
{
public:
    QString m_id;
    QString m_name;
    int m_messageCount;
    QString m_type;

    Private()
        : m_messageCount(0)
    {
    }
};

Folder::Folder()
    : d(new Private)
{
}

Folder::Folder(const Folder &other)
    : d(other.d)
{
}

Folder &Folder::operator=(const Folder &other)
{
    d = other.d;
    return *this;
}

Folder::~Folder()
{
}

void Folder::setId(const QString &u)
{
    d->m_id = u;
}

QString Folder::id() const
{
    return d->m_id;
}

void Folder::setName(const QString &name)
{
    d->m_name = name;
}

QString Folder::name() const
{
    return d->m_name;
}

void Folder::setMessageCount(int c)
{
    d->m_messageCount = c;
}

int Folder::messageCount() const
{
    return d->m_messageCount;
}

void Folder::setType(const QString &v)
{
    d->m_type = v;
}

QString Folder::type() const
{
    return d->m_type;
}

bool Folder::isValid() const
{
    return !(d->m_id.isEmpty());
}
