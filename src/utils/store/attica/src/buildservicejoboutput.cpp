/*
    This file is part of KDE.

    Copyright 2010 Dan Leinir Turthra Jensen <admin@leinir.dk>

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

#include "buildservicejoboutput.h"

using namespace Attica;

class BuildServiceJobOutput::Private : public QSharedData
{
public:
    QString output;

    Private()
    {
    }
};

BuildServiceJobOutput::BuildServiceJobOutput()
    : d(new Private)
{
}

BuildServiceJobOutput::BuildServiceJobOutput(const BuildServiceJobOutput &other)
    : d(other.d)
{
}

BuildServiceJobOutput &BuildServiceJobOutput::operator=(const Attica::BuildServiceJobOutput &other)
{
    d = other.d;
    return *this;
}

BuildServiceJobOutput::~BuildServiceJobOutput()
{
}

void BuildServiceJobOutput::setOutput(const QString &output)
{
    d->output = output;
}

QString BuildServiceJobOutput::output() const
{
    return d->output;
}

bool BuildServiceJobOutput::isValid() const
{
    return !(d->output.isNull());
}
