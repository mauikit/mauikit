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

#ifndef ONLINE_ACCOUNTS_APPLICATION_MODEL_H
#define ONLINE_ACCOUNTS_APPLICATION_MODEL_H

#include "manager.h"
#include <Accounts/Service>
#include <QAbstractListModel>
#include <QList>
#include <QSharedPointer>

namespace OnlineAccounts {

class Application;

class ApplicationModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString service READ service WRITE setService \
               NOTIFY serviceChanged)

public:
    ApplicationModel(QObject *parent = 0);
    ~ApplicationModel();

    enum Roles {
        ApplicationIdRole = Qt::UserRole + 1,
        DisplayNameRole,
        IconNameRole,
        ServiceUsageRole,
        ApplicationRole,
        TranslationsRole,
    };

    void setService(const QString &serviceId);
    QString service() const;

    Q_INVOKABLE QVariant get(int row, const QString &roleName) const;

    // reimplemented virtual methods
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

Q_SIGNALS:
    void countChanged();
    void serviceChanged();

private:
    void computeApplicationList();

private:
    QSharedPointer<Accounts::Manager> manager;
    QList<Application*> applications;
    Accounts::Service m_service;
};

}; // namespace

#endif // ONLINE_ACCOUNTS_APPLICATION_MODEL_H
