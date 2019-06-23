/*
    This file is part of KDE.

    Copyright (c) 2010 Intel Corporation
    Author: Mateu Batle Sastre <mbatle@collabora.co.uk>

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

#include "comment.h"

#include <QMap>

using namespace Attica;

QString Comment::commentTypeToString(const Comment::Type type)
{
    switch (type) {
    case ContentComment:
        return QLatin1String("1");
    case ForumComment:
        return QLatin1String("4");
    case KnowledgeBaseComment:
        return QLatin1String("7");
    case EventComment:
        return QLatin1String("8");
    }

    Q_ASSERT(false);
    return QString();
}

class Comment::Private : public QSharedData
{
public:
    QString m_id;
    QString m_subject;
    QString m_text;
    int m_childCount;
    QString m_user;
    QDateTime m_date;
    int m_score;
    QList<Comment> m_children;

    Private()
        : m_childCount(0),
          m_score(0)
    {
    }
};

Comment::Comment()
    : d(new Private)
{
}

Comment::Comment(const Comment &other)
    : d(other.d)
{
}

Comment &Comment::operator=(const Attica::Comment &other)
{
    d = other.d;
    return *this;
}

Comment::~Comment()
{
}

void Comment::setId(const QString &id)
{
    d->m_id = id;
}

QString Comment::id() const
{
    return d->m_id;
}

void Comment::setSubject(const QString &subject)
{
    d->m_subject = subject;
}

QString Comment::subject() const
{
    return d->m_subject;
}

void Comment::setText(const QString &text)
{
    d->m_text = text;
}

QString Comment::text() const
{
    return d->m_text;
}

void Comment::setChildCount(const int childCount)
{
    d->m_childCount = childCount;
}

int Comment::childCount() const
{
    return d->m_childCount;
}

void Comment::setUser(const QString &user)
{
    d->m_user = user;
}

QString Comment::user() const
{
    return d->m_user;
}

void Comment::setDate(const QDateTime &date)
{
    d->m_date = date;
}

QDateTime Comment::date() const
{
    return d->m_date;
}

void Comment::setScore(const int score)
{
    d->m_score = score;
}

int Comment::score() const
{
    return d->m_score;
}

void Comment::setChildren(QList<Comment> children)
{
    d->m_children = children;
}

QList<Comment> Comment::children() const
{
    return d->m_children;
}

bool Comment::isValid() const
{
    return !(d->m_id.isEmpty());
}
