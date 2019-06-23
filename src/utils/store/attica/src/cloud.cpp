/*
    This file is part of KDE.

    Copyright (c) 2012 Laszlo Papp <lpapp@kde.org>

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

#include "cloud.h"

using namespace Attica;

class Cloud::Private : public QSharedData
{
public:
    QString m_name;
    QString m_url;
    QUrl m_icon;
    qulonglong m_quota;
    qulonglong m_free;
    qulonglong m_used;
    float m_relative;
    QString m_key;
};

Cloud::Cloud()
    : d(new Private)
{
}

Cloud::Cloud(const Attica::Cloud &other)
    : d(other.d)
{
}

Cloud &Cloud::operator=(const Attica::Cloud &other)
{
    d = other.d;
    return *this;
}

Cloud::~Cloud()
{
}

void Cloud::setName(const QString &name)
{
    d->m_name = name;
}

QString Cloud::name() const
{
    return d->m_name;
}

void Cloud::setUrl(const QString &url)
{
    d->m_url = url;
}

QString Cloud::url() const
{
    return d->m_url;
}

void Cloud::setIcon(const QUrl &icon)
{
    d->m_icon = icon;
}

QUrl Cloud::icon() const
{
    return d->m_icon;
}

void Cloud::setQuota(qulonglong quota)
{
    d->m_quota = quota;
}

qulonglong Cloud::quota() const
{
    return d->m_quota;
}

void Cloud::setFree(qulonglong free)
{
    d->m_free = free;
}

qulonglong Cloud::free() const
{
    return d->m_free;
}

void Cloud::setUsed(qulonglong used)
{
    d->m_used = used;
}

qulonglong Cloud::used() const
{
    return d->m_used;
}

void Cloud::setRelative(float relative)
{
    d->m_relative = relative;
}

float Cloud::relative() const
{
    return d->m_relative;
}

void Cloud::setKey(const QString &key)
{
    d->m_key = key;
}

QString Cloud::key() const
{
    return d->m_key;
}
