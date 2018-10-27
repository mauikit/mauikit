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

#ifndef PLACESMODEL_H
#define PLACESMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QList>

class PlacesList;
class PlacesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(PlacesList *list READ getList WRITE setList)

public:    
	PlacesModel(QObject *parent = nullptr);
    ~PlacesModel();
	
	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
	// Editable:
	bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
	
	Qt::ItemFlags flags(const QModelIndex& index) const override;
	
	virtual QHash<int, QByteArray> roleNames() const override;
	
	PlacesList* getList() const;
	void setList(PlacesList *value);	
	
private:
	PlacesList *list;
	
signals:
	void listChanged();

};

#endif // PLACESMODEL_H
