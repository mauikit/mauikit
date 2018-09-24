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

class MAUIAndroid : public QObject
{
    Q_OBJECT
public:
    MAUIAndroid(QObject *parent = nullptr);
    ~MAUIAndroid();

    Q_INVOKABLE void statusbarColor(const QString &bg, const bool &light);
    Q_INVOKABLE void shareDialog(const QString &url);
    Q_INVOKABLE void shareText(const QString &text);
    Q_INVOKABLE void shareLink(const QString &link);
    Q_INVOKABLE void openWithApp(const QString &url);
    Q_INVOKABLE static QStringList defaultPaths();
    Q_INVOKABLE static QString homePath();
    Q_INVOKABLE static QString sdDir();
    void setAppIcons(const QString &lowDPI, const QString &mediumDPI, const QString &highDPI);
    void setAppInfo(const QString &appName, const QString &version, const QString &uri);
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);
    void fileChooser();
public slots:

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
