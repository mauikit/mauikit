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

#include "storelist.h"

StoreList::StoreList(QObject *parent) : QObject(parent)
{
	this->store = new Store(this);
	
	connect(this->store, &Store::contentReady, [this](const FMH::MODEL_LIST &list)
	{
		emit this->preListChanged();
		this->list =list; 
		qDebug()<< "STORE LIST READY" << list;
		emit this->postListChanged();
	});
	
	connect(this->store, &Store::storeReady, this, &StoreList::setList);
}

FMH::MODEL_LIST StoreList::items() const
{
	return this->list;
}

void StoreList::getPersonInfo(const QString& nick)
{
	this->store->getPersonInfo(nick);
}

void StoreList::setList()
{
	this->store->searchFor(static_cast<STORE::CATEGORY_KEY>(this->category), this->query, this->limit);	
}

StoreList::CATEGORY StoreList::getCategory() const
{
	return this->category;
}

void StoreList::setCategory(const StoreList::CATEGORY& value) 
{
	if(this->category == value)
		return;
	
	this->category = value;
	emit this->categoryChanged();
	this->setList();
}

int StoreList::getLimit() const
{
	return this->limit;
}

void StoreList::setLimit(const int& value) 
{
	if(this->limit == value)
		return;
	
	this->limit = value;
	emit this->limitChanged();
}

StoreList::ORDER StoreList::getOrder() const
{
	return this->order;
}

void StoreList::setOrder(const StoreList::ORDER& value) 
{
	if(this->order == value)
		return;
	
	this->order = value;
	emit this->orderChanged();
}

QString StoreList::getQuery() const
{
	return this->query;
}

void StoreList::setQuery(const QString& value) 
{
	if(this->query == value)
		return;
	
	this->query = value;
	emit this->queryChanged();
	this->setList();
}

