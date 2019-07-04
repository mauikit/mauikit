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

#include "basemodel.h"
#include "modellist.h"

BaseModel::~BaseModel()
{
}

BaseModel::BaseModel(QObject *parent)
: QAbstractListModel(parent), list(nullptr)
{}

int BaseModel::rowCount(const QModelIndex &parent) const
{
	if (parent.isValid() || !list)
		return 0;
	
	return list->items().size();
}

QVariant BaseModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || !list)
		return QVariant();
	
	return list->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool BaseModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	Q_UNUSED(index);
	Q_UNUSED(value);
	Q_UNUSED(role);
	
	return false;
}

Qt::ItemFlags BaseModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::NoItemFlags;
	
	return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
	QHash<int, QByteArray> names;
	
	for(auto key : FMH::MODEL_NAME.keys())
		names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();	
	
	return names;
}

ModelList *BaseModel::getList() const
{
	return this->list;
}

void BaseModel::setList(ModelList *value)
{
	beginResetModel();
	
	if(list)
		list->disconnect(this);
	
	list = value;
	
	if(list)
	{
		connect(this->list, &ModelList::preItemAppended, this, [=]()
		{
			const int index = list->items().size();
			beginInsertRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &ModelList::postItemAppended, this, [=]()
		{
			endInsertRows();
		});
		
		connect(this->list, &ModelList::preItemRemoved, this, [=](int index)
		{
			beginRemoveRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &ModelList::postItemRemoved, this, [=]()
		{
			endRemoveRows();
		});
		
		connect(this->list, &ModelList::updateModel, this, [=](int index, QVector<int> roles)
		{
			emit this->dataChanged(this->index(index), this->index(index), roles);
		});
		
		// 		connect(this->list, &PlacesList::pathChanged, this, [=]()
		// 		{
		// 			beginResetModel();
		// 			endResetModel();
		// 		});
		
		connect(this->list, &ModelList::preListChanged, this, [=]()
		{
			beginResetModel();
		});
		
		connect(this->list, &ModelList::postListChanged, this, [=]()
		{	
			endResetModel();
		});
	}
	
	endResetModel();
}
