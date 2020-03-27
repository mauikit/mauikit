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
#include <QIcon>
#include <QEventLoop>
#include <QTimer>
#include <QFileSystemWatcher>
#include "utils.h"

#ifdef COMPONENT_ACCOUNTS
#include "mauiaccounts.h"
#endif

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KFilePlacesModel>
#endif

#ifdef COMPONENT_TAGGING
#include "tagging.h"
#endif

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
PlacesList::PlacesList(QObject *parent) : MauiList(parent),
fm(new FM(this)),
model(nullptr),
watcher(new QFileSystemWatcher(this))
#else
PlacesList::PlacesList(QObject *parent) : MauiList(parent),
fm(new FM(this)),
model(new KFilePlacesModel(this)),
watcher(new QFileSystemWatcher(this))
#endif
{ 		
	connect(watcher, &QFileSystemWatcher::directoryChanged, [&](const QString &path)
	{
		if(this->count.contains(path))
		{
			const auto oldCount =  this->count[path];
			const auto index = this->indexOf(path);
			const auto newCount = FMH::getFileInfoModel(path)[FMH::MODEL_KEY::COUNT].toInt();
			const auto count = newCount - oldCount;
			
			this->list[index][FMH::MODEL_KEY::COUNT] = QString::number(count);
			emit this->updateModel(index, {FMH::MODEL_KEY::COUNT});
		}
	});
	
	#ifdef COMPONENT_TAGGING
	connect(Tagging::getInstance(), &Tagging::tagged, this, &PlacesList::reset);
	#endif
	
	#ifdef COMPONENT_ACCOUNTS
	connect(MauiAccounts::instance(), &MauiAccounts::accountAdded, this, &PlacesList::reset);
	connect(MauiAccounts::instance(), &MauiAccounts::accountRemoved, this, &PlacesList::reset);
	#endif
	
		
	#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
	connect(this->model, &KFilePlacesModel::rowsInserted, [this](const QModelIndex &parent, int first, int last)
	{		
		this->reset();
        emit this->bookmarksChanged();
        
		/*emit this->preListChanged();
		
		for (int i = first; i <= last; i++) 
		{
			const QModelIndex index = model->index(i, 0);
			
			if(this->groups.contains(model->groupType(index)))				
			{
				this->list << getGroup(*this->model, static_cast<FMH::PATHTYPE_KEY>(model->groupType(index)));
			}			
		}		
		emit this->postListChanged();	*/	
	}); //TODO improve the usage of the model
#else
    connect(&UTIL::Settings::global(), &UTIL::Settings::settingChanged, [&](const QUrl &url, const QString &key, const QVariant &value, const QString &group )
    {
        if(key == "BOOKMARKS" && group == "PREFERENCES")
        {
            this->reset();
            emit this->bookmarksChanged();
        }
    });
	#endif
	
	connect(this, &PlacesList::groupsChanged, this, &PlacesList::reset);

}

void PlacesList::watchPath(const QString& path)
{
	if(path.isEmpty() || !FMH::fileExists(path) || QUrl(path).isLocalFile())
		return;
	
	this->watcher->addPath(path);
}

void PlacesList::componentComplete()
{
	this->setList();
}

FMH::MODEL_LIST PlacesList::items() const
{
	return this->list;
}


FMH::MODEL_LIST PlacesList::getGroup(const KFilePlacesModel &model, const FMH::PATHTYPE_KEY &type)
{
    #if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
	Q_UNUSED(model)
	FMH::MODEL_LIST res;
	switch(type)
	{
		case(FMH::PATHTYPE_KEY::PLACES_PATH):
            res << FMStatic::getDefaultPaths();
            res<< FMStatic::packItems(UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {}, true).toStringList(), FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::BOOKMARKS_PATH]);
			break;
		case(FMH::PATHTYPE_KEY::DRIVES_PATH):
			res = FMStatic::getDevices();
			break;
		default: break;
	}
	
	return res;
	#else
    FMH::MODEL_LIST res;

    if(type == FMH::PATHTYPE_KEY::PLACES_PATH)
    {
        res << FMStatic::getDefaultPaths();
    }
    
	const auto group = model.groupIndexes(static_cast<KFilePlacesModel::GroupType>(type));
    res << std::accumulate(group.begin(), group.end(), FMH::MODEL_LIST(), [&model, &type](FMH::MODEL_LIST &list, const QModelIndex &index) -> FMH::MODEL_LIST
    {
        
        const QUrl url = model.url(index); 
        if(type == FMH::PATHTYPE_KEY::PLACES_PATH && FMH::defaultPaths.contains(url.toString()))
            return list;        
        
        list << FMH::MODEL {{FMH::MODEL_KEY::PATH, url.toString()},
                           {FMH::MODEL_KEY::URL, model.url(index).toString()},
                           {FMH::MODEL_KEY::ICON, model.icon(index).name()},
                           {FMH::MODEL_KEY::LABEL, model.text(index)},
                           {FMH::MODEL_KEY::NAME, model.text(index)},
                           {FMH::MODEL_KEY::TYPE, type == FMH::PATHTYPE_KEY::PLACES_PATH ? FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::BOOKMARKS_PATH] : FMH::PATHTYPE_LABEL[type]}};
                           
		return list;
	});
    
    return res;
	#endif
}

void PlacesList::setList()
{		
	this->list.clear();
	
	//this are default static places //TODO move to itws own PATHTYPE_KEY::QUICK
	this->list << FMH::MODEL
	{
		{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::TAGS_PATH]+"fav"},
		{FMH::MODEL_KEY::ICON, "love"},
		{FMH::MODEL_KEY::LABEL, "Favorite"},
		{FMH::MODEL_KEY::TYPE, "Quick"}
	};
	
	#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
	this->list << FMH::MODEL
	{
		{FMH::MODEL_KEY::PATH,"recentdocuments:///"},
		{FMH::MODEL_KEY::ICON, "view-media-recent"},
		{FMH::MODEL_KEY::LABEL, "Recent"},
		{FMH::MODEL_KEY::TYPE, "Quick"}
	};
    #endif


	#ifdef COMPONENT_TAGGING
	this->list << FMH::MODEL
	{
		{FMH::MODEL_KEY::PATH,"tags:///"},
		{FMH::MODEL_KEY::ICON, "tag"},
		{FMH::MODEL_KEY::LABEL, "Tags"},
		{FMH::MODEL_KEY::TYPE, "Quick"}
	};
	#endif
	
	for(const auto &group : this->groups)
	{
        	switch(group)
		{
			case FMH::PATHTYPE_KEY::PLACES_PATH:
                this->list << getGroup(*this->model, FMH::PATHTYPE_KEY::PLACES_PATH);
                break;
				
			case FMH::PATHTYPE_KEY::APPS_PATH:
				this->list << FM::getAppsPath();
				break;
				
			case FMH::PATHTYPE_KEY::DRIVES_PATH:
				this->list << getGroup(*this->model, FMH::PATHTYPE_KEY::DRIVES_PATH);
				break;
				
			case FMH::PATHTYPE_KEY::REMOTE_PATH:
				this->list << getGroup(*this->model, FMH::PATHTYPE_KEY::REMOTE_PATH);
				break;
				
			case FMH::PATHTYPE_KEY::REMOVABLE_PATH:
				this->list << getGroup(*this->model, FMH::PATHTYPE_KEY::REMOVABLE_PATH);
				break;
				
			case FMH::PATHTYPE_KEY::TAGS_PATH:
				this->list << this->fm->getTags();
				break;
				
				#ifdef COMPONENT_ACCOUNTS
			case FMH::PATHTYPE_KEY::CLOUD_PATH:
				this->list << MauiAccounts::instance()->getCloudAccounts();
				break;
				#endif
		}		
    }
    
    this->setCount();
}

void PlacesList::setCount()
{
    this->watcher->removePaths(this->watcher->directories());
    for(auto &data : this->list)
    {
        const auto path = data[FMH::MODEL_KEY::PATH];
        if(FMStatic::isDir(path))
        {
            data.insert(FMH::MODEL_KEY::COUNT, "0");
            const auto count = FMH::getFileInfoModel(path)[FMH::MODEL_KEY::COUNT];
            this->count.insert(path, count.toInt());
            this->watchPath(path);
        }
    }
}

int PlacesList::indexOf(const QString& path)
{
	const auto index = std::find_if(this->list.begin(), this->list.end(), [&path](const FMH::MODEL &item) -> bool
	{
		return item[FMH::MODEL_KEY::PATH] == path;
		
	});
	return std::distance(this->list.begin(), index);
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
	
	const auto model = this->list.at(index);
	return FMH::toMap(model);
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

void PlacesList::addPlace(const QUrl& path)
{
    FMStatic::bookmark(path);
}

void PlacesList::removePlace(const int& index)
{
	if(index >= this->list.size() || index < 0)
		return;
	
	emit this->preItemRemoved(index);
	
    #if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    auto bookmarks = UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {}, true).toStringList();
	bookmarks.removeOne(this->list.at(index)[FMH::MODEL_KEY::PATH]);
    UTIL::saveSettings("BOOKMARKS", bookmarks, "PREFERENCES", true);
	#else
	this->model->removePlace(this->model->closestItem(this->list.at(index)[FMH::MODEL_KEY::PATH]));
	#endif
	
	this->list.removeAt(index);
	emit this->postItemRemoved();
}

bool PlacesList::contains(const QUrl& path)
{
	return (std::find_if(this->list.rbegin(), this->list.rend(), [&](const FMH::MODEL &item) -> bool 
	{
		return item[FMH::MODEL_KEY::PATH] == path.toString();
	})) != this->list.rend();
}

int PlacesList::indexOf(const QUrl& path) //TODO needs tweaking
{	
	return std::distance(std::find_if(this->list.rbegin(), this->list.rend(), [&](const FMH::MODEL &item) -> bool 
	{
		return item[FMH::MODEL_KEY::PATH] == path.toString();
	}), this->list.rend());
}


