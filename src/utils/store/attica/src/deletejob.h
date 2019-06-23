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

#ifndef ATTICA_DELETEJOB_H
#define ATTICA_DELETEJOB_H

#include <QNetworkRequest>

#ifndef STATIC_MAUIKIT
#include "attica_export.h"
#endif

#include "atticabasejob.h"

namespace Attica
{

#ifndef STATIC_MAUIKIT
class ATTICA_EXPORT DeleteJob : public Attica::BaseJob
#else
class DeleteJob : public Attica::BaseJob
#endif
{
    Q_OBJECT

protected:
    DeleteJob(PlatformDependent *internals, const QNetworkRequest &request);

private:
    QNetworkReply *executeRequest() override;
    const QNetworkRequest m_request;
};

}

#endif
