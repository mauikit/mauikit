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

MauiModel::~MauiModel()
{
}

MauiModel::MauiModel(QObject *parent)
: QAbstractListModel(parent), list(nullptr)
{}

int MauiModel::rowCount(const QModelIndex &parent) const
{
	if (parent.isValid() || !list)
		return 0;
	
	return list->items().size();
}

QVariant MauiModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || !list)
		return QVariant();
	
	return list->items().at(index.row())[static_cast<KEYS>(role)];
}

bool MauiModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	Q_UNUSED(index);
	Q_UNUSED(value);
	Q_UNUSED(role);
	
	return false;
}

Qt::ItemFlags MauiModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::NoItemFlags;
	
	return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> MauiModel::roleNames() const
{
	QHash<int, QByteArray> names;
	
	for(auto key : KEYS::_N.keys())
		names[key] = QString(KEYS::_N[key]).toUtf8();	
	
	return names;
}

MauiList *MauiModel::getList() const
{
	return this->list;
}

void MauiModel::setList(MauiList *value)
{
	beginResetModel();
	
	if(list)
		list->disconnect(this);
	
	list = value;
	
	if(list)
	{
        connect(this->list, &MauiList::preItemAppendedAt, this, [=](int index)
        {
            beginInsertRows(QModelIndex(), index, index);
        });
        
		connect(this->list, &MauiList::preItemAppended, this, [=]()
		{
			const int index = list->items().size();
			beginInsertRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &MauiList::postItemAppended, this, [=]()
		{
			endInsertRows();
		});
		
		connect(this->list, &MauiList::preItemRemoved, this, [=](int index)
		{
			beginRemoveRows(QModelIndex(), index, index);
		});
		
		connect(this->list, &MauiList::postItemRemoved, this, [=]()
		{
			endRemoveRows();
		});
		
		connect(this->list, &MauiList::updateModel, this, [=](int index, QVector<int> roles)
		{
			emit this->dataChanged(this->index(index), this->index(index), roles);
		});
				
		connect(this->list, &MauiList::preListChanged, this, [=]()
		{
			beginResetModel();
		});
		
		connect(this->list, &MauiList::postListChanged, this, [=]()
		{	
			endResetModel();
		});
	}
	
	endResetModel();
}
