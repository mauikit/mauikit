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


#include "application.h"
#include "debug.h"

using namespace OnlineAccounts;

/*!
 * \qmltype Application
 * \inqmlmodule Ubuntu.OnlineAccounts 0.1
 * \ingroup Ubuntu
 *
 * \brief Represents a client application of Online Accounts.
 *
 * The Application element represents an application using online accounts.
 * Currently, instances of this object cannot be created directly, but are
 * instantiated by the \l ApplicationModel element.
 */
Application::Application(const Accounts::Application &application,
                         QObject *parent):
    QObject(parent),
    Accounts::Application(application)
{
}

Application::~Application()
{
}

/*!
 * \qmlproperty string Application::applicationId
 * Unique identifier for this application.
 */

/*!
 * \qmlproperty string Application::description
 * Description of the application.
 */

/*!
 * \qmlmethod string Application::serviceUsage(Service service)
 *
 * Returns a textual description of how the application can make use of \a
 * service.
 */
QString Application::serviceUsage(const Accounts::Service &service)
{
    return Accounts::Application::serviceUsage(service);
}
