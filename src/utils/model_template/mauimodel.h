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

/**
 * @brief The MauiModel class
 * The MauiModel is a template model to use with a MauiList, it aims to be a generic and simple data model to quickly model string based models using the FMH::MODEL_LIST and FMH::MODEL_KEY types.
 *
 * This type is exposed to QML to quickly create a modle that can be filtered, sorted and has another usefull functionalities.
 */
#ifdef STATIC_MAUIKIT
class MauiModel : public QSortFilterProxyModel
#else
class MAUIKIT_EXPORT MauiModel : public QSortFilterProxyModel
#endif
{
    Q_OBJECT
    Q_PROPERTY(MauiList *list READ getList WRITE setList NOTIFY listChanged)
    Q_PROPERTY(QString filter READ getFilter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ getSortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(QString sort READ getSort WRITE setSort NOTIFY sortChanged)

public:
    MauiModel(QObject *parent = nullptr);

    /**
     * @brief getList
     * The list being handled by the model
     * @return
     */
    MauiList *getList() const;

    /**
     * @brief setList
     * For the model to work you need to set a MauiList, by subclassing it and exposing it to the QML engine
     * @param value
     */
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

    /**
     * @brief get
     * Returns an item in the model/list. This method correctly maps the given index in case the modle has been sorted or filtered
     * @param index
     * Index of the item in the list
     * @return
     */
    QVariantMap get(const int &index) const;

    /**
     * @brief getAll
     * Returns all the items in the list represented as a QVariantList to be able to be used in QML. This operation performs a transformation from FMH::MODEL_LIST to QVariantList
     * @return
     * All the items in the list
     */
    QVariantList getAll() const;

    /**
     * @brief setFilter
     * Filter the model using a simple string, to clear the filter just set it to a empty string
     * @param filter
     * Simple filter string
     */
    void setFilter(const QString &filter);

    /**
     * @brief getFilter
     * The filter being applied to the model
     * @return
     */
    const QString getFilter() const;

    /**
     * @brief setSortOrder
     * Set the sort order, asc or dec
     * @param sortOrder
     */
    void setSortOrder(const Qt::SortOrder &sortOrder);

    /**
     * @brief getSortOrder
     * The current sort order being applied
     * @return
     */
    Qt::SortOrder getSortOrder() const;

    /**
     * @brief setSort
     * Set the sort key. The sort keys can be found in the FMH::MODEL_KEY keys
     * @param sort
     */
    void setSort(const QString &sort);

    /**
     * @brief getSort
     * The current sorting key
     * @return
     */
    QString getSort() const;

    /**
     * @brief mappedFromSource
     * Maps an index from the base list to the model, incase the modle has been filtered or sorted, this gives you the right mapped index
     * @param index
     * @return
     */
    int mappedFromSource(const int &index) const;

    /**
     * @brief mappedToSource
     * given an index from the filtered or sorted model it return the mapped index to the original list index
     * @param index
     * @return
     */
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
