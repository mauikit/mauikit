/*
    This file is part of KDE.

    Copyright (c) 2018 Ralf Habacker <ralf.habacker@freenet.de>

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

#include "config.h"

using namespace Attica;

class Config::Private : public QSharedData {
    public:
        QString m_version;
        QString m_website;
        QString m_host;
        QString m_contact;
        bool m_ssl;

        Private()
            : m_ssl(false)
        {
        }
};


Config::Config()
    : d(new Private)
{
}

Config::Config(const Attica::Config& other)
    : d(other.d)
{
}

Config& Config::operator=(const Attica::Config & other)
{
    d = other.d;
    return *this;
}

Config::~Config()
{
}

QString Attica::Config::version() const
{
    return d->m_version;
}

QString Config::website() const
{
    return d->m_website;
}

QString Config::host() const
{
    return d->m_host;
}

QString Config::contact() const
{
    return d->m_contact;
}

bool Config::ssl() const
{
    return d->m_ssl;
}

bool Config::isValid() const
{
  return !(d->m_version.isEmpty());
}

void Config::setContact(const QString &contact)
{
    d->m_contact = contact;
}

void Config::setVersion(const QString &version)
{
    d->m_version = version;
}

void Config::setWebsite(const QString &website)
{
    d->m_website = website;
}

void Config::setHost(const QString &host)
{
    d->m_host = host;
}

void Config::setSsl(bool ssl)
{
    d->m_ssl = ssl;
}
