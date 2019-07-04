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
#include "modellist.h"

struct PathContent
{
	QString path;
	FMH::MODEL_LIST content;
};

class FM;
class QFileSystemWatcher;
class FMList : public ModelList
{
	Q_OBJECT

	Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged())

	Q_PROPERTY(bool hidden READ getHidden WRITE setHidden NOTIFY hiddenChanged())
	Q_PROPERTY(bool onlyDirs READ getOnlyDirs WRITE setOnlyDirs NOTIFY onlyDirsChanged())
	Q_PROPERTY(bool preview READ getPreview WRITE setPreview NOTIFY previewChanged())
	Q_PROPERTY(FMList::VIEW_TYPE viewType READ getViewType WRITE setViewType NOTIFY viewTypeChanged())
	Q_PROPERTY(int cloudDepth READ getCloudDepth WRITE setCloudDepth NOTIFY cloudDepthChanged())
	
	Q_PROPERTY(bool isBookmark READ getIsBookmark WRITE setIsBookmark NOTIFY isBookmarkChanged())
	Q_PROPERTY(bool contentReady READ getContentReady NOTIFY contentReadyChanged())
	
	Q_PROPERTY(QStringList filters READ getFilters WRITE setFilters NOTIFY filtersChanged())
	Q_PROPERTY(FMList::FILTER filterType READ getFilterType WRITE setFilterType NOTIFY filterTypeChanged())
	
	Q_PROPERTY(FMList::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())
    Q_PROPERTY(bool foldersFirst READ getFoldersFirst WRITE setFoldersFirst NOTIFY foldersFirstChanged())
    Q_PROPERTY(FMList::PATHTYPE pathType READ getPathType NOTIFY pathTypeChanged())
	
	Q_PROPERTY(bool trackChanges READ getTrackChanges WRITE setTrackChanges NOTIFY trackChangesChanged())
	Q_PROPERTY(bool saveDirProps READ getSaveDirProps WRITE setSaveDirProps NOTIFY saveDirPropsChanged())	
	
	Q_PROPERTY(bool pathExists READ getPathExists NOTIFY pathExistsChanged())
	Q_PROPERTY(bool pathEmpty READ getPathEmpty NOTIFY pathEmptyChanged())
	
	Q_PROPERTY(QString previousPath READ getPreviousPath)
	Q_PROPERTY(QString posteriorPath READ getPosteriorPath)
	Q_PROPERTY(QString parentPath READ getParentPath)
	
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
			NONE = FMH::FILTER_TYPE::NONE
			
		}; Q_ENUM(FILTER)
		
		enum PATHTYPE : uint_fast8_t
		{
			PLACES_PATH = FMH::PATHTYPE_KEY::PLACES_PATH,
			REMOTE_PATH = FMH::PATHTYPE_KEY::REMOTE_PATH,
			DRIVES_PATH = FMH::PATHTYPE_KEY::DRIVES_PATH,
			REMOVABLE_PATH = FMH::PATHTYPE_KEY::REMOVABLE_PATH,
			TAGS_PATH = FMH::PATHTYPE_KEY::TAGS_PATH,
			APPS_PATH = FMH::PATHTYPE_KEY::APPS_PATH,
			TRASH_PATH = FMH::PATHTYPE_KEY::TRASH_PATH,
			SEARCH_PATH = FMH::PATHTYPE_KEY::SEARCH_PATH,
			CLOUD_PATH = FMH::PATHTYPE_KEY::CLOUD_PATH
			
		}; Q_ENUM(PATHTYPE)
		
		enum VIEW_TYPE : uint_fast8_t
		{
			ICON_VIEW,
			LIST_VIEW,
			MILLERS_VIEW
			
		}; Q_ENUM(VIEW_TYPE)
		
		FMList(QObject *parent = nullptr);
		~FMList();
		
		FMH::MODEL_LIST items() const override;
		
		FMList::SORTBY getSortBy() const;
		void setSortBy(const FMList::SORTBY &key);
		
		QString getPath() const;
		void setPath(const QString &path);		
	
		FMList::PATHTYPE getPathType() const;
		
		QStringList getFilters() const;
		void setFilters(const QStringList &filters);
		
		FMList::FILTER getFilterType() const;
		void setFilterType(const FMList::FILTER &type);
		
		bool getHidden() const;
		void setHidden(const bool &state);
		
		bool getPreview() const;
		void setPreview(const bool &state);
		
		bool getOnlyDirs() const;
		void setOnlyDirs(const bool &state);
		
		QString getParentPath();
		
		QString getPreviousPath();
		void setPreviousPath(const QString &path);
		
		QString getPosteriorPath();
		void setPosteriorPath(const QString &path);
		
		bool getPathEmpty() const;
		bool getPathExists() const;
		
		bool getTrackChanges() const;
		void setTrackChanges(const bool &value);
		
		bool getIsBookmark() const;
		void setIsBookmark(const bool &value);

        bool getFoldersFirst() const;
        void setFoldersFirst(const bool &value);
		
		bool getSaveDirProps() const;
		void setSaveDirProps(const bool &value);
		
		bool getContentReady() const;
		void setContentReady(const bool &value);
		
		VIEW_TYPE getViewType() const;
		void setViewType(const VIEW_TYPE &value);
		
		int getCloudDepth() const;
		void setCloudDepth(const int &value);
		
private:
	FM *fm;
	QFileSystemWatcher *watcher;
	void pre();
	void pos();
	
	void reset();
	void setList();
	void sortList();
	void watchPath(const QString &path, const bool &clear = true);
    void search(const QString &query, const QString &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());
	void getPathContent();
	
	FMH::MODEL_LIST list = {{}};
	
	QString path = QString();
	QStringList filters = {};
	
	bool onlyDirs = false;
	bool hidden = false;
	bool preview = false;
	bool pathExists = false;
	bool pathEmpty = true;
	bool trackChanges = true;
	bool isBookmark = false;
    bool foldersFirst = false;
	bool saveDirProps = false;
	bool contentReady = false;
	int cloudDepth = 1;
	QString searchPath;
	
	VIEW_TYPE viewType = VIEW_TYPE::ICON_VIEW;
	FMList::SORTBY sort = FMList::SORTBY::MODIFIED;
	FMList::FILTER filterType = FMList::FILTER::NONE;
	FMList::PATHTYPE pathType = FMList::PATHTYPE::PLACES_PATH;
	
	QStringList prevHistory = {};
	QStringList postHistory = {};
	
public slots:
	QVariantMap get(const int &index) const;
	void refresh();
	
	void createDir(const QString &name);
	void copyInto(const QVariantList &files);
	void cutInto(const QVariantList &files);
	
	void test();
	
signals:
	void pathChanged();
	void pathTypeChanged();
	void filtersChanged();
	void filterTypeChanged();
	void hiddenChanged();
	void previewChanged();
	void onlyDirsChanged();
	void sortByChanged();
	void trackChangesChanged();
	void isBookmarkChanged();
    void foldersFirstChanged();
	void saveDirPropsChanged();
	void contentReadyChanged();
	void viewTypeChanged();
	void cloudDepthChanged();
	
	void pathEmptyChanged();
	void pathExistsChanged();
	
	void warning(QString message);
	void progress(int percent);

    void searchResultReady();
};

#endif // FMLIST_H
