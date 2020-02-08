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

#include <QObject>
#include <QString>
#include <QAndroidActivityResultReceiver>
#include <QObject>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QStringList>
#include <QString>
#include <QVariantList>

class Q_DECL_EXPORT MAUIAndroid : public QObject
{
    Q_OBJECT
public:
    MAUIAndroid(QObject *parent = nullptr);
    ~MAUIAndroid();
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);

    static QImage contactPhoto(const QString &id);
    static void addContact(const QString &name, const QString &tel, const QString &tel2, const QString &tel3, const QString &email, const QString &title, const QString &org, const QString &photo, const QString &account, const QString &accountType);
    static void updateContact(const QString &id, const QString &field, const QString &value);

    static void setAppIcons(const QString &lowDPI, const QString &mediumDPI, const QString &highDPI);
    static void setAppInfo(const QString &appName, const QString &version, const QString &uri);
    static void fileChooser();


private:
    static QVariantList transform(const QAndroidJniObject &obj);
    static QVariantMap createVariantMap(jobject data);

public slots:
    static QString getAccounts();
    static QVariantList getCallLogs();
    static QVariantList getContacts();
    static QVariantMap getContact(const QString &id);

    static void statusbarColor(const QString &bg, const bool &light);
    static void navBarColor(const QString &bg, const bool &light);
    
    static void shareDialog(const QUrl &url);
    static void shareText(const QString &text);
    static void sendSMS(const QString &tel,const QString &subject, const QString &message);
    static void shareLink(const QString &link);
    static void shareContact(const QString &id);
    static void openUrl(const QUrl &url);
    static QStringList defaultPaths();
    static QString homePath();
    static QStringList sdDirs();
    static void call(const QString &tel);

    static bool checkRunTimePermissions(const QStringList &permissions);


signals:
    void folderPicked(QString path);
};

namespace PATHS
{
const QString HomePath = MAUIAndroid::homePath();
const QString PicturesPath = HomePath+"/"+QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_PICTURES", "Ljava/lang/String;").toString();
const QString DownloadsPath = HomePath+"/"+QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_DOWNLOADS", "Ljava/lang/String;").toString();
const QString DocumentsPath = HomePath+"/"+QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_DOCUMENTS", "Ljava/lang/String;").toString();
const QString MusicPath = HomePath+"/"+QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_MUSIC", "Ljava/lang/String;").toString();
const QString VideosPath = HomePath+"/"+QAndroidJniObject::getStaticObjectField("android/os/Environment", "DIRECTORY_MOVIES", "Ljava/lang/String;").toString();
}

#endif // ANDROID_H
