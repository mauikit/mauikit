/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  camilo <email>
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

#include "placesmodel.h"
#include "placeslist.h"

PlacesModel::~PlacesModel()
{
}

PlacesModel::PlacesModel(QObject *parent)
: QAbstractListModel(parent), list(nullptr)
{}

int PlacesModel::rowCount(const QModelIndex &parent) const
{
	if (parent.isValid() || !list)
		return 0;
	
	return list->items().size();
}

QVariant PlacesModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || !list)
		return QVariant();
	
	
	return list->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool PlacesModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	Q_UNUSED(index);
	Q_UNUSED(value);
	Q_UNUSED(role);
	
	return false;
}

Qt::ItemFlags PlacesModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::NoItemFlags;
	
	return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> PlacesModel::roleNames() const
{
	QHash<int, QByteArray> names;
	
	for(auto key : FMH::MODEL_NAME.keys())
		names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();	
	
	return names;
}

PlacesList *PlacesModel::getList() const
{
	return this->list;
}

void PlacesModel::setList(PlacesList *value)
{
	beginResetModel();
	
	if(list)
		list->disconnect(this);
	
	list = value;
	
	if(list)
	{
		connect(this->list, &PlacesList::preItemAppended, this, [=]()
		{
			const int index = list->items().size();
			beginInsertRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &PlacesList::postItemAppended, this, [=]()
		{
			endInsertRows();
		});
		
		connect(this->list, &PlacesList::preItemRemoved, this, [=](int index)
		{
			beginRemoveRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &PlacesList::postItemRemoved, this, [=]()
		{
			endRemoveRows();
		});
		
		connect(this->list, &PlacesList::updateModel, this, [=](int index, QVector<int> roles)
		{
			emit this->dataChanged(this->index(index), this->index(index), roles);
		});
		
		// 		connect(this->list, &PlacesList::pathChanged, this, [=]()
		// 		{
		// 			beginResetModel();
		// 			endResetModel();
		// 		});
		
		connect(this->list, &PlacesList::preListChanged, this, [=]()
		{
			beginResetModel();
		});
		
		connect(this->list, &PlacesList::postListChanged, this, [=]()
		{
			endResetModel();
		});
	}
	
	endResetModel();
}
