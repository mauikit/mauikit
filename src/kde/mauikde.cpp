/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mauikde.h"
#include <KService>
#include <KMimeTypeTrader>
#include <KToolInvocation>
#include <KLocalizedString>
#include <QDebug>
#include <KRun>
#include <QFileInfo>
#include <KService>
#include <KServiceGroup>
#include <QDebug>
#include <KFileItem>
#include <KColorScheme>
#include <KColorSchemeManager>
#include <QModelIndex>
#include <QColor>
#include <QVariantList>
#include <KConfig>
#include <KConfigGroup>

#include "kdeconnect.h"


MAUIKDE * MAUIKDE::qmlAttachedProperties(QObject* object)
{
	Q_UNUSED(object)
	return MAUIKDE::instance();
}

MAUIKDE::MAUIKDE(QObject *parent) : QObject(parent)
{}

static QVariantMap createActionItem(const QString &label, const QString &actionId, const QVariant &argument = QVariant())
{
	QVariantMap map;
	
	map["label"] = label;
	map["actionId"] = actionId;
	
	if (argument.isValid())
		map["actionArgument"] = argument;	
	
	return map;
}

QVariantList MAUIKDE::services(const QUrl &url)
{
	qDebug()<<"trying to get mimes";
	QVariantList list;
	
	if (url.isValid())
	{
		KFileItem fileItem(url);	
		
		for(const auto &service : KMimeTypeTrader::self()->query(fileItem.mimetype(), "Application"))
		{
			const QString text = service->name().replace('&', "&&");
			QVariantMap item = createActionItem(text, "_kicker_fileItem_openWith", service->entryPath());
			item["icon"] = service->icon();
			item["serviceExec"] = service->exec();
			
			list << item;
		}			
		
		// 		list << createActionItem(i18n("Properties"), "_kicker_fileItem_properties");			
	} 
	
	return list;
}

bool MAUIKDE::sendToDevice(const QString &device, const QString &id, const QStringList &urls)
{
	for(const auto &url : urls)
		KdeConnect::sendToDevice(device, id, url);
	
	return true;
}

QVariantList MAUIKDE::devices()
{
	return KdeConnect::getDevices();
}

void MAUIKDE::openWithApp(const QString &exec, const QStringList &urls)
{
	KService service(exec);
	KRun::runApplication(service, QUrl::fromStringList(urls), nullptr);
}

void MAUIKDE::attachEmail(const QStringList &urls)
{
	if(urls.isEmpty()) return;
	
	QFileInfo file(urls[0]);
	
	KToolInvocation::invokeMailer("", "", "", file.baseName(), "Files shared... ", "", urls);
	//    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
	//    + url));
}

void MAUIKDE::email(const QString &to, const QString &cc, const QString &bcc, const QString &subject,  const QString &body, const QString &messageFile, const QStringList &urls)
{
	KToolInvocation::invokeMailer(to, cc, bcc, subject, body, messageFile, urls);
	//    QDesktopServices::openUrl(QUrl("mailto:?subject=test&body=test&attachment;="
	//    + url));
}

void MAUIKDE::setColorScheme(const QString &schemeName, const QString &bg, const QString &fg)
{
	const QString colorSchemeDir = FMH::DataPath+"/color-schemes/";
	
	const QString colorsFile = colorSchemeDir+schemeName+".colors";    
	
	if(!FMH::fileExists(colorSchemeDir))
		QDir(colorSchemeDir).mkpath(".");
	
	if(!FMH::fileExists(colorsFile))
	{
		QFile color_scheme_file(":/assets/maui-app.colors");
		if(color_scheme_file.copy(colorsFile))
		{            
			QFile copied_scheme_file(colorsFile);
			copied_scheme_file.setPermissions(QFile::ReadOwner|QFile::WriteOwner|QFile::ExeOwner|QFile::ReadGroup|QFile::ExeGroup|QFile::ReadOther|QFile::ExeOther);
			KConfig new_scheme_file(colorsFile);
			auto new_scheme_name = new_scheme_file.group("General");
			new_scheme_name.writeEntry("Name",  QVariant(schemeName));
			new_scheme_name.writeEntry("ColorScheme",  QVariant(schemeName));
		}            
	} 
	
	KColorSchemeManager manager;
	auto schemeModel = manager.indexForScheme(schemeName); 
	
	if(!schemeModel.isValid() && FMH::fileExists(colorsFile))
	{
		qDebug()<< "COLROS FILE EXISTS BUT IS INVALID";
		
		KConfig scheme_file(colorsFile);
		auto scheme_name = scheme_file.group("General");
		scheme_name.writeEntry("Name", QVariant(schemeName));
		scheme_name.writeEntry("ColorScheme",  QVariant(schemeName));
	}   
	
	
	schemeModel = manager.indexForScheme(schemeName);     
	
	if(schemeModel.isValid())
	{
		qDebug()<<"COLRO SCHEME IS VALID";
		if(!bg.isEmpty() || !fg.isEmpty())
		{
			
			qDebug()<<"COLRO SCHEME FILE EXISTS"<< colorsFile;
			KConfig file(colorsFile);
			auto group = file.group("WM");
			QColor color;                               
			
			if(!bg.isEmpty())
			{ 
				color.setNamedColor(bg);
				QVariantList rgb = {color.red(), color.green(), color.blue()}; 
				group.writeEntry("activeBackground", QVariant::fromValue(rgb));
				group.writeEntry("inactiveBackground", QVariant::fromValue(rgb));
				
			}                
			
			if(!fg.isEmpty())
			{ 
				color.setNamedColor(fg);
				QVariantList rgb = {color.red(), color.green(), color.blue()};
				group.writeEntry("activeForeground", QVariant::fromValue(rgb));
				group.writeEntry("inactiveForeground", QVariant::fromValue(rgb));                                 
			}
			
			file.group("Colors:Window");
			if(!bg.isEmpty())
			{ 
				color.setNamedColor(bg);
				QVariantList rgb = {color.red(), color.green(), color.blue()}; 
				group.writeEntry("BackgroundNormal", QVariant::fromValue(rgb));
				group.writeEntry("BackgroundAlternate", QVariant::fromValue(rgb));
				
			}                
			
			if(!fg.isEmpty())
			{ 
				color.setNamedColor(fg);
				QVariantList rgb = {color.red(), color.green(), color.blue()};
				group.writeEntry("ForegroundActive", QVariant::fromValue(rgb));
				group.writeEntry("ForegroundInactive", QVariant::fromValue(rgb));                                 
			}           
		}
		manager.activateScheme(schemeModel);            
	} 
}


FMH::MODEL_LIST MAUIKDE::getApps()
{
	FMH::MODEL_LIST res;
	KServiceGroup::Ptr group = KServiceGroup::root();
	
	bool sortByGenericName = false;
	
	KServiceGroup::List list = group->entries(true /* sorted */, true /* excludeNoDisplay */,
											  true /* allowSeparators */, sortByGenericName /* sortByGenericName */);
	
	for (KServiceGroup::List::ConstIterator it = list.constBegin(); it != list.constEnd(); it++)
	{
		const KSycocaEntry::Ptr p = (*it);
		
		if (p->isType(KST_KServiceGroup))
		{
			KServiceGroup::Ptr s(static_cast<KServiceGroup*>(p.data()));
			
			if (!s->noDisplay() && s->childCount() > 0)
			{
				qDebug()<< "Getting app"<<s->icon();
				
				res << FMH::MODEL
				{
					{FMH::MODEL_KEY::ICON, s->icon()},
					{FMH::MODEL_KEY::LABEL, s->name()},
					{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::APPS_PATH]+s->entryPath()}
				};
			}
		}
	}
	return res;
}

FMH::MODEL_LIST MAUIKDE::getApps(const QString &groupStr)
{	
	const auto grp = QString(groupStr).replace("/", "")+"/";
	qDebug() << "APP GROUDP" << groupStr<< grp;
	
	if(grp.isEmpty()) return getApps();
	
	
	FMH::MODEL_LIST res;
	//    const KServiceGroup::Ptr group(static_cast<KServiceGroup*>(groupStr));
	auto group = new KServiceGroup(grp);
	KServiceGroup::List list = group->entries(true /* sorted */,
											  true /* excludeNoDisplay */,
										   false /* allowSeparators */,
										   true /* sortByGenericName */);
	
	for (KServiceGroup::List::ConstIterator it = list.constBegin(); it != list.constEnd(); it++)
	{
		const KSycocaEntry::Ptr p = (*it);
		
		if (p->isType(KST_KService))
		{
			const KService::Ptr s(static_cast<KService*>(p.data()));
			
			if (s->noDisplay())
				continue;
			
			res << FMH::MODEL {
				
				{FMH::MODEL_KEY::ICON, s->icon()},
				{FMH::MODEL_KEY::EXECUTABLE, "true"},
				{FMH::MODEL_KEY::LABEL, s->name()},
				{FMH::MODEL_KEY::PATH, s->entryPath()}
			};
			
			
		} else if (p->isType(KST_KServiceSeparator))
		{
			qDebug()<< "separator wtf";
			
		} else if (p->isType(KST_KServiceGroup))
		{
			const KServiceGroup::Ptr s(static_cast<KServiceGroup*>(p.data()));
			
			if (s->childCount() == 0)
				continue;
			
			res <<  FMH::MODEL { 
				{FMH::MODEL_KEY::ICON, s->icon()},
				{FMH::MODEL_KEY::EXECUTABLE, "true"},				
				{FMH::MODEL_KEY::LABEL, s->name()},
				{FMH::MODEL_KEY::PATH, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::APPS_PATH]+s->entryPath()}
			};
		}
	}
	
	return res;
}

void MAUIKDE::launchApp(const QString &app)
{
	KService service(app);
	KRun::runApplication(service, {}, nullptr);
}
