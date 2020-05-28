/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MAUIMODEL_H
#define MAUIMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QSortFilterProxyModel>

class MauiList;

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#ifdef STATIC_MAUIKIT
class MauiModel : public QSortFilterProxyModel
#else
class MAUIKIT_EXPORT MauiModel : public QSortFilterProxyModel
#endif
{
    Q_OBJECT
    Q_PROPERTY(MauiList *list READ getList WRITE setList)
    Q_PROPERTY(QString filter READ getFilter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ getSortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(QString sort READ getSort WRITE setSort NOTIFY sortChanged)

public:
    MauiModel(QObject *parent = nullptr);

    MauiList *getList() const;
    void setList(MauiList *value);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    class PrivateAbstractListModel;
    PrivateAbstractListModel *m_model;
    QString m_filter;
    Qt::SortOrder m_sortOrder;
    QString m_sort;

public slots:
    void setFilterString(const QString &string); // deprecrated
    void setSortOrder(const int &sortOrder);     // deprecrated

    QVariantMap get(const int &index);
    QVariantList getAll();

    void setFilter(const QString &filter);
    const QString getFilter() const;

    void setSortOrder(const Qt::SortOrder &sortOrder);
    Qt::SortOrder getSortOrder() const;

    void setSort(const QString &sort);
    QString getSort() const;

    int mappedFromSource(const int &index) const;
    int mappedToSource(const int &index) const;

signals:
    void listChanged();
    void filterChanged(QString filter);
    void sortOrderChanged(Qt::SortOrder sortOrder);
    void sortChanged(QString sort);
};

class MauiModel::PrivateAbstractListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    PrivateAbstractListModel(MauiModel *model);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    MauiList *getList() const;
    void setList(MauiList *value);

private:
    MauiList *list;
    MauiModel *m_model;
};

#endif // MAUIMODEL_H
