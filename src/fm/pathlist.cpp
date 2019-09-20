/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
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

#include "pathlist.h"
#include "fm.h"

PathList::PathList(QObject *parent) : MauiList(parent)
{
	
}

PathList::~PathList() {}

QVariantMap PathList::get(const int& index) const
{
	if(this->list.isEmpty() || index >= this->list.size() || index < 0)
	{
		return QVariantMap();
	}
	
	const auto model = this->list.at(index);	
	return FM::toMap(model);
}

QString PathList::getPath() const
{
	return this->m_path;
}

FMH::MODEL_LIST PathList::items() const
{
	return this->list;
}

void PathList::setPath(const QString& path)
{	
	if(path == this->m_path)
		return;	
	
	if(!this->list.isEmpty() && FM::parentDir(path) == this->m_path)
	{
		// 			qDebug() << "APPENDING PATHS TO MODEL << "<< FM::parentDir(this->m_path) << this->list.last()[FMH::MODEL_KEY::PATH];
		emit this->preItemAppended();
		this->list << FMH::getDirInfoModel(path);
		emit this->postItemAppended();
	}else{
		emit this->preListChanged();
		this->list.clear();
		this->list << PathList::splitPath(path);
		emit this->postListChanged();
	}	
	
	this->m_path = path;	
	emit this->pathChanged();	
}

FMH::MODEL_LIST PathList::splitPath(const QString& path)
{
	auto __url = QUrl(path);
	const auto scheme = __url.scheme();
	__url.setScheme("");
	
	const auto m_url = __url.toString();
	
	auto paths = m_url.split("/", QString::SplitBehavior::SkipEmptyParts);
	
	if(paths.isEmpty())
	{
		return {{{FMH::MODEL_KEY::LABEL, QString()}, {FMH::MODEL_KEY::PATH, path}}};
	}
	
	return std::accumulate(paths.constBegin(), paths.constEnd(), FMH::MODEL_LIST(), [scheme](FMH::MODEL_LIST &list, const QString &part) -> FMH::MODEL_LIST
	{	
		const auto url = list.isEmpty() ? QString(scheme + (scheme == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::PLACES_PATH] ? ":///" : "://")  +part) : list.last()[FMH::MODEL_KEY::PATH] + QString("/"+part);		
		
		if(!url.isEmpty())
			list << FMH::MODEL 
			{
				{FMH::MODEL_KEY::LABEL, part},
				{FMH::MODEL_KEY::PATH, url}
			};
		
		return list;
	});
}

