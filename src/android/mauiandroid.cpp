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

#include "mauiandroid.h"
#include <QException>
#include <QColor>
#include <QDebug>
#include <QMimeData>
#include <QMimeDatabase>
#include <QDomDocument>
#include <QFile>

#include "utils.h"

class InterfaceConnFailedException : public QException
{
public:
    void raise() const { throw *this; }
    InterfaceConnFailedException *clone() const { return new InterfaceConnFailedException(*this); }
};

MAUIAndroid::MAUIAndroid(QObject *parent) : QObject(parent)
{

}

MAUIAndroid::~MAUIAndroid()
{
    
}

void MAUIAndroid::statusbarColor(const QString &bg, const bool &light)
{
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
        window.callMethod<void>("addFlags", "(I)V", 0x80000000);
        window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
        window.callMethod<void>("setStatusBarColor", "(I)V", QColor(bg).rgba());
        
        QAndroidJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        decorView.callMethod<void>("setSystemUiVisibility", "(I)V", light ? 0x00002000 :  0x00000001);
    });
}

void MAUIAndroid::shareDialog(const QString &url)
{
    qDebug()<< "trying to share dialog";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");   //activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid())
    {
        QMimeDatabase mimedb;
        QString mimeType = mimedb.mimeTypeForFile(url).name();
        
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "share",
                                                  "(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(url).object<jstring>(),
                                                  QAndroidJniObject::fromString(mimeType).object<jstring>());
        
        
        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    }else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::shareText(const QString &text)
{
    qDebug()<< "trying to share text";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");   //activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if ( activity.isValid() )
    {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "sendText",
                                                  "(Landroid/app/Activity;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(text).object<jstring>());
        
        
        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    }else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::shareLink(const QString &link)
{
    qDebug()<< "trying to share link";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");   //activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if ( activity.isValid() )
    {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "sendUrl",
                                                  "(Landroid/app/Activity;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(link).object<jstring>());
        
        
        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    }else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::openWithApp(const QString &url)
{
    
}

QString MAUIAndroid::homePath()
{
    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    
    return mediaPath.toString();
}

QString MAUIAndroid::sdDir()
{
    //    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    //    QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    //    QString dataAbsPath = mediaPath.toString()+"/Download/";
    //    QAndroidJniEnvironment env;
    //    if (env->ExceptionCheck()) {
    //            // Handle exception here.
    //            env->ExceptionClear();
    //    }
    
    //    qbDebug::Instance()->msg()<<"TESTED SDPATH"<<QProcessEnvironment::systemEnvironment().value("EXTERNAL_SDCARD_STORAGE",dataAbsPath);
    if(UTIL::fileExists("/mnt/extSdCard"))
        return "/mnt/extSdCard";
    else if(UTIL::fileExists("/mnt/ext_sdcard"))
        return "/mnt/ext_sdcard";
    else
        return "/mnt/";
}

void MAUIAndroid::setAppIcons(const QString &lowDPI, const QString &mediumDPI, const QString &highDPI)
{
    
    
}

void MAUIAndroid::setAppInfo(const QString &appName, const QString &version, const QString &uri)
{
    
    QDomDocument doc("mydocument");
    QFile file(":/assets/AndroidManifest.xml");
    
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug("Cannot open the file");
        return;
    }
    
    // Parse file
    if (!doc.setContent(&file)) {
        qDebug("Cannot parse the content");
        file.close();
        return;
    }
    file.close();
    
    // Modify content
    QDomNodeList manifest = doc.elementsByTagName("manifest");
    if (manifest.size() < 1)
    {
        qDebug("Cannot find manifest");
        return;
    }
    
    //Manifest//
    QDomElement root = manifest.at(0).toElement();
    root.setAttribute("package", uri);
    root.setAttribute("android:versionName", version);
    
    //Application//
    auto applicationNode = root.toElement().elementsByTagName("application");
    if (applicationNode.size() < 1)
    {
        qDebug("Cannot find application node in manifest");
        return;
    }
    
    auto application = applicationNode.at(0).toElement();
    application.setAttribute("android:label", appName);
    
    // Activity //
    auto activityNode = application.toElement().elementsByTagName("activity");
    if (activityNode.size() < 1)
    {
        qDebug("Cannot find activity node in manifest");
        return;
    }
    
    auto activity = activityNode.at(0).toElement();
    activity.setAttribute("android:label", appName);
    
    // Service //
    auto serviceNode = application.toElement().elementsByTagName("service");
    if (serviceNode.size() < 1)
    {
        qDebug("Cannot find service node in manifest");
        return;
    }
    
    auto service = activityNode.at(0).toElement();
    auto serviceMetadataNode = service.elementsByTagName("meta-data");
    if (serviceMetadataNode.size() < 1)
    {
        qDebug("Cannot find service metadata node in manifest");
        return;
    }
    
    auto serviceMetadata = serviceMetadataNode.at(1).toElement();
    serviceMetadata.setAttribute("android:value", appName);
    
    if(!file.open(QIODevice::Truncate | QIODevice::WriteOnly))
    {
        qDebug("Basically, now we lost content of a file");
        return;
    }
    
    QByteArray xml = doc.toByteArray();
    file.write(xml);
    file.close();
}


void MAUIAndroid::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    qDebug()<< "ACTIVITY RESULTS";
    jint RESULT_OK = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");
    if (receiverRequestCode == 42 && resultCode == RESULT_OK)
    {
        QString url = data.callObjectMethod("getData", "()Landroid/net/Uri;").callObjectMethod("getPath", "()Ljava/lang/String;").toString();
        emit folderPicked(url);
    }
}

void MAUIAndroid::fileChooser()
{
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");   //activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if ( activity.isValid() )
    {
        QAndroidJniObject::callStaticMethod<void>("com/example/android/tools/SendIntent",
                                                  "fileChooser",
                                                  "(Landroid/app/Activity;)V",
                                                  activity.object<jobject>());
        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    }else
        throw InterfaceConnFailedException();
}

QStringList MAUIAndroid::defaultPaths()
{
    QStringList paths;
    
    paths.append(PATHS::HomePath);
    paths.append(PATHS::DocumentsPath);
    paths.append(PATHS::MusicPath);
    paths.append(PATHS::VideosPath);
    paths.append(PATHS::PicturesPath);
    paths.append(PATHS::DownloadsPath);
    
    return paths;
}


