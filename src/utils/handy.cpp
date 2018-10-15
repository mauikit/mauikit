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

#include "handy.h"
#include "utils.h"
#include <QDebug>
#include <QIcon>
#include <QClipboard>
#include <QCoreApplication>
#include <QMimeData>

Handy::Handy(QObject *parent) : QObject(parent) 
{
	
}

Handy::~Handy()
{
	
}

QVariantMap Handy::appInfo()
{
	auto app =  UTIL::app;
	
	auto res = QVariantMap({{"name", app->applicationName()},
						   {"version", app->applicationVersion()},
						   {"organization", app->organizationName()},
						   {"domain", app->organizationDomain()},
						   {"mauikit", MAUIKIT_VERSION_STR},
						{"qt", QT_VERSION_STR} });
	
	#ifdef Q_OS_ANDROID
	res.insert("icon", QGuiApplication::windowIcon().name());
	#else
	res.insert("icon", QApplication::windowIcon().name());
	#endif
	
	qDebug() << "APP INFO" << res;
	
	return res;
	
}

QVariantMap Handy::userInfo()
{
	QString name = qgetenv("USER");
	if (name.isEmpty())
		name = qgetenv("USERNAME");
	
	auto res = QVariantMap({{"name", name}});
	
	return res;
	
}

bool Handy::saveSetting(const QString &key, const QVariant &value, const QString &group)
{
	UTIL::saveSettings(key, value, group);
	return true;
}

QVariant Handy::loadSetting(const QString &key, const QString &group, const QVariant &defaultValue)
{
	return UTIL::loadSettings(key, group, defaultValue);
}


QString Handy::getClipboard()
{
	#ifdef Q_OS_ANDROID
	auto clipbopard = QGuiApplication::clipboard();
	#else
	auto clipbopard = QApplication::clipboard();
	#endif

	auto mime = clipbopard->mimeData();
	if(mime->hasText())
		return clipbopard->text();
	
	return QString();
}

bool Handy::copyToClipboard(const QString &text)
{
	#ifdef Q_OS_ANDROID
	auto clipbopard = QGuiApplication::clipboard();
	#else
	auto clipbopard = QApplication::clipboard();
	#endif
	
	clipbopard->setText(text);
	
	return true;
}
