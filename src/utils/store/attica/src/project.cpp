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

#include "project.h"

using namespace Attica;

class Project::Private : public QSharedData
{
public:
    QString m_id;
    QString m_name;
    QString m_version;
    QString m_license;
    QString m_url;
    QString m_summary;
    QString m_description;
    QStringList m_developers;
    QString m_requirements;
    QString m_specFile;

    QMap<QString, QString> m_extendedAttributes;

    Private()
    {
    }
};

Project::Project()
    : d(new Private)
{
}

Project::Project(const Project &other)
    : d(other.d)
{
}

Project &Project::operator=(const Attica::Project &other)
{
    d = other.d;
    return *this;
}

Project::~Project()
{
}

void Project::setId(const QString &u)
{
    d->m_id = u;
}

QString Project::id() const
{
    return d->m_id;
}

void Project::setName(const QString &name)
{
    d->m_name = name;
}

QString Project::name() const
{
    return d->m_name;
}

void Project::setVersion(const QString &name)
{
    d->m_version = name;
}

QString Project::version() const
{
    return d->m_version;
}

void Project::setLicense(const QString &name)
{
    d->m_license = name;
}

QString Project::license() const
{
    return d->m_license;
}

void Project::setUrl(const QString &name)
{
    d->m_url = name;
}

QString Project::url() const
{
    return d->m_url;
}

void Project::setSummary(const QString &name)
{
    d->m_summary = name;
}

QString Project::summary() const
{
    return d->m_summary;
}

void Project::setDescription(const QString &name)
{
    d->m_description = name;
}

QString Project::description() const
{
    return d->m_description;
}

void Project::setDevelopers(const QStringList &name)
{
    d->m_developers = name;
}

QStringList Project::developers() const
{
    return d->m_developers;
}

void Project::setRequirements(const QString &name)
{
    d->m_requirements = name;
}

QString Project::requirements() const
{
    return d->m_requirements;
}

void Project::setSpecFile(const QString &name)
{
    d->m_specFile = name;
}

QString Project::specFile() const
{
    return d->m_specFile;
}

void Project::addExtendedAttribute(const QString &key, const QString &value)
{
    d->m_extendedAttributes.insert(key, value);
}

QString Project::extendedAttribute(const QString &key) const
{
    return d->m_extendedAttributes.value(key);
}

QMap<QString, QString> Project::extendedAttributes() const
{
    return d->m_extendedAttributes;
}

bool Project::isValid() const
{
    return !(d->m_id.isEmpty());
}
