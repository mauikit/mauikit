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

#include <QEventLoop>
#include <QTimer>
#include <QFileSystemWatcher>

PlacesList::PlacesList(QObject *parent) : QObject(parent)
{
	this->fm = FM::getInstance();
	this->watcher = new QFileSystemWatcher(this);
	connect(watcher, &QFileSystemWatcher::directoryChanged, [this](const QString &path)
	{
		if(this->count.contains(path))
		{
			
// 			QEventLoop loop;
// 			QTimer timer;
// 			connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
// 			
// 			timer.setSingleShot(true);
// 			timer.setInterval(1000);
			
			auto oldCount =  this->count[path];
			const auto index = this->indexOf(path);
			
// 			timer.start();
// 			loop.exec();
// 			timer.stop();
			
			auto newCount = FM::getPathContent(path, true, false).size();
			auto count = newCount - oldCount;
			
			this->list[index][FMH::MODEL_KEY::COUNT] = QString::number(count);
			
			emit this->updateModel(index, {FMH::MODEL_KEY::COUNT});
		}
	});
	
	connect(fm, &FM::bookmarkInserted, this, &PlacesList::reset);
	connect(fm, &FM::bookmarkRemoved, this, &PlacesList::reset);
	
	connect(this, &PlacesList::groupsChanged, this, &PlacesList::reset);
	
	this->setList();
}

void PlacesList::watchPath(const QString& path)
{
	if(path.isEmpty() || !FMH::fileExists(path))
		return;
	
	this->watcher->addPath(path);
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
	this->list.clear();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::PLACES_PATH))
		this->list << FM::getDefaultPaths();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::APPS_PATH))
		this->list << FM::getCustomPaths();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::BOOKMARKS_PATH))
		this->list << this->fm->getBookmarks();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::DRIVES_PATH))
		this->list << FM::getDevices();
	
	if(this->groups.contains(FMH::PATHTYPE_KEY::TAGS_PATH))
		this->list << this->fm->getTags();	
	
	this->setCount();
}

void PlacesList::setCount()
{
	this->watcher->removePaths(this->watcher->directories());
	for(auto &data : this->list)
	{
		auto path = data[FMH::MODEL_KEY::PATH];
		if(FM::isDir(path))
		{
			auto count = FM::getPathContent(path, true, false).size();
			data.insert(FMH::MODEL_KEY::COUNT, "0");
			this->count.insert(path, count);
			this->watchPath(path);
		}	
	}	
}

int PlacesList::indexOf(const QString& path)
{
	uint i = -1;
	for(auto data : this->list)
	{
		i++;
		if(data[FMH::MODEL_KEY::PATH] == path)
			break;
	}
	
	return i;
}

void PlacesList::reset()
{
	emit this->preListChanged();
	this->setList();	
	emit this->postListChanged();
}

QList<int> PlacesList::getGroups() const
{
	return this->groups;
}

void PlacesList::setGroups(const QList<int> &value)
{
	if(this->groups == value)
		return;
	
	this->groups = value;
	
	emit this->groupsChanged();
}

QVariantMap PlacesList::get(const int& index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	QVariantMap res;
	const auto model = this->list.at(index);
	
	for(auto key : model.keys())
		res.insert(FMH::MODEL_NAME[key], model[key]);
	
	return res;
}

void PlacesList::refresh()
{
	this->reset();
}

void PlacesList::clearBadgeCount(const int& index)
{
	this->list[index][FMH::MODEL_KEY::COUNT] = "0";
	emit this->updateModel(index, {FMH::MODEL_KEY::COUNT});
}
