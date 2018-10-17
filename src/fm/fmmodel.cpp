#include "fmmodel.h"
#include "fmlist.h"

FMModel::FMModel(QObject *parent)
: QAbstractListModel(parent), fmlist(nullptr)
{}

int FMModel::rowCount(const QModelIndex &parent) const
{
	if (parent.isValid() || !fmlist)
		return 0;
	
	return fmlist->items().size();
}

QVariant FMModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || !fmlist)
		return QVariant();
	
	
	return fmlist->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool FMModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	Q_UNUSED(index);
	Q_UNUSED(value);
	Q_UNUSED(role);
	
	return false;
}

Qt::ItemFlags FMModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::NoItemFlags;
	
	return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> FMModel::roleNames() const
{
	QHash<int, QByteArray> names;

	for(auto key : FMH::MODEL_NAME.keys())
		names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();	
	
	return names;
}

FMList *FMModel::getList() const
{
	return this->fmlist;
}

void FMModel::setList(FMList *value)
{
	beginResetModel();
	
	if(fmlist)
		fmlist->disconnect(this);
	
	fmlist = value;
	
	if(fmlist)
	{
		connect(this->fmlist, &FMList::preItemAppended, this, [=]()
		{
			const int index = fmlist->items().size();
			beginInsertRows(QModelIndex(), index, index);
		});
		
		connect(this->fmlist, &FMList::postItemAppended, this, [=]()
		{
			endInsertRows();
		});
		
		connect(this->fmlist, &FMList::preItemRemoved, this, [=](int index)
		{
			beginRemoveRows(QModelIndex(), index, index);
		});
		
		connect(this->fmlist, &FMList::postItemRemoved, this, [=]()
		{
			endRemoveRows();
		});
		
		connect(this->fmlist, &FMList::updateModel, this, [=](int index, QVector<int> roles)
		{
			emit this->dataChanged(this->index(index), this->index(index), roles);
		});
		
		connect(this->fmlist, &FMList::pathChanged, this, [=]()
		{
			beginResetModel();
			endResetModel();
		});
		
		connect(this->fmlist, &FMList::preListChanged, this, [=]()
		{
			beginResetModel();
		});
		
		connect(this->fmlist, &FMList::postListChanged, this, [=]()
		{
			endResetModel();
		});
	}
	
	endResetModel();
}
