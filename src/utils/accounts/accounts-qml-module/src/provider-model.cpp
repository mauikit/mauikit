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
#include "provider-model.h"

#include <Accounts/Application>
#include <Accounts/Manager>
#include <Accounts/Provider>
#include <Accounts/Service>

using namespace OnlineAccounts;

/*!
 * \qmltype ProviderModel
 * \inqmlmodule Ubuntu.OnlineAccounts 0.1
 * \ingroup Ubuntu
 *
 * \brief A model of the account providers
 *
 * The ProviderModel is a model representing the account providers installed on
 * the system.
 *
 * The model defines the following roles:
 * \list
 * \li \c displayName, the user-visible name of this provider
 * \li \c providerId, the unique identifier of the account provider
 * \li \c iconName, the name of the icon representing this provider
 * \li \c isSingleAccount, \a true if this provider supports creating one
 * account at most
 * \li \c translations, the localization domain for translating the provider's
 * display name
 * \endlist
 */

ProviderModel::ProviderModel(QObject *parent):
    QAbstractListModel(parent),
    manager(SharedManager::instance()),
    m_componentCompleted(false)
{
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
}

ProviderModel::~ProviderModel()
{
}

/*!
 * \qmlproperty string ProviderModel::applicationId
 * If set, the model will only show those providers which are relevant for the
 * given \a applicationId. This means that a provider will only be shown if at
 * least one of its services can be used by the application, as described in
 * the application's manifest file.
 */
void ProviderModel::setApplicationId(const QString &applicationId)
{
    if (m_applicationId == applicationId) return;
    m_applicationId = applicationId;
    if (m_componentCompleted) update();
    Q_EMIT applicationIdChanged();
}

QString ProviderModel::applicationId() const
{
    return m_applicationId;
}

/*!
 * \qmlproperty int ProviderModel::count
 * The number of items in the model.
 */
int ProviderModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return providers.count();
}

/*!
 * \qmlmethod variant ProviderModel::get(int row, string roleName)
 *
 * Returns the data at \a row for the role \a roleName.
 */
QVariant ProviderModel::get(int row, const QString &roleName) const
{
    int role = roleNames().key(roleName.toLatin1(), -1);
    return data(index(row), role);
}

QVariant ProviderModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= providers.count())
        return QVariant();

    const Accounts::Provider &provider = providers.at(index.row());
    QVariant ret;

    switch (role) {
    case Qt::DisplayRole:
        ret = provider.displayName();
        break;
    case ProviderIdRole:
        ret = provider.name();
        break;
    case IconNameRole:
        ret = provider.iconName();
        break;
    case IsSingleAccountRole:
        ret = provider.isSingleAccount();
        break;
    case TranslationsRole:
        ret = provider.trCatalog();
        break;
    }

    return ret;
}

QHash<int, QByteArray> ProviderModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty()) {
        roles[Qt::DisplayRole] = "displayName";
        roles[ProviderIdRole] = "providerId";
        roles[IconNameRole] = "iconName";
        roles[IsSingleAccountRole] = "isSingleAccount";
        roles[TranslationsRole] = "translations";
    }
    return roles;
}

void ProviderModel::classBegin()
{
}

void ProviderModel::componentComplete()
{
    update();
    m_componentCompleted = true;
}

void ProviderModel::update()
{
    beginResetModel();

    Accounts::ProviderList allProviders = manager->providerList();
    if (m_applicationId.isEmpty()) {
        providers = allProviders;
    } else {
        providers.clear();
        /* This will be slightly simpler once
         * http://code.google.com/p/accounts-sso/issues/detail?id=214 is fixed. */
        Accounts::Application application = manager->application(m_applicationId);
        Accounts::ServiceList supportedServices;
        Q_FOREACH(const Accounts::Service &service, manager->serviceList()) {
            if (!application.serviceUsage(service).isEmpty()) {
                supportedServices.append(service);
            }
        }
        Q_FOREACH(const Accounts::Provider &provider, allProviders) {
            bool hasSupportedServices = false;
            Q_FOREACH(const Accounts::Service &service, supportedServices) {
                if (service.provider() == provider.name()) {
                    hasSupportedServices = true;
                    break;
                }
            }
            if (hasSupportedServices) {
                providers.append(provider);
            }
        }
    }

    endResetModel();
}
