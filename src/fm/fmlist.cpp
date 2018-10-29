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

#include "fmlist.h"
#include "fm.h"

#include <QFileSystemWatcher>

FMList::FMList(QObject *parent) : QObject(parent)
{
	this->fm = FM::getInstance();
	
	this->watcher = new QFileSystemWatcher(this);
	connect(watcher, &QFileSystemWatcher::directoryChanged, [this](const QString &path)
	{
		Q_UNUSED(path);
		this->reset();
	});
		
	connect(this, &FMList::pathChanged, this, &FMList::reset);	
	connect(this, &FMList::hiddenChanged, this, &FMList::setList);
	connect(this, &FMList::onlyDirsChanged, this, &FMList::setList);
	connect(this, &FMList::filtersChanged, this, &FMList::setList);
}

FMList::~FMList()
{}

void FMList::watchPath(const QString& path, const bool& clear)
{	
	if(!this->watcher->directories().isEmpty() && clear)
		this->watcher->removePaths(this->watcher->directories());
	
	if(path.isEmpty() || !FMH::fileExists(path))
		return;
	
	this->watcher->addPath(path);
}

void FMList::setList()
{	
	switch(this->pathType)
	{
		case FMH::PATHTYPE_KEY::APPS_PATH:
			this->list = FM::getAppsContent(this->path);
			break;
			
		case FMH::PATHTYPE_KEY::TAGS_PATH:
			this->list = this->fm->getTagContent(QString(this->path).right(this->path.length()- 1 - this->path.lastIndexOf("/")));
			break;
			
		case FMH::PATHTYPE_KEY::PLACES_PATH:			
			this->list = FM::getPathContent(this->path, this->hidden, this->onlyDirs, this->filters);			
			break;
			
		case FMH::PATHTYPE_KEY::TRASH_PATH:
		case FMH::PATHTYPE_KEY::DRIVES_PATH:			
		case FMH::PATHTYPE_KEY::BOOKMARKS_PATH:	
			this->list = FMH::MODEL_LIST();
			break;		
	}
	
	this->pathEmpty = this->list.isEmpty() && FM::fileExists(this->path);
	emit this->pathEmptyChanged();
	
	this->sortList();
}

void FMList::reset()
{
	emit this->preListChanged();
	
	switch(this->pathType)
	{
		case FMH::PATHTYPE_KEY::APPS_PATH:
			this->hidden = false;
			emit this->hiddenChanged();
			
			this->preview = false;
			emit this->previewChanged();
			break;
			
		case FMH::PATHTYPE_KEY::TAGS_PATH:
			this->hidden = false;
			emit this->hiddenChanged();
			
			this->preview = true;
			emit this->previewChanged();
			break;
			
		case FMH::PATHTYPE_KEY::PLACES_PATH:
		{	
			auto conf = FMH::dirConf(this->path+"/.directory");
			
			this->hidden = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN]].toBool();
			emit this->hiddenChanged();
			
			this->preview = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL]].toBool();
			emit this->previewChanged();
			
			break;			
		}
		
		case FMH::PATHTYPE_KEY::TRASH_PATH:
		case FMH::PATHTYPE_KEY::DRIVES_PATH:			
		case FMH::PATHTYPE_KEY::BOOKMARKS_PATH:			
			break;		
	}	
	
	this->setList();
	
	emit this->postListChanged();
}

FMH::MODEL_LIST FMList::items() const
{
	return this->list;
}


FMH::MODEL_KEY FMList::getSortBy() const
{
	return this->sort;
}

void FMList::setSortBy(const FMH::MODEL_KEY& key)
{
	emit this->preListChanged();
	
	if(this->sort == key)
		return;
	
	this->sort = key;
	this->sortList();
	
	emit this->sortByChanged();
	emit this->postListChanged();
}

void FMList::sortList()
{
	auto key = this->sort;
	qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
	{
		auto role = key; 
		
		switch(role)
		{
			case FMH::MIME:
				if(e1[role] == "inode/directory")
					return true;
				break;
			case FMH::SIZE:
			{
				QLocale l;
				if(l.toDouble(e1[role]) > l.toDouble(e2[role]))
					return true;
				break;				
			}
			case FMH::MODIFIED:
			case FMH::DATE:
			{
				auto currentTime = QDateTime::currentDateTime();
				
				auto date1 = QDateTime::fromString(e1[role], Qt::TextDate); 
				auto date2 = QDateTime::fromString(e2[role], Qt::TextDate); 
				
				if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
					return true;
				break;
			}
			
			default:
				if(e1[role] < e2[role])
					return true;
		}		
		
		return false;
	});
}

QString FMList::getPath() const
{
	return this->path;
}

void FMList::setPath(const QString &path)
{
	if(this->path == path)
		return;
	
	this->path = path;
	this->setPreviousPath(this->path);
	
	if(path.startsWith(FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::APPS_PATH]+"/"))
	{
		this->pathExists = true;
		this->pathType = FMH::PATHTYPE_KEY::APPS_PATH;
		this->isBookmark = false;
		emit this->pathExistsChanged();
		emit this->pathTypeChanged();
		emit this->isBookmarkChanged();
		this->watchPath(QString());
		
		
	}else if(path.startsWith(FMH::PATHTYPE_NAME[FMH::PATHTYPE_KEY::TAGS_PATH]+"/"))
	{
		this->pathExists = true;
		this->isBookmark = false;
		this->pathType = FMH::PATHTYPE_KEY::TAGS_PATH;
		emit this->pathExistsChanged();
		emit this->pathTypeChanged();
		emit this->isBookmarkChanged();
		this->watchPath(QString());
		
	}else
	{
		this->watchPath(this->path);
		this->isBookmark = this->fm->isBookmark(this->path);
		this->pathExists = FMH::fileExists(this->path);
		this->pathType = FMH::PATHTYPE_KEY::PLACES_PATH;
		emit this->pathExistsChanged();
		emit this->pathTypeChanged();
		emit this->isBookmarkChanged();
	}	
	
	emit this->pathChanged();
}

FMH::PATHTYPE_KEY FMList::getPathType() const
{
	return this->pathType;
}

QStringList FMList::getFilters() const
{
	return this->filters;
}

void FMList::setFilters(const QStringList &filters)
{
	if(this->filters == filters)
		return;
	
	this->filters = filters;
	
	emit this->preListChanged();
	emit this->filtersChanged();
	emit this->postListChanged();	
}

FMH::FILTER_TYPE FMList::getFilterType() const
{
	return this->filterType;
}

void FMList::setFilterType(const FMH::FILTER_TYPE& type)
{
	this->filterType = type;
	
	this->filters = FMH::FILTER_LIST[this->filterType];	
	
	emit this->preListChanged();
	emit this->filtersChanged();
	emit this->filterTypeChanged();
	emit this->postListChanged();	
}

bool FMList::getHidden() const
{
	return this->hidden;
}

void FMList::setHidden(const bool &state)
{
	if(this->hidden == state)
		return;
	
	this->hidden = state;
	
	if(this->pathType == FMH::PATHTYPE_KEY::PLACES_PATH && this->trackChanges)
		FMH::setDirConf(this->path+"/.directory", "Settings", "HiddenFilesShown", this->hidden);
	
	emit this->preListChanged();
	emit this->hiddenChanged();
	emit this->postListChanged();
}

bool FMList::getPreview() const
{
	return this->preview;
}

void FMList::setPreview(const bool &state)
{
	if(this->preview == state)
		return;
	
	this->preview = state;
	
	if(this->pathType == FMH::PATHTYPE_KEY::PLACES_PATH && this->trackChanges)
		FMH::setDirConf(this->path+"/.directory", "MAUIFM", "ShowThumbnail", this->preview);
	
	emit this->previewChanged();
}

bool FMList::getOnlyDirs() const
{
	return this->onlyDirs;
}

void FMList::setOnlyDirs(const bool &state)
{
	if(this->onlyDirs == state)
		return;
	
	this->onlyDirs = state;
	
	emit this->preListChanged();
	emit this->onlyDirsChanged();
	emit this->postListChanged();
}

QVariantMap FMList::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	QVariantMap res;
	const auto model = this->list.at(index);
	
	for(auto key : model.keys())
		res.insert(FMH::MODEL_NAME[key], model[key]);
	
	return res;
}

void FMList::refresh()
{
	emit this->pathChanged();
}

QString FMList::getParentPath() const
{
	return FM::parentDir(this->path);
}

QString FMList::getPosteriorPath()
{
	if(this->postHistory.isEmpty())
		return this->path;
	
	return this->postHistory.takeAt(this->postHistory.length()-1);
}

void FMList::setPosteriorPath(const QString& path)
{
	this->postHistory.append(path);
}

QString FMList::getPreviousPath() 
{	
	if(this->prevHistory.isEmpty())
		return this->path;
	
	if(this->prevHistory.length() < 2)
		return this->prevHistory.at(0);
	
	auto post = this->prevHistory.takeAt(this->prevHistory.length()-1);
	this->setPosteriorPath(post);
	
	return this->prevHistory.takeAt(this->prevHistory.length()-1);
}

void FMList::setPreviousPath(const QString& path)
{
	this->prevHistory.append(path);
}

bool FMList::getPathEmpty() const
{
	return this->pathEmpty;
}

bool FMList::getPathExists() const
{
	return this->pathExists;
}

bool FMList::getTrackChanges() const
{
	return this->trackChanges;
}

void FMList::setTrackChanges(const bool& value)
{
	if(this->trackChanges == value)
		return;
	
	this->trackChanges = value;
	emit this->trackChangesChanged();
}

bool FMList::getIsBookmark() const
{
	return this->isBookmark;
}

void FMList::setIsBookmark(const bool& value)
{
	if(this->isBookmark == value)
		return;
	
	if(this->pathType != FMH::PATHTYPE_KEY::PLACES_PATH)
		return;
	
	this->isBookmark = value;
	
	if(value)
		this->fm->bookmark(this->path);
	else
		this->fm->removeBookmark(this->path);
	
	emit this->isBookmarkChanged();
}

