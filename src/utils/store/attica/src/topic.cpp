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

#include "topic.h"

using namespace Attica;

class Topic::Private : public QSharedData
{
public:
    QString m_id;
    QString m_forumId;
    QString m_user;
    QDateTime m_date;
    QString m_subject;
    QString m_content;
    int m_comments;

    Private()
        : m_comments(0)
    {
    }
};

Topic::Topic()
    : d(new Private)
{
}

Topic::Topic(const Topic &other)
    : d(other.d)
{
}

Topic &Topic::operator=(const Topic &other)
{
    d = other.d;
    return *this;
}

Topic::~Topic()
{
}

void Topic::setId(const QString &id)
{
    d->m_id = id;
}

QString Topic::id() const
{
    return d->m_id;
}

void Topic::setForumId(const QString &forumId)
{
    d->m_forumId = forumId;
}

QString Topic::forumId() const
{
    return d->m_forumId;
}

void Topic::setUser(const QString &user)
{
    d->m_user = user;
}

QString Topic::user() const
{
    return d->m_user;
}

void Topic::setDate(const QDateTime &date)
{
    d->m_date = date;
}

QDateTime Topic::date() const
{
    return d->m_date;
}

void Topic::setSubject(const QString &subject)
{
    d->m_subject = subject;
}

QString Topic::subject() const
{
    return d->m_subject;
}

void Topic::setContent(const QString &content)
{
    d->m_content = content;
}

QString Topic::content() const
{
    return d->m_content;
}

void Topic::setComments(const int comments)
{
    d->m_comments = comments;
}

int Topic::comments() const
{
    return d->m_comments;
}

bool Topic::isValid() const
{
    return !(d->m_id.isEmpty());
}

