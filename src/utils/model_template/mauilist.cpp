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

#include "mauilist.h"
#include "mauimodel.h"

MauiList::MauiList(QObject *parent) : QObject(parent), m_model(nullptr)
{}

int MauiList::mappedIndex(const int &index) const
{
    if(this->m_model)
        return this->m_model->mappedToSource(index);

    return -1;
}

int MauiList::mappedIndexFromSource(const int &index) const
{
    if(this->m_model)
        return this->m_model->mappedFromSource(index);

    return -1;
}

bool MauiList::exists(const FMH::MODEL_KEY& key, const QString& value) const
{
	return this->indexOf(key, value) >= 0;
}

int MauiList::indexOf(const FMH::MODEL_KEY& key, const QString& value) const
{
    const auto items = this->items();
    const auto it = std::find_if(items.constBegin(), items.constEnd(), [&](const FMH::MODEL &item) -> bool
	{
        return item[key] == value;

	});
    
    if(it != items.constEnd())        
        return this->mappedIndexFromSource(std::distance(items.constBegin(), it));
    else return -1;
}

