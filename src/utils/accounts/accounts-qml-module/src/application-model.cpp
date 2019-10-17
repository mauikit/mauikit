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

#include "debug.h"
#include "application-model.h"
#include "application.h"

#include <Accounts/Manager>
#include <QQmlEngine>

using namespace OnlineAccounts;

/*!
 * \qmltype ApplicationModel
 * \inqmlmodule Ubuntu.OnlineAccounts 0.1
 * \ingroup Ubuntu
 *
 * \brief A model of the applications using online accounts.
 *
 * The ApplicationModel is a model representing the applications using online
 * accounts installed on the system.
 *
 * In the current implementation, the model is valid only if its \l
 * ApplicationModel::service property is set to a valid service ID.
 *
 * The model defines the following roles:
 * \list
 * \li \c applicationId is the unique identifier of the application
 * \li \c displayName is the application display name
 * \li \c iconName is the name of the application icon
 * \li \c serviceUsage is a description of how the application uses the
 *     service; this is set to a valid value only if the \l
 *     ApplicationModel::service property is set to a valid service ID.
 * \li \c application is the Application object
 * \li \c translations, the localization domain for translating the
 * \c serviceUsage field
 * \endlist
 */

ApplicationModel::ApplicationModel(QObject *parent):
    QAbstractListModel(parent),
    manager(SharedManager::instance())
{
}

ApplicationModel::~ApplicationModel()
{
}

/*!
 * \qmlproperty int ApplicationModel::count
 * The number of items in the model.
 */
int ApplicationModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return applications.count();
}

/*!
 * \qmlproperty string ApplicationModel::service
 * If set, the model will list only those applications which can use this
 * specific service.
 */
void ApplicationModel::setService(const QString &serviceId)
{
    if (serviceId == m_service.name()) return;
    m_service = manager->service(serviceId);

    beginResetModel();
    qDeleteAll(applications);
    applications.clear();

    computeApplicationList();
    endResetModel();
    Q_EMIT serviceChanged();
}

QString ApplicationModel::service() const
{
    return m_service.name();
}

/*!
 * \qmlmethod variant ApplicationModel::get(int row, string roleName)
 *
 * Returns the data at \a row for the role \a roleName.
 */
QVariant ApplicationModel::get(int row, const QString &roleName) const
{
    int role = roleNames().key(roleName.toLatin1(), -1);
    return data(index(row), role);
}

QVariant ApplicationModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= applications.count())
        return QVariant();

    Application *application = applications.at(index.row());
    QVariant ret;

    switch (role) {
    case Qt::DisplayRole:
    case ApplicationIdRole:
        ret = application->name();
        break;
    case DisplayNameRole:
        ret = application->displayName();
        break;
    case IconNameRole:
        ret = application->iconName();
        break;
    case ServiceUsageRole:
        ret = application->serviceUsage(m_service);
        break;
    case ApplicationRole:
        QQmlEngine::setObjectOwnership(application, QQmlEngine::CppOwnership);
        ret = QVariant::fromValue<QObject*>(application);
        break;
    case TranslationsRole:
        ret = application->trCatalog();
        break;
    }

    return ret;
}

QHash<int, QByteArray> ApplicationModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty()) {
        roles[ApplicationIdRole] = "applicationId";
        roles[DisplayNameRole] = "displayName";
        roles[IconNameRole] = "iconName";
        roles[ServiceUsageRole] = "serviceUsage";
        roles[ApplicationRole] = "application";
        roles[TranslationsRole] = "translations";
    }
    return roles;
}

void ApplicationModel::computeApplicationList()
{
    if (!m_service.isValid()) return;

    Q_FOREACH(const Accounts::Application &app,
              manager->applicationList(m_service)) {
        applications.append(new Application(app, this));
    }
}
