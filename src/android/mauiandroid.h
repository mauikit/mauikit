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

#ifndef MAUIANDROID_H
#define MAUIANDROID_H

#include <QAndroidActivityResultReceiver>
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QtAndroid>

/**
 * @brief The MAUIAndroid class
 */
class Q_DECL_EXPORT MAUIAndroid : public QObject
{
    Q_OBJECT
public:
    MAUIAndroid(QObject *parent = nullptr);
    ~MAUIAndroid();

    /**
     * @brief handleActivityResult
     * @param receiverRequestCode
     * @param resultCode
     * @param data
     */
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);

    /**
     * @brief contactPhoto
     * @param id
     * @return
     */
    static QImage contactPhoto(const QString &id);

    /**
     * @brief addContact
     * @param name
     * @param tel
     * @param tel2
     * @param tel3
     * @param email
     * @param title
     * @param org
     * @param photo
     * @param account
     * @param accountType
     */
    static void addContact(const QString &name, const QString &tel, const QString &tel2, const QString &tel3, const QString &email, const QString &title, const QString &org, const QString &photo, const QString &account, const QString &accountType);

    /**
     * @brief updateContact
     * @param id
     * @param field
     * @param value
     */
    static void updateContact(const QString &id, const QString &field, const QString &value);

    /**
     * @brief setAppIcons
     * @param lowDPI
     * @param mediumDPI
     * @param highDPI
     */
    static void setAppIcons(const QString &lowDPI, const QString &mediumDPI, const QString &highDPI);

    /**
     * @brief setAppInfo
     * @param appName
     * @param version
     * @param uri
     */
    static void setAppInfo(const QString &appName, const QString &version, const QString &uri);

    /**
     * @brief fileChooser
     */
    static void fileChooser();

private:
    static QVariantList transform(const QAndroidJniObject &obj);
    static QVariantMap createVariantMap(jobject data);

public slots:
    /**
     * @brief getAccounts
     * @return
     */
    static QString getAccounts();

    /**
     * @brief getCallLogs
     * @return
     */
    static QVariantList getCallLogs();

    /**
     * @brief getContacts
     * @return
     */
    static QVariantList getContacts();

    /**
     * @brief getContact
     * @param id
     * @return
     */
    static QVariantMap getContact(const QString &id);

    /**
     * @brief statusbarColor
     * @param bg
     * @param light
     */
    static void statusbarColor(const QString &bg, const bool &light);

    /**
     * @brief navBarColor
     * @param bg
     * @param light
     */
    static void navBarColor(const QString &bg, const bool &light);

    /**
     * @brief shareDialog
     * @param url
     */
    static void shareDialog(const QUrl &url);

    /**
     * @brief shareText
     * @param text
     */
    static void shareText(const QString &text);

    /**
     * @brief sendSMS
     * @param tel
     * @param subject
     * @param message
     */
    static void sendSMS(const QString &tel, const QString &subject, const QString &message);

    /**
     * @brief shareLink
     * @param link
     */
    static void shareLink(const QString &link);

    /**
     * @brief shareContact
     * @param id
     */
    static void shareContact(const QString &id);

    /**
     * @brief openUrl
     * @param url
     */
    static void openUrl(const QUrl &url);

    /**
     * @brief defaultPaths
     * @return
     */
    static QStringList defaultPaths();

    /**
     * @brief homePath
     * @return
     */
    static QString homePath();

    /**
     * @brief sdDirs
     * @return
     */
    static QStringList sdDirs();

    /**
     * @brief call
     * @param tel
     */
    static void call(const QString &tel);

    /**
     * @brief checkRunTimePermissions
     * @param permissions
     * @return
     */
    static bool checkRunTimePermissions(const QStringList &permissions);

signals:
    /**
     * @brief folderPicked
     * @param path
     */
    void folderPicked(QString path);
};


namespace PATHS
{
const QString HomePath = MAUIAndroid::homePath();
const QString PicturesPath = HomePath + "/" + QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_PICTURES", "Ljava/lang/String;").toString();
const QString DownloadsPath = HomePath + "/" + QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_DOWNLOADS", "Ljava/lang/String;").toString();
const QString DocumentsPath = HomePath + "/" + QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_DOCUMENTS", "Ljava/lang/String;").toString();
const QString MusicPath = HomePath + "/" + QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_MUSIC", "Ljava/lang/String;").toString();
const QString VideosPath = HomePath + "/" + QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_MOVIES", "Ljava/lang/String;").toString();
}

#endif // ANDROID_H
