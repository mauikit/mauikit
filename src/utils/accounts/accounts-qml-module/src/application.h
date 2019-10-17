/*
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Alberto Mardegan <alberto.mardegan@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.1.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ONLINE_ACCOUNTS_APPLICATION_H
#define ONLINE_ACCOUNTS_APPLICATION_H

#include <QObject>

#include <Accounts/Application>

namespace OnlineAccounts {

class Application: public QObject, public Accounts::Application
{
    Q_OBJECT
    Q_PROPERTY(QString applicationId READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)

public:
    Application(const Accounts::Application &application, QObject *parent = 0);
    ~Application();

    Q_INVOKABLE QString serviceUsage(const Accounts::Service &service);
};

}; // namespace

#endif // ONLINE_ACCOUNTS_APPLICATION_H
