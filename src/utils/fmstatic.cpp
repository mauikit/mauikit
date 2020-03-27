#include "fmstatic.h"
#include <QDesktopServices>
#include "utils.h"

#if defined(Q_OS_ANDROID)
#include "mauiandroid.h"
#elif defined Q_OS_LINUX
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
{}

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


static bool copyRecursively(QString sourceFolder, QString destFolder)
{
    bool success = false;
    QDir sourceDir(sourceFolder);

    if(!sourceDir.exists())
        return false;

    QDir destDir(destFolder);
    if(!destDir.exists())
        destDir.mkdir(destFolder);

    QStringList files = sourceDir.entryList(QDir::Files);
    for(int i = 0; i< files.count(); i++) {
        QString srcName = sourceFolder + QDir::separator() + files[i];
        QString destName = destFolder + QDir::separator() + files[i];
        success = QFile::copy(srcName, destName);
        if(!success)
            return false;
    }

    files.clear();
    files = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + QDir::separator() + files[i];
        QString destName = destFolder + QDir::separator() + files[i];
        success = copyRecursively(srcName, destName);
        if(!success)
            return false;
    }

    return true;
}


bool FMStatic::copy(const QList<QUrl> &urls, const QUrl &destinationDir, const bool &overWriteDirectory)
{
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    for(const auto &url : urls)
    {
        QFileInfo srcFileInfo(url.toLocalFile());
        if (!srcFileInfo.isDir() && srcFileInfo.isFile())
        {
            const auto _destination = QUrl(destinationDir.toString()+"/"+FMH::getFileInfoModel(url)[FMH::MODEL_KEY::LABEL]);
            if (!QFile::copy(url.toLocalFile(), _destination.toLocalFile()))
            {
                continue;
            }
        }else
        {
            const auto _destination = QUrl(destinationDir.toString()+"/"+FMH::getFileInfoModel(url)[FMH::MODEL_KEY::LABEL]);
            QDir destDir(_destination.toLocalFile());
            if(!destDir.exists())
                destDir.mkdir(_destination.toLocalFile());

            if(!copyRecursively(url.toLocalFile(), _destination.toLocalFile()))
                continue;
        }
    }
    return true;
#else
	   auto job = KIO::copy(urls, destinationDir);
	   job->start();
	   return true;
#endif
}

bool FMStatic::cut(const QList<QUrl> &urls, const QUrl &where)
{
    return FMStatic::cut(urls, where, QString());
}

bool FMStatic::cut(const QList<QUrl> &urls, const QUrl &where, const QString &name)
{
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
	for(const auto &url : urls)
	{
        QUrl _where;
		if(name.isEmpty())
			_where =  QUrl(where.toString()+"/"+FMH::getFileInfoModel(url)[FMH::MODEL_KEY::LABEL]);
		else
			_where =  QUrl(where.toString()+"/"+name);
		
		QFile file(url.toLocalFile());
        file.rename(_where.toLocalFile());

#ifdef COMPONENT_TAGGING
        Tagging::getInstance()->updateUrl(url.toString(), _where.toString());
#endif
	}
#else
	QUrl _where = where;
	if(!name.isEmpty())
		_where =  QUrl(where.toString()+"/"+name);
	
	auto job = KIO::move(urls, _where, KIO::HideProgressInfo);
    job->start();

#ifdef COMPONENT_TAGGING
    for(const auto &url : urls)
    {
        QUrl where_ = QUrl(where.toString()+"/"+FMH::getFileInfoModel(url)[FMH::MODEL_KEY::LABEL]);
        if(!name.isEmpty())
            where_ =  QUrl(where.toString()+"/"+name);

        Tagging::getInstance()->updateUrl(url.toString(), where_.toString());
    }
#endif
#endif

    return true;
}

bool FMStatic::removeFiles(const QList<QUrl> &urls)
{
#ifdef COMPONENT_TAGGING
    for(const auto &url : urls)
    {
        Tagging::getInstance()->removeUrl(url.toString());
    }
#endif

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS

    qDebug()<< "ASKED GTO DELETE FILES" << urls;
    for(const auto &url : urls)
    {
        if(QFileInfo(url.toLocalFile()).isDir())
        {
            if(!FMStatic::removeDir(url)) continue;
        }
        else
        {
            if(!QFile(url.toLocalFile()).remove())
                continue;
        }
    }
return true;
#else
    auto job = KIO::del(urls);
    job->start();
    return true;
#endif
}

void FMStatic::moveToTrash(const QList<QUrl> &urls)
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    auto job = KIO::trash(urls);
    job->start();
#endif
}

void FMStatic::emptyTrash()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
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
    return FMStatic::cut({url}, QUrl(url.toString().left(url.toString().lastIndexOf("/"))), name);
}

bool FMStatic::createDir(const QUrl &path, const QString &name)
{
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    QFileInfo dd(path.toLocalFile());
    return QDir(path.toLocalFile()).mkdir(name);
#else
    auto job = KIO::mkdir(name.isEmpty() ? path : QUrl(path.toString() + "/" + name));
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
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    return QFile::link(path.toLocalFile(), where.toLocalFile() + "/" + QFileInfo(path.toLocalFile()).fileName());
#else
	qDebug()<< "trying to create symlink" << path << where;
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
#elif defined Q_OS_LINUX
    //     return QDesktopServices::openUrl(QUrl::fromUserInput(url));
    return KRun::runUrl(url, FMH::getFileInfoModel(url)[FMH::MODEL_KEY::MIME], nullptr, false, KRun::RunFlag::DeleteTemporaryFiles);
#elif defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    return QDesktopServices::openUrl(url);
#endif
}

void FMStatic::openLocation(const QStringList &urls)
{
    for(const auto &url : urls)
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

const QVariantMap FMStatic::dirConf(const QUrl &path)
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

bool FMStatic::toggleFav(const QUrl& url)
{
	if(FMStatic::isFav(url))
		return FMStatic::unFav(url);
	
	return FMStatic::fav(url);
}

bool FMStatic::fav(const QUrl& url)
{
    #ifdef COMPONENT_TAGGING
		return Tagging::getInstance()->tagUrl(url.toString(), "fav", "#e91e63");
    #endif
}

bool FMStatic::unFav(const QUrl& url)
{
	#ifdef COMPONENT_TAGGING	
		return Tagging::getInstance()->removeUrlTag(url.toString(), "fav");	
	#endif
}

bool FMStatic::isFav(const QUrl& url, const bool &strict)
{
    #ifdef COMPONENT_TAGGING
    return Tagging::getInstance()->urlTagExists(url.toString(), "fav", strict);
    #endif
}

static bool doNameFilter(const QString &name, const QStringList &filters)
{
	for(const auto &filter : std::accumulate(filters.constBegin(), filters.constEnd(), QVector<QRegExp> {}, [](QVector<QRegExp> &res, const QString &filter) -> QVector<QRegExp>
	{ res.append(QRegExp(filter, Qt::CaseInsensitive, QRegExp::Wildcard)); return res; }))
	{
		if(filter.exactMatch(name))
		{
			return true;
		}
	}
	return false;
}

QList<QUrl> FMStatic::getTagUrls(const QString& tag, const QStringList& filters, const bool& strict)
{
	QList<QUrl> urls;
	#ifdef COMPONENT_TAGGING
	for(const auto &data : Tagging::getInstance()->getUrls(tag, strict, [filters](QVariantMap &item) -> bool
	{ return filters.isEmpty() ? true : doNameFilter(FMH::mapValue(item, FMH::MODEL_KEY::URL), filters); }))
	{                
		const auto url = QUrl(data.toMap()[TAG::KEYMAP[TAG::KEYS::URL]].toString());
		if(url.isLocalFile() && !FMH::fileExists(url))
			continue;		
		urls << url;
	}	
	#endif
	return urls;
}

void FMStatic::bookmark(const QUrl& url)
{
    #if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
	//do android stuff until cmake works with android	
    auto bookmarks = UTIL::loadSettings("BOOKMARKS", "PREFERENCES", {},true).toStringList();
    bookmarks << url.toString();
    UTIL::saveSettings("BOOKMARKS", bookmarks, "PREFERENCES", true);
	#else
	KFilePlacesModel model;
	model.addPlace(QDir(url.toLocalFile()).dirName(), url, FMH::getIconName(url));
	#endif
}
