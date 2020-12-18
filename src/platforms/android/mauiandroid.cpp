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
#include <QColor>
#include <QDebug>
#include <QException>
#include <QFile>
#include <QImage>
#include <QMimeData>
#include <QMimeDatabase>
#include <QUrl>
#include <QFileInfo>
#include <QCoreApplication>
#include <QProcess>

#include <android/bitmap.h>
// WindowManager.LayoutParams
#define FLAG_TRANSLUCENT_STATUS 0x04000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS 0x80000000
// View
#define SYSTEM_UI_FLAG_LIGHT_STATUS_BAR 0x00002000
#define SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR 0x00000010

class InterfaceConnFailedException : public QException
{
public:
    void raise() const
    {
        throw *this;
    }
    InterfaceConnFailedException *clone() const
    {
        return new InterfaceConnFailedException(*this);
    }
};

MAUIAndroid::MAUIAndroid(QObject *parent)
    : AbstractPlatform(parent)
{
}

QString MAUIAndroid::getAccounts()
{
    QAndroidJniObject str = QAndroidJniObject::callStaticObjectMethod("com/kde/maui/tools/Union", "getAccounts", "(Landroid/content/Context;)Ljava/lang/String;", QtAndroid::androidActivity().object<jobject>());

    return str.toString();
}

static QAndroidJniObject getAndroidWindow()
{
    QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
    window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
    return window;
}

void MAUIAndroid::statusbarColor(const QString &bg, const bool &light)
{
    if (QtAndroid::androidSdkVersion() <= 23)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
        if (light)
            visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        else
            visibility &= ~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        window.callMethod<void>("setStatusBarColor", "(I)V", QColor(bg).rgba());
    });
}

void MAUIAndroid::navBarColor(const QString &bg, const bool &light)
{
    if (QtAndroid::androidSdkVersion() <= 23)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
        if (light)
            visibility |= SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        else
            visibility &= ~SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
        window.callMethod<void>("setNavigationBarColor", "(I)V", QColor(bg).rgba());
    });
}

void MAUIAndroid::shareFiles(const QList<QUrl> &urls)
{
    shareDialog(urls.first());
}

void MAUIAndroid::shareDialog(const QUrl &url)
{
    qDebug() << "trying to share dialog";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        qDebug() << "trying to share dialog << valid";

        QMimeDatabase mimedb;
        QString mimeType = mimedb.mimeTypeForFile(url.toLocalFile()).name();

        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "share",
                                                  "(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(url.toLocalFile()).object<jstring>(),
                                                  QAndroidJniObject::fromString(mimeType).object<jstring>(),
                                                  QAndroidJniObject::fromString(QString("%1.fileprovider").arg(qApp->organizationDomain())).object<jstring>());

        if (_env->ExceptionCheck()) {
            qDebug() << "trying to share dialog << exception";

            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::shareText(const QString &text)
{
    qDebug() << "trying to share text";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent", "sendText", "(Landroid/app/Activity;Ljava/lang/String;)V", activity.object<jobject>(), QAndroidJniObject::fromString(text).object<jstring>());

        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::shareLink(const QString &link)
{
    qDebug() << "trying to share link";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent", "sendUrl", "(Landroid/app/Activity;Ljava/lang/String;)V", activity.object<jobject>(), QAndroidJniObject::fromString(link).object<jstring>());

        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::shareContact(const QString &id)
{
    QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/Union",
                                              "shareContact",
                                              "(Landroid/content/Context;"
                                              "Ljava/lang/String;)V",
                                              QtAndroid::androidActivity().object<jobject>(),
                                              QAndroidJniObject::fromString(id).object<jstring>());
}

void MAUIAndroid::sendSMS(const QString &tel, const QString &subject, const QString &message)
{
    qDebug() << "trying to send sms text";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "sendSMS",
                                                  "(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(tel).object<jstring>(),
                                                  QAndroidJniObject::fromString(subject).object<jstring>(),
                                                  QAndroidJniObject::fromString(message).object<jstring>());

        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

void MAUIAndroid::openUrl(const QUrl &url)
{
    qDebug() << "trying to open file with";
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
                                                  "openUrl",
                                                  "(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V",
                                                  activity.object<jobject>(),
                                                  QAndroidJniObject::fromString(url.toLocalFile()).object<jstring>(),
                                                  QAndroidJniObject::fromString(QString("%1.fileprovider").arg(qApp->organizationDomain())).object<jstring>());

        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

QString MAUIAndroid::homePath()
{
    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
    QAndroidJniObject mediaPath = mediaDir.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");

    return mediaPath.toString();
}

QStringList MAUIAndroid::sdDirs()
{    
    QStringList res;

    QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("com/kde/maui/tools/SDCard", "findSdCardPath", "(Landroid/content/Context;)Ljava/io/File;", QtAndroid::androidActivity().object<jobject>());

    if(mediaDir == NULL)
        return res;

    QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
    QString dataAbsPath = mediaPath.toString();

    res << QUrl::fromLocalFile(dataAbsPath).toString();
    return res;
}

//void MAUIAndroid::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
//{
//    qDebug() << "ACTIVITY RESULTS";
//    jint RESULT_OK = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");

//    if (receiverRequestCode == 42 && resultCode == RESULT_OK) {
//        QString url = data.callObjectMethod("getData", "()Landroid/net/Uri;").callObjectMethod("getPath", "()Ljava/lang/String;").toString();
//        emit folderPicked(url);
//    }
//}

void MAUIAndroid::fileChooser()
{
    QAndroidJniEnvironment _env;
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid
    if (_env->ExceptionCheck()) {
        _env->ExceptionClear();
        throw InterfaceConnFailedException();
    }
    if (activity.isValid()) {
        QAndroidJniObject::callStaticMethod<void>("com/example/android/tools/SendIntent", "fileChooser", "(Landroid/app/Activity;)V", activity.object<jobject>());
        if (_env->ExceptionCheck()) {
            _env->ExceptionClear();
            throw InterfaceConnFailedException();
        }
    } else
        throw InterfaceConnFailedException();
}

QVariantList MAUIAndroid::transform(const QAndroidJniObject &obj)
{
    QVariantList res;
    const auto size = obj.callMethod<jint>("size", "()I");

    for (auto i = 0; i < size; i++) {
        QAndroidJniObject hashObj = obj.callObjectMethod("get", "(I)Ljava/lang/Object;", i);
        res << createVariantMap(hashObj.object<jobject>());
    }

    return res;
}

QVariantMap MAUIAndroid::createVariantMap(jobject data)
{
    QVariantMap res;

    QAndroidJniEnvironment env;
    /* Reference : https://community.oracle.com/thread/1549999 */

    // Get the HashMap Class
    jclass jclass_of_hashmap = (env)->GetObjectClass(data);

    // Get link to Method "entrySet"
    jmethodID entrySetMethod = (env)->GetMethodID(jclass_of_hashmap, "entrySet", "()Ljava/util/Set;");

    // Invoke the "entrySet" method on the HashMap object
    jobject jobject_of_entryset = env->CallObjectMethod(data, entrySetMethod);

    // Get the Set Class
    jclass jclass_of_set = (env)->FindClass("java/util/Set"); // Problem during compilation !!!!!

    if (jclass_of_set == 0) {
        qWarning() << "java/util/Set lookup failed\n";
        return res;
    }

    // Get link to Method "iterator"
    jmethodID iteratorMethod = env->GetMethodID(jclass_of_set, "iterator", "()Ljava/util/Iterator;");

    // Invoke the "iterator" method on the jobject_of_entryset variable of type Set
    jobject jobject_of_iterator = env->CallObjectMethod(jobject_of_entryset, iteratorMethod);

    // Get the "Iterator" class
    jclass jclass_of_iterator = (env)->FindClass("java/util/Iterator");

    // Get link to Method "hasNext"
    jmethodID hasNextMethod = env->GetMethodID(jclass_of_iterator, "hasNext", "()Z");

    jmethodID nextMethod = env->GetMethodID(jclass_of_iterator, "next", "()Ljava/lang/Object;");

    while (env->CallBooleanMethod(jobject_of_iterator, hasNextMethod)) {
        jobject jEntry = env->CallObjectMethod(jobject_of_iterator, nextMethod);
        QAndroidJniObject entry = QAndroidJniObject(jEntry);
        QAndroidJniObject key = entry.callObjectMethod("getKey", "()Ljava/lang/Object;");
        QAndroidJniObject value = entry.callObjectMethod("getValue", "()Ljava/lang/Object;");
        QString k = key.toString();

        QVariant v = value.toString();

        env->DeleteLocalRef(jEntry);

        if (v.isNull()) {
            continue;
        }

        res[k] = v;
    }

    if (env->ExceptionOccurred()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
    }

    env->DeleteLocalRef(jclass_of_hashmap);
    env->DeleteLocalRef(jobject_of_entryset);
    env->DeleteLocalRef(jclass_of_set);
    env->DeleteLocalRef(jobject_of_iterator);
    env->DeleteLocalRef(jclass_of_iterator);

    return res;
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

bool MAUIAndroid::checkRunTimePermissions(const QStringList &permissions)
{
    qDebug() << "CHECKIGN PERMISSSIONS";

    //    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    //    if(r == QtAndroid::PermissionResult::Denied) {
    //        QtAndroid::requestPermissionsSync( QStringList() << "android.permission.WRITE_EXTERNAL_STORAGE" );
    //        r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    //        if(r == QtAndroid::PermissionResult::Denied) {
    //            qDebug() << "Permission denied";
    //            return false;
    //        }
    //    }

    //    qDebug() << "Permissions granted!";
    //    return true;

    //    QAndroidJniObject::callStaticMethod<void>("com/kde/maui/tools/SendIntent",
    //                                              "requestPermission",
    //                                              "(Landroid/app/Activity;)V",
    //                                              QtAndroid::androidActivity().object<jobject>());
    for (const auto &permission : permissions) {
        QtAndroid::PermissionResult r = QtAndroid::checkPermission(permission);
        if (r == QtAndroid::PermissionResult::Denied) {
            QtAndroid::requestPermissionsSync({permission});
            r = QtAndroid::checkPermission(permission);
            if (r == QtAndroid::PermissionResult::Denied) {
                qWarning() << "Permission denied";
                return false;
            }
        }
    }

    qDebug() << "Permissions granted!";
    return true;
}

bool MAUIAndroid::hasKeyboard()
{

    QAndroidJniObject context =QtAndroid::androidContext().object<jobject>();

    if (context.isValid()) {

        QAndroidJniObject resources = context.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
        QAndroidJniObject config = resources.callObjectMethod("getConfiguration", "()Landroid/content/res/Configuration;");
        int value = config.getField<jint>("keyboard");
        //        QVariant v = value.toString();
        qDebug() << "KEYBOARD" << value;

        return value == 2 || value == 3; // KEYBOARD_12KEY || KEYBOARD_QWERTY

    } else
        throw InterfaceConnFailedException();
}

bool MAUIAndroid::hasMouse()
{
    return false;
}

void MAUIAndroid::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    qDebug() << "ACTIVITY RESULTS" << receiverRequestCode;
    emit this->hasKeyboardChanged();
    jint RESULT_OK = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");

    if (receiverRequestCode == 42 && resultCode == RESULT_OK) {
        QString url = data.callObjectMethod("getData", "()Landroid/net/Uri;").callObjectMethod("getPath", "()Ljava/lang/String;").toString();
        emit folderPicked(url);
    }
}

