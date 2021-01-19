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

#include "mauimodel.h"
#include "mauilist.h"

MauiModel::MauiModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new PrivateAbstractListModel(this))
{
    this->setSourceModel(this->m_model);
    this->setDynamicSortFilter(true);
}

void MauiModel::setFilterString(const QString &string)
{
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setFilterFixedString(string);
    //     this->setFilterRegExp(QRegExp(string, Qt::CaseInsensitive));
}

void MauiModel::setSortOrder(const int &sortOrder)
{
    this->sort(0, static_cast<Qt::SortOrder>(sortOrder));
}

QVariantMap MauiModel::get(const int &index) const
{
    QVariantMap res;
    if (index >= this->rowCount() || index < 0)
        return res;

    const auto roleNames = this->roleNames();
    for (const auto &role : roleNames)
        res.insert(role, this->index(index, 0).data(FMH::MODEL_NAME_KEY[role]).toString());

    return res;
}

QVariantList MauiModel::getAll() const
{
    QVariantList res;
    for (auto i = 0; i < this->rowCount(); i++)
        res << this->get(i);

    return res;
}

void MauiModel::setFilter(const QString &filter)
{
    if (this->m_filter == filter)
        return;

    this->m_filter = filter;
    emit this->filterChanged(this->m_filter);
    this->setFilterFixedString(this->m_filter);
}

const QString MauiModel::getFilter() const
{
    return this->m_filter;
}

void MauiModel::setSortOrder(const Qt::SortOrder &sortOrder)
{
    if (this->m_sortOrder == sortOrder)
        return;

    this->m_sortOrder = sortOrder;
    emit this->sortOrderChanged(this->m_sortOrder);
    this->sort(0, this->m_sortOrder);
}

Qt::SortOrder MauiModel::getSortOrder() const
{
    return this->m_sortOrder;
}

void MauiModel::setSort(const QString &sort)
{
    if (this->m_sort == sort)
        return;

    this->m_sort = sort;
    emit this->sortChanged(this->m_sort);
    this->setSortRole(FMH::MODEL_NAME_KEY[sort]);
    this->sort(0, this->m_sortOrder);
}

QString MauiModel::getSort() const
{
    return this->m_sort;
}

int MauiModel::mappedFromSource(const int &index) const
{
    return this->mapFromSource(this->m_model->index(index, 0)).row();
}

int MauiModel::mappedToSource(const int &index) const
{
    return this->mapToSource(this->index(index, 0)).row();
}

bool MauiModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (this->filterRole() != Qt::DisplayRole) {
        QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
        const auto data = this->sourceModel()->data(index, this->filterRole()).toString();
        return data.contains(this->filterRegExp());
    }

    const auto roleNames = this->sourceModel()->roleNames();
    for (const auto &role : roleNames) {
        QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
        const auto data = this->sourceModel()->data(index, FMH::MODEL_NAME_KEY[role]).toString();
        if (data.contains(this->filterRegExp()))
            return true;
        else
            continue;
    }

    return false;
}

MauiList *MauiModel::getList() const
{
    return this->m_model->getList();
}

MauiList *MauiModel::PrivateAbstractListModel::getList() const
{
    return this->list;
}

void MauiModel::PrivateAbstractListModel::setList(MauiList *value)
{
    beginResetModel();

    if (this->list)
        this->list->disconnect(this);

    this->list = value;

    if (this->list) {
        connect(
            this->list,
            &MauiList::preItemAppendedAt,
            this,
            [=](int index) {
                beginInsertRows(QModelIndex(), index, index);
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::preItemAppended,
            this,
            [=]() {
                const int index = this->list->items().size();
                beginInsertRows(QModelIndex(), index, index);
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::preItemsAppended,
            this,
            [=](uint count) {
                const int index = this->list->items().size();
                beginInsertRows(QModelIndex(), index, index + count - 1);
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::postItemAppended,
            this,
            [=]() {
                endInsertRows();
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::preItemRemoved,
            this,
            [=](int index) {
                beginRemoveRows(QModelIndex(), index, index);
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::postItemRemoved,
            this,
            [=]() {
                endRemoveRows();
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::updateModel,
            this,
            [=](int index, QVector<int> roles) {
                emit this->dataChanged(this->index(index), this->index(index), roles);
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::preListChanged,
            this,
            [=]() {
                beginResetModel();
            },
            Qt::DirectConnection);

        connect(
            this->list,
            &MauiList::postListChanged,
            this,
            [=]() {
                endResetModel();
            },
            Qt::DirectConnection);
    }

    endResetModel();
}

void MauiModel::setList(MauiList *value)
{
    value->modelHooked();
    this->m_model->setList(value);
    this->getList()->m_model = this;
    emit this->listChanged();
}

MauiModel::PrivateAbstractListModel::PrivateAbstractListModel(MauiModel *model)
    : QAbstractListModel(model)
    , list(nullptr)
    , m_model(model)
{
    connect(
        this,
        &QAbstractListModel::rowsInserted,
        this,
        [this](QModelIndex, int, int) {
            if (this->list) {
                emit this->list->countChanged();
            }
        },
        Qt::DirectConnection);

    connect(
        this,
        &QAbstractListModel::rowsRemoved,
        this,
        [this](QModelIndex, int, int) {
            if (this->list) {
                emit this->list->countChanged();
            }
        },
        Qt::DirectConnection);
}

int MauiModel::PrivateAbstractListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !list)
        return 0;

    return list->items().size();
}

QVariant MauiModel::PrivateAbstractListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !list)
        return QVariant();

    auto value = list->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];

    if (role == FMH::MODEL_KEY::ADDDATE || role == FMH::MODEL_KEY::DATE || role == FMH::MODEL_KEY::MODIFIED || role == FMH::MODEL_KEY::RELEASEDATE) {
        const auto date = QDateTime::fromString(value, Qt::TextDate);
        if (date.isValid())
            return date;
    }

    return value;
}

bool MauiModel::PrivateAbstractListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    Q_UNUSED(index);
    Q_UNUSED(value);
    Q_UNUSED(role);

    return false;
}

Qt::ItemFlags MauiModel::PrivateAbstractListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> MauiModel::PrivateAbstractListModel::roleNames() const
{
    QHash<int, QByteArray> names;

    for (const auto &key : FMH::MODEL_NAME.keys())
        names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();

    return names;
}
