#include "syncingmodel.h"
#include "syncinglist.h"

#include "fmh.h"

SyncingModel::SyncingModel(QObject *parent)
    : QAbstractListModel(parent),
      mList(nullptr)
{}

int SyncingModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant SyncingModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    return mList->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool SyncingModel::setData(const QModelIndex &index, const QVariant &value, int role)
{

    return false;
}

Qt::ItemFlags SyncingModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> SyncingModel::roleNames() const
{
    QHash<int, QByteArray> names;

        for(auto key : FMH::MODEL_NAME.keys())
            names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();

        return names;
}

SyncingList *SyncingModel::getList() const
{
    return this->mList;
}

void SyncingModel::setList(SyncingList *value)
{
    beginResetModel();

    if(mList)
        mList->disconnect(this);

    mList = value;

    if(mList)
    {
        connect(this->mList, &SyncingList::preItemAppended, this, [=]()
        {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &SyncingList::postItemAppended, this, [=]()
        {
            endInsertRows();
        });

        connect(this->mList, &SyncingList::preItemRemoved, this, [=](int index)
        {
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(this->mList, &SyncingList::postItemRemoved, this, [=]()
        {
            endRemoveRows();
        });

        connect(this->mList, &SyncingList::updateModel, this, [=](int index, QVector<int> roles)
        {
            emit this->dataChanged(this->index(index), this->index(index), roles);
        });

        connect(this->mList, &SyncingList::preListChanged, this, [=]()
        {
            beginResetModel();
        });

        connect(this->mList, &SyncingList::postListChanged, this, [=]()
        {
            endResetModel();
        });
    }

    endResetModel();
}
