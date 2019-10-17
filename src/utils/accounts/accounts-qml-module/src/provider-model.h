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

#ifndef ONLINE_ACCOUNTS_PROVIDER_MODEL_H
#define ONLINE_ACCOUNTS_PROVIDER_MODEL_H

#include "manager.h"
#include <QAbstractListModel>
#include <QList>
#include <QQmlParserStatus>

namespace Accounts {
    class Provider;
};

namespace OnlineAccounts {

class ProviderModel: public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QString applicationId READ applicationId \
               WRITE setApplicationId NOTIFY applicationIdChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    ProviderModel(QObject *parent = 0);
    ~ProviderModel();

    enum Roles {
        ProviderIdRole = Qt::UserRole + 1,
        IconNameRole,
        IsSingleAccountRole,
        TranslationsRole,
    };

    void setApplicationId(const QString &applicationId);
    QString applicationId() const;

    Q_INVOKABLE QVariant get(int row, const QString &roleName) const;

    // reimplemented virtual methods
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    void classBegin();
    void componentComplete();

Q_SIGNALS:
    void applicationIdChanged();
    void countChanged();

private:
    void update();

private:
    QSharedPointer<Accounts::Manager> manager;
    QList<Accounts::Provider> providers;
    QString m_applicationId;
    bool m_componentCompleted;
};

}; // namespace

#endif // ONLINE_ACCOUNTS_PROVIDER_MODEL_H
