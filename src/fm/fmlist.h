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

class FM;
class FMList : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged())
	Q_PROPERTY(bool hidden READ getHidden WRITE setHidden NOTIFY hiddenChanged())
	Q_PROPERTY(bool onlyDirs READ getOnlyDirs WRITE setOnlyDirs NOTIFY onlyDirsChanged())
	Q_PROPERTY(bool preview READ getPreview WRITE setPreview NOTIFY previewChanged())
	Q_PROPERTY(bool isBookmark READ getIsBookmark WRITE setIsBookmark NOTIFY isBookmarkChanged())
	
	Q_PROPERTY(QStringList filters READ getFilters WRITE setFilters NOTIFY filtersChanged())
	Q_PROPERTY(FMH::FILTER_TYPE filterType READ getFilterType WRITE setFilterType NOTIFY filterTypeChanged())
	
	Q_PROPERTY(FMH::MODEL_KEY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())
	Q_PROPERTY(FMH::PATHTYPE_KEY pathType READ getPathType NOTIFY pathTypeChanged())
	
	Q_PROPERTY(bool trackChanges READ getTrackChanges WRITE setTrackChanges NOTIFY trackChangesChanged())
	
	Q_PROPERTY(bool pathExists READ getPathExists NOTIFY pathExistsChanged())
	Q_PROPERTY(bool pathEmpty READ getPathEmpty NOTIFY pathEmptyChanged())
	
	Q_PROPERTY(QString previousPath READ getPreviousPath)
	Q_PROPERTY(QString posteriorPath READ getPosteriorPath)
	Q_PROPERTY(QString parentPath READ getParentPath)
	
	public:
		Q_ENUM(FMH::MODEL_KEY)
		Q_ENUM(FMH::FILTER_TYPE)
		Q_ENUM(FMH::PATHTYPE_KEY)
		
		FMList(QObject *parent = nullptr);
		~FMList();
		
		FMH::MODEL_LIST items() const;
		
		FMH::MODEL_KEY getSortBy() const;
		void setSortBy(const FMH::MODEL_KEY &key);
		
		QString getPath() const;
		void setPath(const QString &path);
		
		FMH::PATHTYPE_KEY getPathType() const;
		
		QStringList getFilters() const;
		void setFilters(const QStringList &filters);
		
		FMH::FILTER_TYPE getFilterType() const;
		void setFilterType(const FMH::FILTER_TYPE &type);
		
		bool getHidden() const;
		void setHidden(const bool &state);
		
		bool getPreview() const;
		void setPreview(const bool &state);
		
		bool getOnlyDirs() const;
		void setOnlyDirs(const bool &state);
		
		QString getParentPath() const;
		
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
		
private:
	FM *fm;
	
	void reset();
	void setList();
	void sortList();
	
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
	
	FMH::MODEL_KEY sort = FMH::MODEL_KEY::MODIFIED;
	FMH::FILTER_TYPE filterType = FMH::FILTER_TYPE::NONE;
	FMH::PATHTYPE_KEY pathType = FMH::PATHTYPE_KEY::PLACES_PATH;
	
	QStringList prevHistory = {};
	QStringList postHistory = {};
	
public slots:
	QVariantMap get(const int &index) const;
	void refresh();
	
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
	
	void pathEmptyChanged();
	void pathExistsChanged();
	
	void preItemAppended();
	void postItemAppended();
	void preItemRemoved(int index);
	void postItemRemoved();
	void updateModel(int index, QVector<int> roles);
	void preListChanged();
	void postListChanged();
	
};

#endif // FMLIST_H
