/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  camilo higuita <milo.h@aol.com>
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
#include "utils.h"

#include <QObject>
#include <QFileSystemWatcher>

#ifdef COMPONENT_SYNCING
#include "syncing.h"
#endif

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KIO/EmptyTrashJob>
#endif

#include <QtConcurrent>
#include <QtConcurrent/QtConcurrentRun>
#include <QFuture>
#include <QThread>

FMList::FMList(QObject *parent) : 
MauiList(parent),
fm(new FM(this)),
watcher(new QFileSystemWatcher(this))
{
    connect(this->fm, &FM::cloudServerContentReady, [&](const FMH::MODEL_LIST &list, const QUrl &url)
	{
		if(this->path == url)
		{			
			this->assignList(list);			
		}	
	});
	
	connect(this->fm, &FM::pathContentReady, [&](const FMH::PATH_CONTENT &res)
	{		
//         if(res.path != this->path)
//             return;
		
		this->assignList(res.content);
	});	
	
	connect(this->fm, &FM::warningMessage, [&](const QString &message)
	{
		emit this->warning(message);
	});
	
	connect(this->fm, &FM::loadProgress, [&](const int &percent)
	{
		emit this->progress(percent);
	});
	
	// with kio based on android it watches the directory itself, so better relay on that
#ifdef Q_OS_ANDROID
	connect(this->watcher, &QFileSystemWatcher::directoryChanged, [&](const QString &path)
	{
		qDebug()<< "FOLDER PATH CHANGED" << path;
		this->reset();
	});
#else
	connect(this->fm, &FM::pathContentChanged, [&](const QUrl &path)
	{
		qDebug()<< "FOLDER PATH CHANGED" << path;
		if(path != this->path)
			return;
		this->sortList();
	});
#endif
	
    connect(this->fm, &FM::newItem, [&] (const FMH::MODEL &item, const QUrl &url)
	{
		if(this->path == url)
		{
			emit this->preItemAppended();
			this->list << item;
			emit this->postItemAppended();
		}
	});	
	
	const auto value = UTIL::loadSettings("SaveDirProps", "SETTINGS", this->saveDirProps).toBool();
	this->setSaveDirProps(value);	
	connect(this, &FMList::pathChanged, this, &FMList::reset);
}

void FMList::watchPath(const QString& path, const bool& clear)
{	
	#ifdef Q_OS_ANDROID
	
	if(!this->watcher->directories().isEmpty() && clear)
		this->watcher->removePaths(this->watcher->directories());
	
	if(path.isEmpty() || !FMH::fileExists(path) || !QUrl(path).isLocalFile())
		return;
	
	this->watcher->addPath(QString(path).replace("file://", ""));
	qDebug()<< "WATCHING PATHS" << this->watcher->directories();
#else
	Q_UNUSED(path)
	Q_UNUSED(clear)
#endif
}

void FMList::assignList(const FMH::MODEL_LIST& list)
{
    emit this->preListChanged();
    this->list =list;
    this->sortList();    
    
    this->count = static_cast<uint>(this->list.size());
    emit this->countChanged();
    
    this->setStatus({STATUS_CODE::READY, this->list.isEmpty() ? "Nothing here!" : "",  this->list.isEmpty() ? "This place seems to be empty" : "",this->list.isEmpty()  ? "folder-add" : "", this->list.isEmpty(), true});  

    emit this->postListChanged();
}

void FMList::setList()
{
    qDebug()<< "PATHTYPE FOR URL"<< pathType << path;
    
	switch(this->pathType)
	{			
		case FMList::PATHTYPE::SEARCH_PATH:			
			this->search(this->path.fileName(), this->searchPath, this->hidden, this->onlyDirs, this->filters);
			break; //ASYNC
			
		case FMList::PATHTYPE::TAGS_PATH:
            this->assignList(this->fm->getTagContent(this->path.fileName()));
			break; //SYNC	
			
		case FMList::PATHTYPE::CLOUD_PATH:
			this->fm->getCloudServerContent(this->path.toString(), this->filters, this->cloudDepth);
            break; //ASYNC

        default:
        {
            emit this->preListChanged();
            this->list.clear();
            emit this->postListChanged();

            const bool exists = this->path.isLocalFile() ? FMH::fileExists(this->path) : true;
            if(!exists)    
                this->setStatus({STATUS_CODE::ERROR, "Error", "This URL cannot be listed", "documentinfo", this->list.isEmpty(), exists});
            else{
                this->fm->getPathContent(this->path, this->hidden, this->onlyDirs, this->filters);                
            } 
            break;//ASYNC
        }
	}
}

void FMList::reset()
{	
		
	if(this->saveDirProps)
	{
		auto conf = FMH::dirConf(this->path.toString()+"/.directory");	
		this->sort = static_cast<FMList::SORTBY>(conf[FMH::MODEL_NAME[FMH::MODEL_KEY::SORTBY]].toInt());
        this->hidden = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN]].toBool();				
        this->foldersFirst = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::FOLDERSFIRST]].toBool();
	}else
	{	
        this->hidden = UTIL::loadSettings("HiddenFilesShown", "SETTINGS", this->hidden).toBool();
        this->foldersFirst = UTIL::loadSettings("FoldersFirst", "SETTINGS", this->foldersFirst).toBool();
		this->sort = static_cast<FMList::SORTBY>(UTIL::loadSettings("SortBy", "SETTINGS", this->sort).toInt());
	}
	
	emit this->sortByChanged();
	emit this->hiddenChanged();
	emit this->foldersFirstChanged();
    
	this->setList();	
}

FMH::MODEL_LIST FMList::items() const
{
	return this->list;
}

FMList::SORTBY FMList::getSortBy() const
{
	return this->sort;
}

void FMList::setSortBy(const FMList::SORTBY &key)
{	
	if(this->sort == key)
		return;
	
	emit this->preListChanged();
	
	this->sort = key;
	this->sortList();
	
	if(this->pathType == FMList::PATHTYPE::PLACES_PATH && this->trackChanges && this->saveDirProps)
		FMH::setDirConf(this->path.toString()+"/.directory", "MAUIFM", "SortBy", this->sort);
	else
		UTIL::saveSettings("SortBy", this->sort, "SETTINGS");
	
	emit this->sortByChanged();
	
	emit this->postListChanged();
}

void FMList::sortList()
{
    const FMH::MODEL_KEY key = static_cast<FMH::MODEL_KEY>(this->sort);
	auto index = 0;
	
	if(this->foldersFirst)
	{
        qSort(this->list.begin(), this->list.end(), [](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
		{
            Q_UNUSED(e2)
			const auto key = FMH::MODEL_KEY::MIME;
			if(e1[key] == "inode/directory")
				return true;
			
			return false;
		});
		
        for(const auto &item : this->list)
			if(item[FMH::MODEL_KEY::MIME] == "inode/directory")
				index++;
			else break;
			
			std::sort(this->list.begin(),this->list.begin() + index, [&key](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
		{			
            switch(key)
			{				
				case FMH::MODEL_KEY::SIZE:
				{				
                    if(e1[key].toDouble() > e2[key].toDouble())
						return true;
					break;
				}
				
				case FMH::MODEL_KEY::MODIFIED:
				case FMH::MODEL_KEY::DATE:
				{
					auto currentTime = QDateTime::currentDateTime();
					
                    auto date1 = QDateTime::fromString(e1[key], Qt::TextDate);
                    auto date2 = QDateTime::fromString(e2[key], Qt::TextDate);
					
					if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
						return true;
					
					break;
				}
				
				case FMH::MODEL_KEY::LABEL:
				{
                    const auto str1 = QString(e1[key]).toLower();
                    const auto str2 = QString(e2[key]).toLower();
					
					if(str1 < str2)
						return true;				
					break;
				}
				
				default:
                    if(e1[key] < e2[key])
						return true;
			}
			
			return false;
		});
	}
	
    std::sort(this->list.begin() + index, this->list.end(), [key](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
	{
        const auto role = key;
		
		switch(role)
		{
			case FMH::MODEL_KEY::MIME:
				if(e1[role] == "inode/directory")
					return true;
				break;
				
			case FMH::MODEL_KEY::SIZE:
			{				
				if(e1[role].toDouble() > e2[role].toDouble())
					return true;
				break;
			}
			
			case FMH::MODEL_KEY::MODIFIED:
			case FMH::MODEL_KEY::DATE:
			{
				auto currentTime = QDateTime::currentDateTime();
				
				auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
				auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);
				
				if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
					return true;
				
				break;
			}
			
			case FMH::MODEL_KEY::LABEL:
			{
				const auto str1 = QString(e1[role]).toLower();
				const auto str2 = QString(e2[role]).toLower();
				
				if(str1 < str2)
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

QString FMList::getPathName() const
{
    return this->pathName;
}

QUrl FMList::getPath() const
{
	return this->path;
}

void FMList::setPath(const QUrl &path)
{
	if(this->path == path)
		return;
	
    this->searchPath = this->path;
	
	this->path = path;
    NavHistory.appendPath(this->path);
    
    this->setStatus({STATUS_CODE::LOADING, "Loading content", "Almost ready!", "view-refresh", true, false});
	
	const auto __scheme = this->path.scheme();
    this->pathName = this->path.fileName();

    if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::SEARCH_PATH])
	{
		this->pathType = FMList::PATHTYPE::SEARCH_PATH;
		this->watchPath(QString());
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::CLOUD_PATH])
	{
		this->pathType = FMList::PATHTYPE::CLOUD_PATH;
		this->watchPath(QString());
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::APPS_PATH])
	{
		this->pathType = FMList::PATHTYPE::APPS_PATH;
		this->watchPath(QString());
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::TAGS_PATH])
	{
		this->pathType = FMList::PATHTYPE::TAGS_PATH;
		this->watchPath(QString());
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::TRASH_PATH])
	{
		this->pathType = FMList::PATHTYPE::TRASH_PATH;
        this->pathName = "Trash";
		this->watchPath(QString());
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::PLACES_PATH]) 
	{
		this->watchPath(this->path.toString());        
		this->pathType = FMList::PATHTYPE::PLACES_PATH;
        this->pathName = FMH::getDirInfoModel(this->path)[FMH::MODEL_KEY::LABEL];
		
	}else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::MTP_PATH])		
	{
		this->pathType = FMList::PATHTYPE::MTP_PATH;
        
    }else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::FISH_PATH] )		
	{
		this->pathType = FMList::PATHTYPE::FISH_PATH;
        
    }else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::REMOTE_PATH] )		
	{
		this->pathType = FMList::PATHTYPE::REMOTE_PATH;
    
    }else if(__scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::DRIVES_PATH] )		
	{
		this->pathType = FMList::PATHTYPE::DRIVES_PATH;
    }else
    {
        this->pathType = FMList::PATHTYPE::OTHER_PATH;
    }
	
    emit this->pathNameChanged();
    emit this->pathTypeChanged();
    emit this->pathChanged();
}

FMList::PATHTYPE FMList::getPathType() const
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
	
	emit this->filtersChanged();
	this->reset();
}

FMList::FILTER FMList::getFilterType() const
{
	return this->filterType;
}

void FMList::setFilterType(const FMList::FILTER &type)
{	
	if(this->filterType == type)
		return;
	
	this->filterType = type;
	this->filters = FMH::FILTER_LIST[static_cast<FMH::FILTER_TYPE>(this->filterType)];
	
	emit this->filtersChanged();
	emit this->filterTypeChanged();
	
	this->reset();
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
	
	if(this->pathType == FMList::PATHTYPE::PLACES_PATH && this->trackChanges && this->saveDirProps)
		FMH::setDirConf(this->path.toString()+"/.directory", "Settings", "HiddenFilesShown", this->hidden);
	else
		UTIL::saveSettings("HiddenFilesShown", this->hidden, "SETTINGS");
	
	emit this->hiddenChanged();
	this->reset();
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
	
	emit this->onlyDirsChanged();
	this->reset();
}

QVariantMap FMList::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	const auto model = this->list.at(index);
	
    return FMH::toMap(model);
}

void FMList::refresh()
{
	emit this->pathChanged();
}

void FMList::createDir(const QString& name)
{
	if(this->pathType == FMList::PATHTYPE::CLOUD_PATH)		
    {
#ifdef COMPONENT_SYNCING
        this->fm->createCloudDir(QString(this->path.toString()).replace(FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::CLOUD_PATH]+"/"+this->fm->sync->getUser(), ""), name);
#endif
    }else
	{
        FMStatic::createDir(this->path, name);
	}
}

void FMList::copyInto(const QStringList& urls)
{	
		this->fm->copy(QUrl::fromStringList(urls), this->path);		
}

void FMList::cutInto(const QStringList& urls)
{
	this->fm->cut(QUrl::fromStringList(urls), this->path);	
// 	else if(this->pathType == FMList::PATHTYPE::CLOUD_PATH)		
// 	{
// 		this->fm->createCloudDir(QString(this->path).replace(FMH::PATHTYPE_NAME[FMList::PATHTYPE::CLOUD_PATH]+"/"+this->fm->sync->getUser(), ""), name);
// 	}
}

void FMList::setDirIcon(const int &index, const QString &iconName)
{
	if(index >= this->list.size() || index < 0)
		return;	
	
	const auto path = QUrl(this->list.at(index)[FMH::MODEL_KEY::PATH]);
	
    if(!FMStatic::isDir(path))
		return;	

	FMH::setDirConf(path.toString()+"/.directory", "Desktop Entry", "Icon", iconName);
	
	this->list[index][FMH::MODEL_KEY::ICON] = iconName;	
	emit this->updateModel(index, QVector<int> {FMH::MODEL_KEY::ICON});
}

const QUrl FMList::getParentPath()
{
	switch(this->pathType)
	{		
		case FMList::PATHTYPE::PLACES_PATH:
            return FMStatic::parentDir(this->path).toString();
		default:
			return this->getPreviousPath();
	}	
}

QList<QUrl> FMList::getPosteriorPathHistory()
{
	return QList<QUrl> (); // todo : implement signal
}

QList<QUrl> FMList::getPreviousPathHistory()
{
	return QList<QUrl> (); // todo : implement signal
}

const QUrl FMList::getPosteriorPath()
{
    const auto url = NavHistory.getPosteriorPath();

    if(url.isEmpty())
        return this->path;

    return url;
}

const QUrl FMList::getPreviousPath() 
{	
    const auto url = NavHistory.getPreviousPath();

    if(url.isEmpty())
		return this->path;

    return url;
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

bool FMList::getFoldersFirst() const
{
	return this->foldersFirst;
}

void FMList::setFoldersFirst(const bool &value)
{
	if(this->foldersFirst == value)
		return;
	
	emit this->preListChanged();
	
	this->foldersFirst = value;
	
	if(this->pathType == FMList::PATHTYPE::PLACES_PATH && this->trackChanges && this->saveDirProps)
		FMH::setDirConf(this->path.toString()+"/.directory", "MAUIFM", "FoldersFirst", this->foldersFirst);
	else
		UTIL::saveSettings("FoldersFirst", this->foldersFirst, "SETTINGS");
	
	emit this->foldersFirstChanged();
	
	this->sortList();
	
	emit this->postListChanged();
}

void FMList::setSaveDirProps(const bool& value)
{
	if(this->saveDirProps == value)
		return;
	
	this->saveDirProps = value;	
	UTIL::saveSettings("SaveDirProps", this->saveDirProps, "SETTINGS");
	
	emit this->saveDirPropsChanged();
}

bool FMList::getSaveDirProps() const
{
	return this->saveDirProps;
}

void FMList::search(const QString& query, const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
{
	qDebug()<< "SEARCHING FOR" << query << path;
	
	if(!path.isLocalFile())
	{
        qWarning() << "URL recived is not a local file. So search will only filter the content" << path;
        this->filterContent(query, path, hidden, onlyDirs, filters);
		return;	  
	}	
	
	QFutureWatcher<FMH::PATH_CONTENT> *watcher = new QFutureWatcher<FMH::PATH_CONTENT>;
	connect(watcher, &QFutureWatcher<FMH::MODEL_LIST>::finished, [=]()
	{
		if(this->pathType != FMList::PATHTYPE::SEARCH_PATH)
			return;
		
		const auto res = watcher->future().result();
		
		if(res.path != this->searchPath.toString())
			return;
		
		this->assignList(res.content);        
		emit this->searchResultReady();
		
        watcher->deleteLater();
	});
	
	QFuture<FMH::PATH_CONTENT> t1 = QtConcurrent::run([=]() -> FMH::PATH_CONTENT
	{		
		FMH::PATH_CONTENT res;
		res.path = path.toString();				
        res.content = FMStatic::search(query, path, hidden, onlyDirs, filters);
		return res;
	});
    watcher->setFuture(t1);
}

void FMList::filterContent(const QString &query, const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
{
    if(this->list.isEmpty())
    {
        qDebug() << "Can not filter content. List is empty";
        return;
    }

    QFutureWatcher<FMH::PATH_CONTENT> *watcher = new QFutureWatcher<FMH::PATH_CONTENT>;
    connect(watcher, &QFutureWatcher<FMH::MODEL_LIST>::finished, [=]()
    {
        if(this->pathType != FMList::PATHTYPE::SEARCH_PATH)
            return;

        const auto res = watcher->future().result();

        if(res.path != this->searchPath.toString())
            return;

        this->assignList(res.content);
        emit this->searchResultReady();

        watcher->deleteLater();
    });

    QFuture<FMH::PATH_CONTENT> t1 = QtConcurrent::run([=]() -> FMH::PATH_CONTENT
    {
        FMH::MODEL_LIST m_content;
        FMH::PATH_CONTENT res;

        for(const auto &item : this->list)
        {
            if(item[FMH::MODEL_KEY::LABEL].contains(query, Qt::CaseInsensitive)
                    || item[FMH::MODEL_KEY::SUFFIX].contains(query, Qt::CaseInsensitive) || item[FMH::MODEL_KEY::MIME].contains(query, Qt::CaseInsensitive))
            {
                if(onlyDirs && item[FMH::MODEL_KEY::IS_DIR] == "true")
                {
                    m_content << item;
                    continue;
                }

                m_content << item;
            }
        }

        res.path = path.toString();
        res.content = m_content;
        return res;
    });
    watcher->setFuture(t1);
}

int FMList::getCloudDepth() const
{
	return this->cloudDepth;
}

void FMList::setCloudDepth(const int& value)
{
	if(this->cloudDepth == value)
		return;
	
	this->cloudDepth = value;
	
	emit this->cloudDepthChanged();
	this->reset();
}

uint FMList::getCount() const
{
	return this->count;
}

PathStatus FMList::getStatus() const
{
    return this->m_status;
}

void FMList::setStatus(const PathStatus &status)
{
    this->m_status = status;
    emit this->statusChanged();
}

bool FMList::itemIsFav(const QUrl &path)
{
	return this->fm->urlTagExists(path, "fav");
}

bool FMList::favItem(const QUrl &path)
{
	if(this->itemIsFav(path))
		return this->fm->removeTagToUrl("fav", path);
	
	return this->fm->addTagToUrl("fav", path);
}
