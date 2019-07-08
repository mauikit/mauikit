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

PathList::PathList(QObject *parent) : ModelList(parent)
{
}

PathList::~PathList()
{
}

QVariantMap PathList::get(const int& index) const
{
	return QVariantMap();
}

QString PathList::getPath()
{
	return this->m_path;
}

FMH::MODEL_LIST PathList::items() const
{
	return this->list;
}

void PathList::setPath(const QString& path) const
{
	if(path == this->m_path)
		return;
}

FMH::MODEL_LIST PathList::splitPath(const QString& path)
{
	const auto paths = path.split("/");
	return std::accumulate(paths.constBegin(), paths.constEnd(), FMH::MODEL_LIST(), [](FMH::MODEL_LIST &list, const QString &part) -> FMH::MODEL_LIST
	{		
		const auto url = list.last()[FMH::MODEL_KEY::PATH] + QString(part) + "/";
		if(!part.isEmpty())
			list << FMH::getDirInfoModel(url);
		
		return list;
	});
}

