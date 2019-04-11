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
#include <QOperatingSystemVersion>
#include "fmh.h"

Handy::Handy(QObject *parent) : QObject(parent) {}

Handy::~Handy() {}

QVariantMap Handy::appInfo()
{
	auto app =  UTIL::app;
	
    auto res = QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::NAME], app->applicationName()},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::VERSION], app->applicationVersion()},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::ORG], app->organizationName()},
                           {FMH::MODEL_NAME[FMH::MODEL_KEY::DOMAIN], app->organizationDomain()},
                           {"mauikit_version", MAUIKIT_VERSION_STR},
                           {"qt_version", QT_VERSION_STR} });
	
	#ifdef Q_OS_ANDROID
    res.insert(FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], QGuiApplication::windowIcon().name());
	#else
    res.insert(FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], QApplication::windowIcon().name());
	#endif	
	
    return res;
}

QVariantMap Handy::userInfo()
{
	QString name = qgetenv("USER");
	if (name.isEmpty())
		name = qgetenv("USERNAME");
	
    auto res = QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::NAME], name}});
	
	return res;
	
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

int Handy::version()
{
    auto current = QOperatingSystemVersion::current();
    return current.majorVersion();
}
