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
#include <QTouchDevice>

#include "fmh.h"

Handy::Handy(QObject *parent) : QObject(parent), m_isTouch(Handy::isTouch())
{}

#ifdef Q_OS_ANDROID
static inline struct
{
	QList<QUrl> urls;
	QString text;
	
	bool hasUrls(){ return !urls.isEmpty(); }
	bool hasText(){ return !text.isEmpty(); }
	
} _clipboard;
#endif

QVariantMap Handy::appInfo()
{
	auto res = QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::NAME], qApp->applicationName()},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::VERSION], qApp->applicationVersion()},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::ORG], qApp->organizationName()},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::DOMAIN_M], qApp->organizationDomain()},
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
	
	return QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::NAME], name}});	
}

QString Handy::getClipboardText()
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

QVariantMap Handy::getClipboard()
{
	QVariantMap res;
	#ifdef Q_OS_ANDROID
	if(_clipboard.hasUrls())
		res.insert("urls", QUrl::toStringList(_clipboard.urls));
	
	if(_clipboard.hasText())
		res.insert("text", _clipboard.text);
	#else
	auto clipboard = QApplication::clipboard();
	
	auto mime = clipboard->mimeData();
	if(mime->hasUrls())
		res.insert("urls", QUrl::toStringList(mime->urls()));
	
	if(mime->hasText())
		res.insert("text", mime->text());
	#endif
	return res;
}

bool Handy::copyToClipboard(const QVariantMap &value)
{
	#ifdef Q_OS_ANDROID
	if(value.contains("urls"))
		_clipboard.urls = QUrl::fromStringList(value["urls"].toStringList());
	
	if(value.contains("text"))
		_clipboard.text = value["text"].toString();
	
	return true;
	#else
	auto clipboard = QApplication::clipboard();
	QMimeData* mimeData = new QMimeData();
	
	if(value.contains("urls"))
		mimeData->setUrls(QUrl::fromStringList(value["urls"].toStringList()));
	
	if(value.contains("text"))
		mimeData->setText(value["text"].toString());
	
	clipboard->setMimeData(mimeData);
	return true;
	#endif
	
	return false;
}

bool Handy::copyTextToClipboard(const QString &text)
{
	#ifdef Q_OS_ANDROID
	Handy::copyToClipboard({{"text", text}});	
	#else
	QApplication::clipboard()->setText(text);
	#endif
	return true;
}

int Handy::version()
{
	return QOperatingSystemVersion::current().majorVersion();
}

bool Handy::isAndroid()
{
	return FMH::isAndroid();
}

bool Handy::isLinux()
{
	return FMH::isLinux();
}

bool Handy::isTouch()
{
	qDebug()<< "CHECKIGN IS IT IS TROYCH";
	for(const auto &device : QTouchDevice::devices())
	{
		if(device->type() == QTouchDevice::TouchScreen)
			return true;
		
		qDebug()<< "DEVICE CAPABILITIES" << device->capabilities() << device->name();
	}
	
	return false;	
}

bool Handy::isWindows()
{
	return FMH::isWindows();
}

bool Handy::isMac()
{
	return FMH::isMac();
}




