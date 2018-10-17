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

FMList::FMList(QObject *parent) : QObject(parent)
{
	this->fm = new FM(this);
	
	connect(fm, &FM::pathModified, this, [this]()
	{
		emit this->preListChanged();
		emit this->postListChanged();
	});
	
	connect(this, &FMList::pathChanged, this, &FMList::reset);	
	connect(this, &FMList::preListChanged, this, &FMList::setList);
}

FMList::~FMList()
{
	
}

void FMList::setList()
{
	this->list = this->fm->getPathContent(this->path, this->hidden, this->onlyDirs, this->filters);	
}

void FMList::reset()
{
	auto conf = FMH::dirConf(this->path+"/.directory");
	
	this->hidden = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN]].toBool();
	emit this->hiddenChanged();
	
	this->preview = conf[FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL]].toBool();
	emit this->previewChanged();
	
	this->setList();
}

FMH::MODEL_LIST FMList::items() const
{
	return this->list;
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
	this->fm->watchPath(this->path);
	emit this->pathChanged();
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
	emit this->postListChanged();}
	
	bool FMList::getHidden() const
	{
		return this->hidden;
	}
	
	void FMList::setHidden(const bool &state)
	{
		if(this->hidden == state)
			return;
		
		this->hidden = state;
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
	
