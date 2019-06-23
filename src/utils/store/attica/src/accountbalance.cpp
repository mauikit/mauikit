/*
    Copyright (C) 2009 Frederik Gladhorn <gladhorn@kde.org>

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

#include "accountbalance.h"

using namespace Attica;

class AccountBalance::Private : public QSharedData
{
public:
    QString balance;
    QString currency;
};

AccountBalance::AccountBalance()
    : d(new Private)
{
}

AccountBalance::AccountBalance(const Attica::AccountBalance &other)
    : d(other.d)
{
}

AccountBalance &AccountBalance::operator=(const Attica::AccountBalance &other)
{
    d = other.d;
    return *this;
}

AccountBalance::~AccountBalance()
{}

void AccountBalance::setBalance(const QString &balance)
{
    d->balance = balance;
}

QString AccountBalance::balance() const
{
    return d->balance;
}

void AccountBalance::setCurrency(const QString &currency)
{
    d->currency = currency;
}

QString AccountBalance::currency() const
{
    return d->currency;
}
