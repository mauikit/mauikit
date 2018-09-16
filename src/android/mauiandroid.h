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
    void setIcons(const QString &lowDPI, const QString &mediumDPI, const QString &highDPI);
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
