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

#ifndef PLACESLIST_H
#define PLACESLIST_H

#include <QObject>
#include "fmh.h"

class QFileSystemWatcher;
class FM;
class PlacesList : public QObject
{
    Q_OBJECT    
//     typedef QList<int> Group;
	
	Q_PROPERTY(QList<int> groups READ getGroups WRITE setGroups NOTIFY groupsChanged())	

public:  
// 	Q_ENUMS(FMH::PATHTYPE_KEY)
	
	PlacesList(QObject *parent = nullptr);
    ~PlacesList();
	
	FMH::MODEL_LIST items() const;
	
	QList<int> getGroups() const;
	void setGroups(const QList<int> &value);
	
protected:
	void setList();
	void reset();
	
public slots:
	QVariantMap get(const int &index) const;
	void refresh();
	void clearBadgeCount(const int &index);
	
private:
	FM *fm;
	FMH::MODEL_LIST list;
	QHash<QString, int> count;
	QList<int> groups;
	
	QFileSystemWatcher *watcher;
	void watchPath(const QString &path);
	
	void setCount();
	int indexOf(const QString &path);
	
signals:
	void groupsChanged();
	
	void preItemAppended();
	void postItemAppended();
	void preItemRemoved(int index);
	void postItemRemoved();
	void updateModel(int index, QVector<int> roles);
	void preListChanged();
	void postListChanged();
	
};
#endif // PLACESLIST_H
