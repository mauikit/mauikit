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

#include "placeslist.h"
#include "fm.h"

PlacesList::PlacesList(QObject *parent) : QObject(parent)
{
	this->fm = new FM(this);
	
	connect(fm, &FM::pathModified, this, [](QString path)
	{
		qDebug()<< "Path modified" << path;
	});
	
	connect(this, &PlacesList::groupsChanged, this, &PlacesList::reset);
}

PlacesList::~PlacesList()
{
}

FMH::MODEL_LIST PlacesList::items() const
{
	return this->list;
}

void PlacesList::setList()
{
	if(this->groups.contains(FMH::PATHTYPE_KEY::PLACES_PATH))
		this->list << this->fm->getDefaultPaths();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::APPS_PATH))
		this->list << this->fm->getCustomPaths();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::BOOKMARKS_PATH))
		this->list << this->fm->getBookmarks();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::DRIVES_PATH))
		this->list << this->fm->getDevices();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::TAGS_PATH))
		this->list << this->fm->getTags();
}

void PlacesList::reset()
{
	emit this->preListChanged();
	this->setList();
	emit this->postListChanged();
}

PlacesList::Group PlacesList::getGroups() const
{
	return this->groups;
}

void PlacesList::setGroups(const PlacesList::Group& value)
{
	if(this->groups == value)
		return;
	
	this->groups = value;
	emit this->groupsChanged();
}
