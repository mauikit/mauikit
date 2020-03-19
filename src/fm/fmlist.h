/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  Camilo Higuita <email>
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

#ifndef FMLIST_H
#define FMLIST_H

#include <QObject>
#include "fmh.h"
#include "mauilist.h"


enum STATUS_CODE : uint_fast8_t
{
	LOADING,  
	ERROR,
	READY
}; 

class PathStatus
{
	Q_GADGET
	
	Q_PROPERTY(STATUS_CODE code MEMBER m_code)
	Q_PROPERTY(QString title MEMBER m_title)
	Q_PROPERTY(QString message MEMBER m_message)
	Q_PROPERTY(QString icon MEMBER m_icon)
	Q_PROPERTY(bool empty MEMBER m_empty)
	Q_PROPERTY(bool exists MEMBER m_exists)
	
public:    
	
	STATUS_CODE m_code;
	QString m_title;
	QString m_message;
	QString m_icon;
	bool m_empty = false;
	bool m_exists = false;
};
Q_DECLARE_METATYPE(PathStatus)

static inline struct
{
	void appendPath(const QUrl &path)
	{
		this->prev_history.append(path);
	}
	
	QUrl getPosteriorPath()
	{
		if(this->post_history.isEmpty())
			return QUrl();
		
		return this->post_history.takeLast();
	}
	
	QUrl getPreviousPath()
	{
		if(this->prev_history.isEmpty())
			return QUrl();
		
		if(this->prev_history.length() < 2)
			return this->prev_history.at(0);
		
		this->post_history.append(this->prev_history.takeLast());
		
		return this->prev_history.takeLast();
	}
	
private:
	QVector<QUrl> prev_history;
	QVector<QUrl> post_history;
	
} NavHistory;

class FM;
class QFileSystemWatcher;
class FMList : public MauiList
{
	Q_OBJECT
	
	//writable
	Q_PROPERTY(QUrl path READ getPath WRITE setPath NOTIFY pathChanged)
	
	Q_PROPERTY(bool hidden READ getHidden WRITE setHidden NOTIFY hiddenChanged)
	Q_PROPERTY(bool onlyDirs READ getOnlyDirs WRITE setOnlyDirs NOTIFY onlyDirsChanged)
	Q_PROPERTY(bool foldersFirst READ getFoldersFirst WRITE setFoldersFirst NOTIFY foldersFirstChanged)
	Q_PROPERTY(int cloudDepth READ getCloudDepth WRITE setCloudDepth NOTIFY cloudDepthChanged)  
	
	Q_PROPERTY(QStringList filters READ getFilters WRITE setFilters NOTIFY filtersChanged)
	Q_PROPERTY(FMList::FILTER filterType READ getFilterType WRITE setFilterType NOTIFY filterTypeChanged)	
	Q_PROPERTY(FMList::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
	
	Q_PROPERTY(bool trackChanges READ getTrackChanges WRITE setTrackChanges NOTIFY trackChangesChanged)
	Q_PROPERTY(bool saveDirProps READ getSaveDirProps WRITE setSaveDirProps NOTIFY saveDirPropsChanged)	
	
	//readonly 
	Q_PROPERTY(QString pathName READ getPathName NOTIFY pathNameChanged)
	Q_PROPERTY(FMList::PATHTYPE pathType READ getPathType NOTIFY pathTypeChanged)
	
	Q_PROPERTY(PathStatus status READ getStatus NOTIFY statusChanged) 
	
	Q_PROPERTY(QList<QUrl> previousPathHistory READ getPreviousPathHistory) //interface for NavHistory
	Q_PROPERTY(QList<QUrl> posteriorPathHistory READ getPreviousPathHistory) //interface for NavHistory
	Q_PROPERTY(QUrl previousPath READ getPreviousPath) //interface for NavHistory
	Q_PROPERTY(QUrl posteriorPath READ getPosteriorPath) //interface for NavHistory
	
	Q_PROPERTY(QUrl parentPath READ getParentPath)    
	
public:
	enum SORTBY : uint_fast8_t
	{
		SIZE = FMH::MODEL_KEY::SIZE,
		MODIFIED = FMH::MODEL_KEY::MODIFIED,
		DATE = FMH::MODEL_KEY::DATE,
		LABEL = FMH::MODEL_KEY::LABEL,
		MIME = FMH::MODEL_KEY::MIME,
		ADDDATE = FMH::MODEL_KEY::MIME,
		TITLE = FMH::MODEL_KEY::TITLE,
		PLACE = FMH::MODEL_KEY::PLACE,
		FORMAT = FMH::MODEL_KEY::FORMAT
		
	}; Q_ENUM(SORTBY)
	
	enum FILTER : uint_fast8_t
	{
		AUDIO = FMH::FILTER_TYPE::AUDIO,
		VIDEO= FMH::FILTER_TYPE::VIDEO,
		TEXT = FMH::FILTER_TYPE::TEXT,
		IMAGE = FMH::FILTER_TYPE::IMAGE,
		DOCUMENT = FMH::FILTER_TYPE::DOCUMENT,
		NONE = FMH::FILTER_TYPE::NONE
		
	}; Q_ENUM(FILTER)
	
	enum PATHTYPE : uint_fast8_t
	{
		PLACES_PATH = FMH::PATHTYPE_KEY::PLACES_PATH,
		FISH_PATH = FMH::PATHTYPE_KEY::FISH_PATH,
		MTP_PATH = FMH::PATHTYPE_KEY::MTP_PATH,
		REMOTE_PATH = FMH::PATHTYPE_KEY::REMOTE_PATH,
		DRIVES_PATH = FMH::PATHTYPE_KEY::DRIVES_PATH,
		REMOVABLE_PATH = FMH::PATHTYPE_KEY::REMOVABLE_PATH,
		TAGS_PATH = FMH::PATHTYPE_KEY::TAGS_PATH,
		APPS_PATH = FMH::PATHTYPE_KEY::APPS_PATH,
		TRASH_PATH = FMH::PATHTYPE_KEY::TRASH_PATH,
		CLOUD_PATH = FMH::PATHTYPE_KEY::CLOUD_PATH,
		QUICK_PATH = FMH::PATHTYPE_KEY::QUICK_PATH,
		OTHER_PATH = FMH::PATHTYPE_KEY::OTHER_PATH
		
	}; Q_ENUM(PATHTYPE)
	
	enum VIEW_TYPE : uint_fast8_t
	{
		ICON_VIEW,
		LIST_VIEW,
		MILLERS_VIEW
		
	}; Q_ENUM(VIEW_TYPE)
	
	Q_ENUM(STATUS_CODE)        
	
	FMList(QObject *parent = nullptr);	
	
	FMH::MODEL_LIST items() const final override;
	
	FMList::SORTBY getSortBy() const;
	void setSortBy(const FMList::SORTBY &key);
	
	QUrl getPath() const;
	void setPath(const QUrl &path);	
	
	QString getPathName() const;
	
	FMList::PATHTYPE getPathType() const;
	
	QStringList getFilters() const;
	void setFilters(const QStringList &filters);
	
	FMList::FILTER getFilterType() const;
	void setFilterType(const FMList::FILTER &type);
	
	bool getHidden() const;
	void setHidden(const bool &state);
	
	bool getOnlyDirs() const;
	void setOnlyDirs(const bool &state);
	
	const QUrl getParentPath();
	
	static QList<QUrl> getPreviousPathHistory();		
	static QList<QUrl> getPosteriorPathHistory();
	const QUrl getPreviousPath();		
	const QUrl getPosteriorPath();
	
	bool getTrackChanges() const;
	void setTrackChanges(const bool &value);
	
	bool getFoldersFirst() const;
	void setFoldersFirst(const bool &value);
	
	bool getSaveDirProps() const;
	void setSaveDirProps(const bool &value);
	
	int getCloudDepth() const;
	void setCloudDepth(const int &value);
	
	void setStatus(const PathStatus &status);
	PathStatus getStatus() const;
	
private:
	FM *fm;
	QFileSystemWatcher *watcher;
	
	void clear();
	void reset();
	void setList();
	void assignList(const FMH::MODEL_LIST &list);
	void appendToList(const FMH::MODEL_LIST &list);
	void sortList();
	void watchPath(const QString &path, const bool &clear = true);
	void search(const QString &query, const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());
	void filterContent(const QString &query, const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());
	
	FMH::MODEL_LIST list = {{}};
	
	QUrl path;
	QString pathName = QString();
	QStringList filters = {};
	
	bool onlyDirs = false;
	bool hidden = false;
	
	bool trackChanges = true;
	bool foldersFirst = false;
	bool saveDirProps = false;
	int cloudDepth = 1;	
	
	PathStatus m_status;
	
	FMList::SORTBY sort = FMList::SORTBY::MODIFIED;
	FMList::FILTER filterType = FMList::FILTER::NONE;
	FMList::PATHTYPE pathType = FMList::PATHTYPE::PLACES_PATH;
	
	QList<QUrl> prevHistory = {};
	QList<QUrl> postHistory = {};
	
public slots:
	QVariantMap get(const int &index) const;
	void refresh();
	
	void createDir(const QString &name);
	void copyInto(const QStringList &urls);
	void cutInto(const QStringList &urls);
	
	void setDirIcon(const int &index, const QString &iconName);
	
	bool itemIsFav(const QUrl &path);
	bool favItem(const QUrl &path);
	
	void remove(const int &index);
	void moveFileToTrash(const int &index);
	void deleteFile(const int &index);
	
	void search(const QString &query, const FMList *currentFMList);
	
signals:
	void pathChanged();
	void pathNameChanged();
	void pathTypeChanged();
	void filtersChanged();
	void filterTypeChanged();
	void hiddenChanged();
	void onlyDirsChanged();
	void sortByChanged();
	void trackChangesChanged();
	void foldersFirstChanged();
	void saveDirPropsChanged();
	void statusChanged();
	void cloudDepthChanged();
	
	void warning(QString message);
	void progress(int percent);
	
	void searchResultReady();
	
}; 

#endif // FMLIST_H
