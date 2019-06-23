/*
    This file is part of KDE.

    Copyright (c) Martin Sandsmark <martin.sandsmark@kde.org>

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

#include "privatedata.h"

#include <QStringList>

using namespace Attica;

class PrivateData::Private : public QSharedData
{
public:
    QMap<QString, QString> m_attributes;
    QMap<QString, QDateTime> m_attributesTimestamp;

    Provider *m_provider;

    Private()
        : m_provider(nullptr)
    {
    }
};

PrivateData::PrivateData()
    : d(new Private)
{
}

PrivateData::PrivateData(const PrivateData &other)
    : d(other.d)
{
}

PrivateData &PrivateData::operator=(const Attica::PrivateData &other)
{
    d = other.d;
    return *this;
}

PrivateData::~PrivateData()
{
}

void PrivateData::setAttribute(const QString &key, const QString &value)
{
    d->m_attributes[key] = value;
    d->m_attributesTimestamp[key] = QDateTime::currentDateTime();
}

QString PrivateData::attribute(const QString &key) const
{
    return d->m_attributes[key];
}

QDateTime PrivateData::timestamp(const QString &key) const
{
    return d->m_attributesTimestamp[key];
}

QStringList PrivateData::keys() const
{
    return d->m_attributes.keys();
}

void PrivateData::setTimestamp(const QString &key, const QDateTime &when)
{
    d->m_attributesTimestamp[key] = when;
}

