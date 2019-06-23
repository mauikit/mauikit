/*
    This file is part of KDE.

    Copyright (c) 2009 Frederik Gladhorn <gladhorn@kde.org>
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

#include "itemjob.h"

using namespace Attica;

template <class T>
ItemJob<T>::ItemJob(PlatformDependent *internals, const QNetworkRequest &request)
    : GetJob(internals, request)
{
}

template <class T>
void ItemJob<T>::parse(const QString &xml)
{
    typename T::Parser p;
    m_item = p.parse(xml);
    setMetadata(p.metadata());
}

template <class T>
T ItemJob<T>::result() const
{
    return m_item;
}

template <class T>
ItemDeleteJob<T>::ItemDeleteJob(PlatformDependent *internals, const QNetworkRequest &request)
    : DeleteJob(internals, request)
{
}

template <class T>
void ItemDeleteJob<T>::parse(const QString &xml)
{
    typename T::Parser p;
    m_item = p.parse(xml);
    setMetadata(p.metadata());
}

template <class T>
T ItemDeleteJob<T>::result() const
{
    return m_item;
}

template <class T>
ItemPostJob<T>::ItemPostJob(PlatformDependent *internals, const QNetworkRequest &request, QIODevice *data)
    : PostJob(internals, request, data)
{
}

template <class T>
ItemPostJob<T>::ItemPostJob(PlatformDependent *internals, const QNetworkRequest &request, const StringMap &parameters)
    : PostJob(internals, request, parameters)
{
}

template <class T>
void ItemPostJob<T>::parse(const QString &xml)
{
    typename T::Parser p;
    m_item = p.parse(xml);
    setMetadata(p.metadata());
}

template <class T>
T ItemPostJob<T>::result() const
{
    return m_item;
}

template <class T>
ItemPutJob<T>::ItemPutJob(PlatformDependent *internals, const QNetworkRequest &request, QIODevice *data)
    : PutJob(internals, request, data)
{
}

template <class T>
ItemPutJob<T>::ItemPutJob(PlatformDependent *internals, const QNetworkRequest &request, const StringMap &parameters)
    : PutJob(internals, request, parameters)
{
}

template <class T>
void ItemPutJob<T>::parse(const QString &xml)
{
    typename T::Parser p;
    m_item = p.parse(xml);
    setMetadata(p.metadata());
}

template <class T>
T ItemPutJob<T>::result() const
{
    return m_item;
}
