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

#ifndef HANDY_H
#define HANDY_H

#include <QObject>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#include <QVariantMap>

/*!
 * \brief The Handy class contains useful static methods to be used as an attached property to the Maui application
 */
#ifdef STATIC_MAUIKIT
class Handy : public QObject
#else
class MAUIKIT_EXPORT Handy : public QObject
#endif
{
    Q_OBJECT
    Q_PROPERTY(bool isTouch MEMBER m_isTouch CONSTANT FINAL)
    Q_PROPERTY(bool isAndroid READ isAndroid CONSTANT FINAL)
    Q_PROPERTY(bool isLinux READ isLinux CONSTANT FINAL)
    Q_PROPERTY(bool isWindows READ isWindows CONSTANT FINAL)
    Q_PROPERTY(bool isMac READ isMac CONSTANT FINAL)
    Q_PROPERTY(bool isIOS READ isIOS CONSTANT FINAL)

    Q_PROPERTY(bool singleClick MEMBER m_singleClick NOTIFY singleClickChanged)

public:
    Handy(QObject *parent = nullptr);

private:
    bool m_isTouch = false;
    bool m_singleClick = true;

public slots:

    /*!
     * \brief Returns the major version of the current OS
     *
     * This function is static.
     * \return Major OS version
     */
    static int version();

    /*!
     * \brief Returns a QVariantMap containing basic information about the current app
     *
     * The pairs keys for the information returned are:
     * "name", "version", "org", "domain", "mauikit_version" and "qt_version"
     * \return QVariantMap with app info
     */
    static QVariantMap appInfo();

    /*!
     * \brief Returns a QVariantMap containing basic information about the current user
     *
     * The pairs keys for the information returned are:
     * "name"
     * \return QVariantMap with user info
     */
    static QVariantMap userInfo();

    /*!
     * \brief Returns the text contained in the clipboard
     * \return QString containing clipboard text
     */
    static QString getClipboardText();
    static QVariantMap getClipboard();

    /*!
     * \brief Copies text to the clipboard
     * \param text text to be copied to the clipboard
     * \return
     */
    static bool copyTextToClipboard(const QString &text);
    static bool copyToClipboard(const QVariantMap &value, const bool &cut = false);

    // TODO move to Device.h the defs and implementation of device specifics
    static bool isTouch();
    static bool isAndroid();
    static bool isWindows();
    static bool isMac();
    static bool isLinux();
    static bool isIOS();

signals:
    void singleClickChanged();
};

#endif // HANDY_H
