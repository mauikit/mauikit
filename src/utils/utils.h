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

#ifndef UTILS_H
#define UTILS_H

#include <QString>
#include <QFileInfo>
#include <QSettings>
#include <QDebug>
#include <QColor>
#include <QImage>
#include <QUrl>
#include <QObject>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

namespace UTIL
{
    static const auto app = QCoreApplication::instance();	
    
    static const inline QString whoami()
    {
        #ifdef Q_OS_UNIX
        return qgetenv("USER"); ///for Mac or Linux
        #else
        return  qgetenv("USERNAME"); //for windows
        #endif
    }    

    #ifdef STATIC_MAUIKIT
    class Settings : public QObject
    #else
    class MAUIKIT_EXPORT Settings : public QObject    
    #endif
    {
        Q_OBJECT
    public:
        static Settings &local()
        {
            static Settings settings;
            return settings;
        }

        static Settings &global()
        {
            static Settings settings("mauiproject");
            return settings;
        }

        Settings(const Settings&) = delete;
        Settings& operator=(const Settings &) = delete;
        Settings(Settings &&) = delete;
        Settings & operator=(Settings &&) = delete;

        QUrl url() const
        {
            return QUrl::fromLocalFile(m_settings->fileName());
        }

        QVariant load(const QString &key, const QString &group, const QVariant &defaultValue) const
        {
            QVariant variant;
            m_settings->beginGroup(group);
            variant = m_settings->value(key,defaultValue);
            m_settings->endGroup();
            return variant;
        }
        void save(const QString &key, const QVariant &value, const QString &group)
        {
            m_settings->beginGroup(group);
            m_settings->setValue(key, value);
            m_settings->endGroup();
            emit this->settingChanged(url(), key, value, group);
        }

    private:
        explicit Settings(QString app = UTIL::app->applicationName(), QString org = UTIL::app->organizationName().isEmpty() ? QString("org.kde.maui") : UTIL::app->organizationName()) : QObject(nullptr)
        ,m_app(app)
        ,m_org(org)
        ,m_settings(new QSettings(m_org, m_app, this))
        { }

        ~Settings() {}

        QString m_app;
        QString m_org;
        QSettings *m_settings;

    signals:
        void settingChanged(QUrl url, QString key, QVariant value, QString group);
    };

    static inline void saveSettings(const QString &key, const QVariant &value, const QString &group, const bool &global = false)
    {
        if(global)
            Settings::global().save(key, value, group);
        else
            Settings::local().save(key, value, group);
    }
    
    static inline const QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue, const bool &global = false)
    {
        if(global)
            return Settings::global().load(key, group, defaultValue);
        else
            return Settings::local().load(key, group, defaultValue);
    }
    
    static inline bool isDark(const QColor &color)
    {
        const double darkness = 1-(0.299*color.red() + 0.587*color.green() + 0.114*color.blue())/255;
        return (darkness>0.5);
    }
    
    static inline QColor averageColour(QImage img) 
    {
        int r = 0;
        int g = 0;
        int b = 0;
        int c = 0;
        
        for (int i = 0; i < img.width(); i++) 
        {
            for (int ii = 0; ii < img.height(); ii++) 
            {
                QRgb pix = img.pixel(i, ii);
                if (pix == 0)
                    continue;
                
                c++;
                r += qRed(pix);
                g += qGreen(pix);
                b += qBlue(pix);
            }
        }
        r = r / c;
        g = g / c;
        b = b / c;
        
        QColor color = QColor::fromRgb(r,g,b);
        
        color.setHsv(color.hue(), color.saturation() / 4, color.value());
        
        return color;
        
    }

}


#endif // UTILS_H
