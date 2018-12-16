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

#ifndef STORE_H
#define STORE_H

#include <QObject>
#include "fmh.h"

#ifdef STATIC_MAUIKIT
#include "providermanager.h"
#include "provider.h"
#include "category.h"
#else
#include <Attica/ProviderManager>
#include <Attica/Provider>
#include <Attica/ListJob>
#include <Attica/Content>
#include <Attica/DownloadItem>
#include <Attica/AccountBalance>
#include <Attica/Person>
#include <Attica/Category>
#include <Attica/Project>
#endif

namespace STORE
{
	enum CATEGORY_KEY : uint_fast8_t
	{
		WALLPAPERS,
		IMAGES,
		COMICS,
		AUDIO,
		ART,
		CLIPS,
		MOVIES
	};
	
	enum ATTRIBUTE_KEY : uint_fast8_t
	{
		PREVIEW_1,
		PREVIEW_2,
		PREVIEW_SMALL_1,
		PREVIEW_SMALL_2,
		DOWNLOAD_LINK,
		XDG_TYPE
	};
	
	static const QHash<STORE::ATTRIBUTE_KEY, QString> ATTRIBUTE=
	{
		{STORE::ATTRIBUTE_KEY::PREVIEW_1, QString("previewpic1")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_2, QString("previewpic2")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_1, QString("smallpreviewpic1")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_2, QString("smallpreviewpic2")},
		{STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK, QString("downloadlink1")}, 
		{STORE::ATTRIBUTE_KEY::XDG_TYPE, QString("xdg_type")} 
	};
	
	static const QHash<CATEGORY_KEY, QStringList> CATEGORIES =
	{
		{CATEGORY_KEY::WALLPAPERS, QStringList
			{
				"wallpapers", 
				"wallpapers", 
				"Wallpaper", 
				"Wallpapers",
				"Wallpaper 800x600",
				"Wallpaper 1024x768", 
				"Wallpaper 1280x1024",
				"Wallpaper 1440x900", 
				"Wallpaper 1600x1200",
				"Wallpaper (other)",
				"KDE Wallpaper 800x600",
				"KDE Wallpaper 1024x768", 
				"KDE Wallpaper 1280x1024",
				"KDE Wallpaper 1440x900", 
				"KDE Wallpaper 1600x1200",
				"KDE Wallpaper (other)"			
			}			
		},
		
		{CATEGORY_KEY::COMICS, QStringList
			{
				"comics", 
				"Comics", 
				"comic", 
				"Comic"
				
			}			
		},
		
		{CATEGORY_KEY::ART, QStringList
			{
				"art", 
				"drawings", 
				"Art", 
				"Wallpapers", 
				"Drawings", 
				"Paintings", 
				"paintings"	
			}
		}
	};
}

class Store : public QObject
{
	Q_OBJECT
	
public:  
// 	 Q_ENUM(STORE::CATEGORY_KEY);	
	
	Store(QObject *parent = nullptr);   
	~Store();
	
	void searchFor(const STORE::CATEGORY_KEY &categoryKey, const QString &query = QString(), const int &limit = 10);
	void listProjects();
	void listCategories();
	
public slots:
	void providersChanged();
	void categoryListResult(Attica::BaseJob* j);
	void projectListResult(Attica::BaseJob *j);
	void contentListResult(Attica::BaseJob *j);
	
	void getPersonInfo(const QString &nick);
	
private:
	Attica::ProviderManager m_manager;
	// A provider that we will ask for data from openDesktop.org
	Attica::Provider m_provider;
	
signals:
	void storeReady();
	void contentReady(FMH::MODEL_LIST list);
	void warning(QString warning);
};




#endif // STORE_H
