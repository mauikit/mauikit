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

#include <QColor>
#include <QDebug>
#include <QFileInfo>
#include <QImage>
#include <QObject>
#include <QSettings>
#include <QString>
#include <QUrl>

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

/**
 * @brief whoami
 * @return
 */
static const inline QString whoami()
{
#ifdef Q_OS_UNIX
    return qgetenv("USER"); /// for Mac or Linux
#else
    return qgetenv("USERNAME"); // for windows
#endif
}

/**
 * @brief The Settings class
 */
#ifdef STATIC_MAUIKIT
class Settings : public QObject
#else
class MAUIKIT_EXPORT Settings : public QObject
#endif
{
    Q_OBJECT
public:
    /**
     * @brief local
     * @return
     */
    static Settings &local()
    {
        static Settings settings;
        return settings;
    }

    /**
     * @brief global
     * @return
     */
    static Settings &global()
    {
        static Settings settings("mauiproject");
        return settings;
    }

    Settings(const Settings &) = delete;
    Settings &operator=(const Settings &) = delete;
    Settings(Settings &&) = delete;
    Settings &operator=(Settings &&) = delete;

    /**
     * @brief url
     * @return
     */
    QUrl url() const
    {
        return QUrl::fromLocalFile(m_settings->fileName());
    }

    /**
     * @brief load
     * @param key
     * @param group
     * @param defaultValue
     * @return
     */
    QVariant load(const QString &key, const QString &group, const QVariant &defaultValue) const
    {
        QVariant variant;
        m_settings->beginGroup(group);
        variant = m_settings->value(key, defaultValue);
        m_settings->endGroup();
        return variant;
    }

    /**
     * @brief save
     * @param key
     * @param value
     * @param group
     */
    void save(const QString &key, const QVariant &value, const QString &group)
    {
        m_settings->beginGroup(group);
        m_settings->setValue(key, value);
        m_settings->endGroup();
        emit this->settingChanged(url(), key, value, group);
    }

private:
    explicit Settings(QString app = UTIL::app->applicationName(), QString org = UTIL::app->organizationName().isEmpty() ? QString("org.kde.maui") : UTIL::app->organizationName())
        : QObject(nullptr)
        , m_app(app)
        , m_org(org)
        , m_settings(new QSettings(m_org, m_app, this))
    {
    }

    QString m_app;
    QString m_org;
    QSettings *m_settings;

signals:
    /**
     * @brief settingChanged
     * @param url
     * @param key
     * @param value
     * @param group
     */
    void settingChanged(QUrl url, QString key, QVariant value, QString group);
};

/**
 * @brief saveSettings
 * @param key
 * @param value
 * @param group
 * @param global
 */
static inline void saveSettings(const QString &key, const QVariant &value, const QString &group, const bool &global = false)
{
    if (global)
        Settings::global().save(key, value, group);
    else
        Settings::local().save(key, value, group);
}

/**
 * @brief loadSettings
 * @param key
 * @param group
 * @param defaultValue
 * @param global
 * @return
 */
static inline const QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue, const bool &global = false)
{
    if (global)
        return Settings::global().load(key, group, defaultValue);
    else
        return Settings::local().load(key, group, defaultValue);
}

/**
 * @brief isDark
 * @param color
 * @return
 */
static inline bool isDark(const QColor &color)
{
    const double darkness = 1 - (0.299 * color.red() + 0.587 * color.green() + 0.114 * color.blue()) / 255;
    return (darkness > 0.5);
}

/**
 * @brief averageColour
 * @param img
 * @return
 */
static inline QColor averageColour(QImage img)
{
    int r = 0;
    int g = 0;
    int b = 0;
    int c = 0;

    for (int i = 0; i < img.width(); i++) {
        for (int ii = 0; ii < img.height(); ii++) {
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

    QColor color = QColor::fromRgb(r, g, b);

    color.setHsv(color.hue(), color.saturation() / 4, color.value());

    return color;
}

}

#endif // UTILS_H
