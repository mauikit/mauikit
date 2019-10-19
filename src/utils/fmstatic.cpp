#include "fmstatic.h"
#include <QDesktopServices>
#include "utils.h"

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#else
#include "mauikde.h"
#include <KFilePlacesModel>
#include <KIO/CopyJob>
#include <KIO/SimpleJob>
#include <KIO/MkdirJob>
#include <KIO/DeleteJob>
#include <KIO/EmptyTrashJob>
#include <KCoreDirLister>
#include <KFileItem>
#include <KRun>
#include <QIcon>
#endif

#ifdef COMPONENT_TAGGING
#include "tagging.h"
#endif

FMStatic::FMStatic(QObject *parent) : QObject(parent)
{

}

FMH::MODEL_LIST FMStatic::packItems(const QStringList &items, const QString &type)
{
    FMH::MODEL_LIST data;

    for(const auto &path : items)
    {
        if(QUrl(path).isLocalFile() && !FMH::fileExists(path))
            continue;

        auto model = FMH::getFileInfoModel(path);
        model.insert(FMH::MODEL_KEY::TYPE, type);
        data << model;
    }

    return data;
}

FMH::MODEL_LIST FMStatic::getDefaultPaths()
{
    return FMStatic::packItems(FMH::defaultPaths, FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::PLACES_PATH]);
}

FMH::MODEL_LIST FMStatic::search(const QString& query, const QUrl &path, const bool &hidden, const bool &onlyDirs, const QStringList &filters)
{
    FMH::MODEL_LIST content;

    if(!path.isLocalFile())
    {
        qWarning() << "URL recived is not a local file. FM::search" << path;
        return content;
    }

    if (FMStatic::isDir(path))
    {
        QDir::Filters dirFilter;

        dirFilter = (onlyDirs ? QDir::AllDirs | QDir::NoDotDot | QDir::NoDot :
                                QDir::Files | QDir::AllDirs | QDir::NoDotDot | QDir::NoDot);

        if(hidden)
            dirFilter = dirFilter | QDir::Hidden | QDir::System;

        QDirIterator it (path.toLocalFile(), filters, dirFilter, QDirIterator::Subdirectories);
        while (it.hasNext())
        {
            auto url = it.next();
            if(it.fileName().contains(query, Qt::CaseInsensitive))
            {
                content << FMH::getFileInfoModel(QUrl::fromLocalFile(url));
            }
        }
    }else
        qWarning() << "Search path does not exists" << path;

    qDebug()<< content;
    return content;
}

FMH::MODEL_LIST FMStatic::getDevices()
{
    FMH::MODEL_LIST drives;

#if defined(Q_OS_ANDROID)
    drives << packItems(MAUIAndroid::sdDirs(), FMH::PATHTYPE_LABEL[FMH::PATHTYPE_KEY::DRIVES_PATH]);
    return drives;
#endif

    return drives;
}


QVariantMap FMStatic::getDirInfo(const QUrl &path, const QString &type)
{
    return FMH::getDirInfo(path, type);
}

QVariantMap FMStatic::getFileInfo(const QUrl &path)
{
    return FMH::getFileInfo(path);
}

bool FMStatic::isDefaultPath(const QString &path)
{
    return FMH::defaultPaths.contains(path);
}

QUrl FMStatic::parentDir(const QUrl &path)
{
   return FMH::parentDir(path);
}

bool FMStatic::isDir(const QUrl &path)
{
    if(!path.isLocalFile())
    {
        qWarning() << "URL recived is not a local file. FM::isDir" << path;
        return false;
    }

    QFileInfo file(path.toLocalFile());
    return file.isDir();
}

bool FMStatic::isApp(const QString& path)
{
    return /*QFileInfo(path).isExecutable() ||*/ path.endsWith(".desktop");
}

bool FMStatic::isCloud(const QUrl &path)
{
    return path.scheme() == FMH::PATHTYPE_SCHEME[FMH::PATHTYPE_KEY::CLOUD_PATH];
}

bool FMStatic::fileExists(const QUrl &path)
{
    return FMH::fileExists(path);
}

QString FMStatic::fileDir(const QUrl& path) // the directory path of the file
{
    return FMH::fileDir(path);
}

void FMStatic::saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    UTIL::saveSettings(key, value, group);
}

QVariant FMStatic::loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return UTIL::loadSettings(key, group, defaultValue);
}

QString FMStatic::formatSize(const int &size)
{
    QLocale locale;
    return locale.formattedDataSize(size);
}

QString FMStatic::formatDate(const QString &dateStr, const QString &format, const QString &initFormat)
{
    QDateTime date;
    if( initFormat.isEmpty() )
        date = QDateTime::fromString(dateStr, Qt::TextDate);
    else
        date = QDateTime::fromString(dateStr, initFormat);
    return date.toString(format);
}

QString FMStatic::formatTime(const qint64 &value)
{
	QString tStr;
	if (value)
	{
		QTime time((value/3600)%60, (value/60)%60, value%60, (value*1000)%1000);
		QString format = "mm:ss";
		if (value > 3600)
			format = "hh:mm:ss";
			tStr = time.toString(format);
	}
	
	return tStr.isEmpty() ? "00:00" : tStr;
}

QString FMStatic::homePath()
{
    return FMH::HomePath;
}

bool FMStatic::copy(const QUrl &url, const QUrl &destinationDir, const bool &overWriteDirectory)
{
#ifdef Q_OS_ANDROID
    QFileInfo fileInfo(url.toLocalFile());
    if(fileInfo.isFile())
        QFile::copy(url.toLocalFile(), destinationDir.toLocalFile());

    QDir originDirectory(url.toLocalFile());

    if (!originDirectory.exists())
        return false;

    QDir destinationDirectory(destinationDir.toLocalFile());

    if(destinationDirectory.exists() && !overWriteDirectory)
        return false;
    else if(destinationDirectory.exists() && overWriteDirectory)
        destinationDirectory.removeRecursively();

    originDirectory.mkpath(destinationDir.toLocalFile());

    foreach(QString directoryName, originDirectory.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        QString destinationPath = destinationDir.toLocalFile() + "/" + directoryName;
        originDirectory.mkpath(destinationPath);
        copy(url.toLocalFile() + "/" + directoryName, destinationPath, overWriteDirectory);
    }

    foreach (QString fileName, originDirectory.entryList(QDir::Files))
    {
        QFile::copy(url.toLocalFile() + "/" + fileName, destinationDir.toLocalFile() + "/" + fileName);
    }

    /*! Possible race-condition mitigation? */
    QDir finalDestination(destinationDir.toLocalFile());
    finalDestination.refresh();

    if(finalDestination.exists())
        return true;

    return false;
#else
    auto job = KIO::copy(url, destinationDir);
    job->start();
    return true;
#endif
}

bool FMStatic::cut(const QUrl &url, const QUrl &where)
{
	return FMStatic::cut(url, where, QString());
}

bool FMStatic::cut(const QUrl &url, const QUrl &where, const QString &name)
{
	QUrl _where;
	if(name.isEmpty())
		 _where =  QUrl(where.toString()+"/"+FMH::getFileInfoModel(url)[FMH::MODEL_KEY::LABEL]);
	else
		_where =  QUrl(where.toString()+"/"+name);	
	
	#ifdef Q_OS_ANDROID
	QFile file(url.toLocalFile());
	file.rename(_where.toLocalFile());
	#else
	auto job = KIO::move(url, _where);
	job->start();
	#endif
	
	#ifdef COMPONENT_TAGGING
	Tagging::getInstance()->updateUrl(url.toString(), _where.toString());	
	#endif
	
	return true;
}

bool FMStatic::removeFile(const QUrl &path)
{
    if(!path.isLocalFile())
        qWarning() << "URL recived is not a local file, FM::removeFile" << path;

    qDebug()<< "TRYING TO REMOVE FILE: " << path;

#ifdef Q_OS_ANDROID
    if(QFileInfo(path.toLocalFile()).isDir())
        return FMStatic::removeDir(path);
    else return QFile(path.toLocalFile()).remove();
#else
    auto job = KIO::del(path);
    job->start();
    return true;
#endif
}

void FMStatic::moveToTrash(const QUrl &path)
{
    if(!path.isLocalFile())
        qWarning() << "URL recived is not a local file, FM::moveToTrash" << path;

#ifdef Q_OS_ANDROID
#else
    auto job = KIO::trash(path);
    job->start();
#endif
}

void FMStatic::emptyTrash()
{
#ifdef Q_OS_ANDROID
#else
    auto job = KIO::emptyTrash();
    job->start();
#endif
}

bool FMStatic::removeDir(const QUrl &path)
{
    bool result = true;
    QDir dir(path.toLocalFile());
    qDebug()<< "TRYING TO REMOVE DIR" << path << path.toLocalFile();
    if (dir.exists())
    {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst))
        {
            if (info.isDir())
            {
                result = removeDir(QUrl::fromLocalFile(info.absoluteFilePath()));
            }
            else
            {
                result = QFile::remove(info.absoluteFilePath());
            }

            if (!result)
            {
                return result;
            }
        }
        result = dir.rmdir(path.toLocalFile());
    }

    return result;
}

bool FMStatic::rename(const QUrl &url, const QString &name)
{	
	return FMStatic::cut(url, QUrl(url.toString().left(url.toString().lastIndexOf("/"))), name);
}

bool FMStatic::createDir(const QUrl &path, const QString &name)
{
#ifdef Q_OS_ANDROID
    QFileInfo dd(path.toLocalFile());
    return QDir(path.toLocalFile()).mkdir(name);
#else
    const auto _path = QUrl(path.toString() + "/" + name);
    auto job = KIO::mkdir(_path);
    job->start();
    return true;
#endif
}

bool FMStatic::createFile(const QUrl &path, const QString &name)
{
    QFile file(path.toLocalFile() + "/" + name);

    if(file.open(QIODevice::ReadWrite))
    {
        file.close();
        return true;
    }

    return false;
}

bool FMStatic::createSymlink(const QUrl &path, const QUrl &where)
{
#ifdef Q_OS_ANDROID
    return QFile::link(path.toLocalFile(), where.toLocalFile() + "/" + QFileInfo(path.toLocalFile()).fileName());
#else
    const auto job = KIO::link({path}, where);
    job->start();
    return true;
#endif
}

bool FMStatic::openUrl(const QUrl &url)
{
#ifdef Q_OS_ANDROID
    MAUIAndroid::openUrl(url.toString());
    return true;
#else
    //     return QDesktopServices::openUrl(QUrl::fromUserInput(url));
    return KRun::runUrl(url, FMH::getFileInfoModel(url)[FMH::MODEL_KEY::MIME], nullptr, false, KRun::RunFlag::DeleteTemporaryFiles);
#endif
}

void FMStatic::openLocation(const QStringList &urls)
{
    for(const auto &url : urls)
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

QVariantMap FMStatic::dirConf(const QUrl &path)
{
    return FMH::dirConf(path);
}

void FMStatic::setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
{
    FMH::setDirConf(path, group, key, value);
}

bool FMStatic::checkFileType(const int& type, const QString& mimeTypeName)
{
	return FMH::SUPPORTED_MIMETYPES[static_cast<FMH::FILTER_TYPE>(type)].contains(mimeTypeName);
}

