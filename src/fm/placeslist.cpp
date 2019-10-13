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

#ifdef Q_OS_ANDROID 
#else
#include <KFilePlacesModel>
#endif

#ifdef Q_OS_ANDROID 
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
    connect(watcher, &QFileSystemWatcher::directoryChanged, [this](const QString &path)
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

    connect(fm, &FM::cloudAccountInserted, this, &PlacesList::reset);
    connect(fm, &FM::cloudAccountRemoved, this, &PlacesList::reset);

    connect(this, &PlacesList::groupsChanged, this, &PlacesList::reset);

    this->setList();
}

void PlacesList::watchPath(const QString& path)
{
    if(path.isEmpty() || !FMH::fileExists(path) || QUrl(path).isLocalFile())
        return;

    this->watcher->addPath(path);
}

PlacesList::~PlacesList() {}

FMH::MODEL_LIST PlacesList::items() const
{
    return this->list;
}

#ifdef Q_OS_ANDROID
#else
static FMH::MODEL modelPlaceInfo(const KFilePlacesModel &model, const QModelIndex &index,  const FMH::PATHTYPE_KEY &type)
{
    return FMH::MODEL
        {
            {FMH::MODEL_KEY::PATH, model.url(index).toString()},
            {FMH::MODEL_KEY::URL, model.url(index).toString()},
            {FMH::MODEL_KEY::ICON, model.icon(index).name()},
            {FMH::MODEL_KEY::LABEL, model.text(index)},
            {FMH::MODEL_KEY::NAME, model.text(index)},
            {FMH::MODEL_KEY::TYPE, FMH::PATHTYPE_LABEL[type]}
        };
}
#endif


static FMH::MODEL_LIST getGroup(const KFilePlacesModel &model, const FMH::PATHTYPE_KEY &type)
{
	#ifdef Q_OS_ANDROID
    Q_UNUSED(model)
    FMH::MODEL_LIST res;
    switch(type)
    {
        case(FMH::PATHTYPE_KEY::PLACES_PATH):
            res << FM_STATIC::getDefaultPaths();
            res<< FM_STATIC::packItems(UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {}, "FileManager").toStringList(), FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]);
            break;
        case(FMH::PATHTYPE_KEY::DRIVES_PATH):
            res = FM_STATIC::getDevices();
            break;
        default: break;
    }

    return res;
	#else
	const auto group = model.groupIndexes(static_cast<KFilePlacesModel::GroupType>(type));
	return std::accumulate(group.begin(), group.end(), FMH::MODEL_LIST(), [&model, &type](FMH::MODEL_LIST &list, const QModelIndex &index) -> FMH::MODEL_LIST
	{
		list << modelPlaceInfo(model, index, type);
		return list;        
	});
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
    
//     this->list << FMH::MODEL
// 	{
// 		{FMH::MODEL_KEY::PATH,"kdeconnect:///"},
// 		{FMH::MODEL_KEY::ICON, "phone"},
// 		{FMH::MODEL_KEY::LABEL, "KDEConnect"},
// 		{FMH::MODEL_KEY::TYPE, "Quick"}
// 	};
#endif
    
    for(const auto &group : this->groups)
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

    this->setCount();
}

void PlacesList::setCount()
{
    this->watcher->removePaths(this->watcher->directories());
    for(auto &data : this->list)
    {
        const auto path = data[FMH::MODEL_KEY::PATH];
        if(FM_STATIC::isDir(path))
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
    const auto it = std::find_if(this->list.rbegin(), this->list.rend(), [](const FMH::MODEL &item) -> bool{
       return item[FMH::MODEL_KEY::TYPE] == FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]; 
    });
    const auto index = std::distance(it, this->list.rend());
    
    emit this->preItemAppendedAt(index);
	
#ifdef Q_OS_ANDROID
	//do android stuff until cmake works with android 
    auto bookmarks = UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {}, "FileManager").toStringList();
    bookmarks << path.toString();
    UTIL::saveSettings("BOOKMARKS", bookmarks, "PREFERENCES", "FileManager");
    this->list.insert(index, FMH::getDirInfoModel(path));
#else
//     const auto url =  QStringLiteral("file://")+path;
	this->model->addPlace(QDir(path.toLocalFile()).dirName(), path);
	this->list.insert(index, modelPlaceInfo(*this->model, this->model->closestItem(path), FMH::PATHTYPE_KEY::PLACES_PATH));
#endif
	
    emit this->postItemAppended();    
}

void PlacesList::removePlace(const int& index)
{
    if(index >= this->list.size() || index < 0)
        return;

    emit this->preItemRemoved(index);
	
	#ifdef Q_OS_ANDROID
    auto bookmarks = UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {}, "FileManager").toStringList();
    bookmarks.removeOne(this->list.at(index)[FMH::MODEL_KEY::PATH]);
    UTIL::saveSettings("BOOKMARKS", bookmarks, "PREFERENCES", "FileManager");
	#else
	this->model->removePlace(this->model->index(index, 0));	
	#endif
	
    this->list.removeAt(index);
    emit this->postItemRemoved();
}

