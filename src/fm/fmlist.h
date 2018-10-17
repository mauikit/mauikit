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

#ifndef FMLIST_H
#define FMLIST_H

#include <QObject>
#include "fm.h"
/**
 * @todo write docs
 */
class FMList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged())
	Q_PROPERTY(bool hidden READ getHidden WRITE setHidden NOTIFY hiddenChanged())
	Q_PROPERTY(bool onlyDirs READ getOnlyDirs WRITE setOnlyDirs NOTIFY onlyDirsChanged())
	Q_PROPERTY(bool preview READ getPreview WRITE setPreview NOTIFY previewChanged())
	Q_PROPERTY(QStringList filters READ getFilters WRITE setFilters NOTIFY filtersChanged())
	
public:
    
	FMList(QObject *parent = nullptr);
    ~FMList();
	
	FMH::MODEL_LIST items() const;
	
	QString getPath() const;
	void setPath(const QString &path);
	
	QStringList getFilters() const;
	void setFilters(const QStringList &filters);
	
	bool getHidden() const;
	void setHidden(const bool &state);
	
	bool getPreview() const;
	void setPreview(const bool &state);
	
	bool getOnlyDirs() const;
	void setOnlyDirs(const bool &state);
	
private:
	FM *fm;
	
	void reset();
	void setList();
	
	FMH::MODEL_LIST list = {{}};
	QString path = QString();
	QStringList filters = {};
	bool onlyDirs = false;
	bool hidden = false;
	bool preview = false;
	
public slots:
	 QVariantMap get(const int &index) const;
	 
signals:
	void pathChanged();
	void filtersChanged();
	void hiddenChanged();
	void previewChanged();
	void onlyDirsChanged();
	
	void preItemAppended();
	void postItemAppended();
	void preItemRemoved(int index);
	void postItemRemoved();
	void updateModel(int index, QVector<int> roles);
	void preListChanged();
	void postListChanged();

};

#endif // FMLIST_H
