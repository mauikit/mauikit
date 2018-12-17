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

#ifndef STORELIST_H
#define STORELIST_H

#include <QObject>
#include "fmh.h"
#include "store.h"

class StoreList : public QObject
{
	Q_OBJECT
	Q_PROPERTY(StoreList::CATEGORY category READ getCategory WRITE setCategory NOTIFY categoryChanged)
	Q_PROPERTY(int limit READ getLimit WRITE setLimit NOTIFY limitChanged)
	Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged)
	Q_PROPERTY(StoreList::ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)
	
public:    
	StoreList(QObject *parent = nullptr);   
	FMH::MODEL_LIST items() const;
	
	enum CATEGORY : uint_fast8_t
	{
		WALLPAPERS = STORE::CATEGORY_KEY::WALLPAPERS,
		IMAGES = STORE::CATEGORY_KEY::IMAGES,
		COMICS = STORE::CATEGORY_KEY::COMICS,
		AUDIO = STORE::CATEGORY_KEY::AUDIO,
		ART = STORE::CATEGORY_KEY::ART,
		CLIPS = STORE::CATEGORY_KEY::CLIPS,
		MOVIES= STORE::CATEGORY_KEY::MOVIES
	}; Q_ENUM(CATEGORY)
	
	enum ORDER : uint_fast8_t
	{		
		Newest = Attica::Provider::SortMode::Newest,
		Alphabetical = Attica::Provider::SortMode::Alphabetical,
		Rating = Attica::Provider::SortMode::Rating,
		Downloads = Attica::Provider::SortMode::Downloads	
	};Q_ENUM(ORDER)
	
	void setCategory(const StoreList::CATEGORY &value);
	StoreList::CATEGORY getCategory() const;
	
	void setLimit(const int &value);
	int getLimit() const;
	
	void setQuery(const QString &value);
	QString getQuery() const;
	
	void setOrder(const StoreList::ORDER &value);
	StoreList::ORDER getOrder() const;
	
	
public slots:
	void getPersonInfo(const QString &nick);
	
private:
	FMH::MODEL_LIST list;
	Store *store;
	
	void setList();
	
	StoreList::CATEGORY category;
	int limit = 10;
	QString query;
	StoreList::ORDER order;	
	
signals:
	void preItemAppended();
	void postItemAppended();
	void preItemRemoved(int index);
	void postItemRemoved();
	void updateModel(int index, QVector<int> roles);
	void preListChanged();
	void postListChanged();
	
	void categoryChanged();
	void limitChanged();
	void queryChanged();
	void orderChanged();
	
};

#endif // STORELIST_H
