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

#ifndef MAUIAPP_H
#define MAUIAPP_H
#include <QObject>
#include <QQuickItem>

#include "handy.h"
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

class MauiAccounts;
#ifdef STATIC_MAUIKIT
class MauiApp : public QObject
#else
class MAUIKIT_EXPORT MauiApp : public QObject
#endif
{
    Q_OBJECT
    
    Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(QString version READ getVersion CONSTANT)
	Q_PROPERTY(QString org READ getOrg CONSTANT)
	Q_PROPERTY(QString domain READ getDomain CONSTANT)
	Q_PROPERTY(QString iconName READ getIconName WRITE setIconName NOTIFY iconNameChanged)
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString mauikitVersion READ getMauikitVersion CONSTANT)
	Q_PROPERTY(QString qtVersion READ getQtVersion CONSTANT)
	Q_PROPERTY(MauiAccounts * accounts READ getAccounts CONSTANT FINAL)


public:  
    static MauiApp *qmlAttachedProperties(QObject *object);
    
	static MauiApp *instance();
	static QString getName() 
	{
		return Handy::appInfo().value(FMH::MODEL_NAME[FMH::MODEL_KEY::NAME]).toString();
	}
	
	static QString getVersion() 
	{
		return Handy::appInfo().value(FMH::MODEL_NAME[FMH::MODEL_KEY::VERSION]).toString();
	}
	
	static QString getOrg() 
	{
		return Handy::appInfo().value(FMH::MODEL_NAME[FMH::MODEL_KEY::ORG]).toString();
	}
	
	static QString getDomain() 
	{
		return Handy::appInfo().value(FMH::MODEL_NAME[FMH::MODEL_KEY::DOMAIN]).toString();
	}
	
	static QString getMauikitVersion() 
	{
		return Handy::appInfo().value("mauikit_version").toString();
	}	
	
	static QString getQtVersion() 
	{
		return Handy::appInfo().value("qt_version").toString();
	}
	
	QString getDescription() const
	{
		return description;
	}
	
	void setDescription(const QString &value) 
	{
		if(description == value)
			return;
		
		description = value;
		emit this->descriptionChanged(description);
	}
	
	QString getIconName() const
	{
		return iconName;
	}
	
	void setIconName(const QString &value) 
	{
		if(iconName == value)
			return;
		
		iconName = value;
		emit this->iconNameChanged(iconName);
	}
	
	MauiAccounts *getAccounts() const;
	
	~MauiApp();	
	
private:
	static MauiApp *m_instance;
	MauiApp(QObject *parent = nullptr);
	MauiApp(const MauiApp &other) = delete;
	MauiAccounts *m_accounts;
	
	QString description;
	QString iconName;
	
signals:
	void iconNameChanged(QString iconName);
	void descriptionChanged(QString description);
};


QML_DECLARE_TYPEINFO(MauiApp, QML_HAS_ATTACHED_PROPERTIES)

#endif // MAUIAPP_H
