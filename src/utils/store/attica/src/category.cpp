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

#include "category.h"

#include <QString>
#include <QDebug>

using namespace Attica;

QDebug operator<<(QDebug s, const Attica::Category& cat)
{
    const QString name = cat.isValid() ? cat.name() : QStringLiteral("Invalid");
    s.nospace() << "Category(" << name << ')';
    return s.space();
}

class Category::Private : public QSharedData
{
public:
    QString m_id;
    QString m_name;
    QString m_displayName;
};

Category::Category() : d(new Private)
{
}

Category::Category(const Attica::Category &other)
    : d(other.d)
{
}

Category &Category::operator=(const Attica::Category &other)
{
    d = other.d;
    return *this;
}

Category::~Category()
{
}

void Category::setId(const QString &u)
{
    d->m_id = u;
}

QString Category::id() const
{
    return d->m_id;
}

void Category::setName(const QString &name)
{
    d->m_name = name;
}

QString Category::name() const
{
    return d->m_name;
}

void Category::setDisplayName(const QString &name)
{
    d->m_displayName = name;
}

QString Category::displayName() const
{
    return d->m_displayName;
}

bool Category::isValid() const
{
    return !(d->m_id.isEmpty());
}
