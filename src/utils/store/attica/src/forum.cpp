/*
    This file is part of KDE.

    Copyright (c) 2011 Laszlo Papp <djszapi@archlinux.us>

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

#include "forum.h"

using namespace Attica;

class Forum::Private : public QSharedData
{
public:
    QString m_id;
    QString m_name;
    QString m_description;
    QDateTime m_date;
    QUrl m_icon;
    int m_childCount;
    int m_topics;
    QList<Forum> m_children;

    Private()
        : m_childCount(0),
          m_topics(0)
    {
    }
};

Forum::Forum()
    : d(new Private)
{
}

Forum::Forum(const Forum &other)
    : d(other.d)
{
}

Forum &Forum::operator=(const Attica::Forum &other)
{
    d = other.d;
    return *this;
}

Forum::~Forum()
{
}

void Forum::setId(const QString &id)
{
    d->m_id = id;
}

QString Forum::id() const
{
    return d->m_id;
}

void Forum::setName(const QString &name)
{
    d->m_name = name;
}

QString Forum::name() const
{
    return d->m_name;
}

void Forum::setDescription(const QString &description)
{
    d->m_description = description;
}

QString Forum::description() const
{
    return d->m_description;
}

void Forum::setDate(const QDateTime &date)
{
    d->m_date = date;
}

QDateTime Forum::date() const
{
    return d->m_date;
}

void Forum::setIcon(const QUrl &icon)
{
    d->m_icon = icon;
}

QUrl Forum::icon() const
{
    return d->m_icon;
}

void Forum::setChildCount(const int childCount)
{
    d->m_childCount = childCount;
}

int Forum::childCount() const
{
    return d->m_childCount;
}

void Forum::setChildren(QList<Forum> children)
{
    d->m_children = children;
}

QList<Forum> Forum::children() const
{
    return d->m_children;
}

void Forum::setTopics(const int topics)
{
    d->m_topics = topics;
}

int Forum::topics() const
{
    return d->m_topics;
}

bool Forum::isValid() const
{
    return !(d->m_id.isEmpty());
}
