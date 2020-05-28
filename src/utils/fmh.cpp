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

#include "fmh.h"

// #ifdef COMPONENT_TAGGING
// #include "tagging.h"
// #endif

namespace FMH
{
bool isAndroid()
{
#if defined(Q_OS_ANDROID)
    return true;
#else
    return false;
#endif
}

bool isWindows()
{
#if defined(Q_OS_WIN32)
    return true;
#elif defined(Q_OS_WIN64)
    return true;
#else
    return false;
#endif
}

bool isLinux()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    return true;
#else
    return false;
#endif
}

bool isMac()
{
#if defined(Q_OS_MACOS)
    return true;
#elif defined(Q_OS_MAC)
    return true;
#else
    return false;
#endif
}

bool isIOS()
{
#if defined(Q_OS_iOS)
    return true;
#else
    return false;
#endif
}

const QVector<int> modelRoles(const FMH::MODEL &model)
{
    const auto keys = model.keys();
    return std::accumulate(keys.begin(), keys.end(), QVector<int>(), [](QVector<int> &res, const FMH::MODEL_KEY &key) {
        res.append(key);
        return res;
    });
}

const QString mapValue(const QVariantMap &map, const FMH::MODEL_KEY &key)
{
    return map[FMH::MODEL_NAME[key]].toString();
}

const QVariantMap toMap(const FMH::MODEL &model)
{
    QVariantMap map;
    for (const auto &key : model.keys())
        map.insert(FMH::MODEL_NAME[key], model[key]);

    return map;
}

const FMH::MODEL toModel(const QVariantMap &map)
{
    FMH::MODEL model;
    for (const auto &key : map.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], map[key].toString());

    return model;
}

const FMH::MODEL_LIST toModelList(const QVariantList &list)
{
    FMH::MODEL_LIST res;

    for (const auto &data : list)
        res << FMH::toModel(data.toMap());

    return res;
}

const QVariantList toMapList(const FMH::MODEL_LIST &list)
{
    QVariantList res;

    for (const auto &data : list)
        res << FMH::toMap(data);

    return res;
}

const FMH::MODEL filterModel(const FMH::MODEL &model, const QVector<FMH::MODEL_KEY> &keys)
{
    FMH::MODEL res;
    for (const auto &key : keys) {
        if (model.contains(key))
            res[key] = model[key];
    }

    return res;
}

const QStringList modelToList(const FMH::MODEL &model, const FMH::MODEL_KEY &key)
{
    QStringList res;
    for (const auto &item : model) {
        if (item.contains(key))
            res << item[key];
    }

    return res;
}

/**
 * Checks if a local file exists.
 * The URL must represent a local file path, by using the scheme file://
 **/
bool fileExists(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return false;
    }
    return QFileInfo::exists(path.toLocalFile());
}

const QString fileDir(const QUrl &path) // the directory path of the file
{
    QString res = path.toString();
    if (path.isLocalFile()) {
        const QFileInfo file(path.toLocalFile());
        if (file.isDir())
            res = path.toString();
        else
            res = QUrl::fromLocalFile(file.dir().absolutePath()).toString();
    } else
        qWarning() << "The path is not a local one. FM::fileDir";

    return res;
}

const QUrl parentDir(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file, FM::parentDir" << path;
        return path;
    }

    QDir dir(path.toLocalFile());
    dir.cdUp();
    return QUrl::fromLocalFile(dir.absolutePath());
}

/**
 * Return the configuration of a single directory represented
 * by a QVariantMap.
 * The passed path must be a local file URL.
 **/
QVariantMap dirConf(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return QVariantMap();
    }

    if (!FMH::fileExists(path))
        return QVariantMap();

    QString icon, iconsize, hidden, detailview, showthumbnail, showterminal;

    uint count = 0, sortby = FMH::MODEL_KEY::MODIFIED, viewType = 0;

    bool foldersFirst = false;

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    QSettings file(path.toLocalFile(), QSettings::Format::NativeFormat);
    file.beginGroup(QString("Desktop Entry"));
    icon = file.value("Icon").toString();
    file.endGroup();

    file.beginGroup(QString("Settings"));
    hidden = file.value("HiddenFilesShown").toString();
    file.endGroup();

    file.beginGroup(QString("MAUIFM"));
    iconsize = file.value("IconSize").toString();
    detailview = file.value("DetailView").toString();
    showthumbnail = file.value("ShowThumbnail").toString();
    showterminal = file.value("ShowTerminal").toString();
    count = file.value("Count").toInt();
    sortby = file.value("SortBy").toInt();
    foldersFirst = file.value("FoldersFirst").toBool();
    viewType = file.value("ViewType").toInt();
    file.endGroup();

#else
    KConfig file(path.toLocalFile());
    icon = file.entryMap(QString("Desktop Entry"))["Icon"];
    hidden = file.entryMap(QString("Settings"))["HiddenFilesShown"];
    iconsize = file.entryMap(QString("MAUIFM"))["IconSize"];
    detailview = file.entryMap(QString("MAUIFM"))["DetailView"];
    showthumbnail = file.entryMap(QString("MAUIFM"))["ShowThumbnail"];
    showterminal = file.entryMap(QString("MAUIFM"))["ShowTerminal"];
    count = file.entryMap(QString("MAUIFM"))["Count"].toInt();
    sortby = file.entryMap(QString("MAUIFM"))["SortBy"].toInt();
    foldersFirst = file.entryMap(QString("MAUIFM"))["FoldersFirst"] == "true" ? true : false;
    viewType = file.entryMap(QString("MAUIFM"))["ViewType"].toInt();
#endif

    return QVariantMap({{FMH::MODEL_NAME[FMH::MODEL_KEY::ICON], icon.isEmpty() ? "folder" : icon},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::ICONSIZE], iconsize},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT], count},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTERMINAL], showterminal.isEmpty() ? "false" : showterminal},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SHOWTHUMBNAIL], showthumbnail.isEmpty() ? "false" : showthumbnail},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::DETAILVIEW], detailview.isEmpty() ? "false" : detailview},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::HIDDEN], hidden.isEmpty() ? false : (hidden == "true" ? true : false)},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SORTBY], sortby},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FOLDERSFIRST], foldersFirst},
                        {FMH::MODEL_NAME[FMH::MODEL_KEY::VIEWTYPE], viewType}});
}

void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file" << path;
        return;
    }

#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    QSettings file(path.toLocalFile(), QSettings::Format::IniFormat);
    file.beginGroup(group);
    file.setValue(key, value);
    file.endGroup();
    file.sync();
#else
    KConfig file(path.toLocalFile(), KConfig::SimpleConfig);
    auto kgroup = file.group(group);
    kgroup.writeEntry(key, value);
    // 		file.reparseConfiguration();
    file.sync();
#endif
}

/**
 * Returns the icon name for certain file.
 * The file path must be represented as a local file URL.
 * It also looks into the directory config file to get custom set icons
 **/
QString getIconName(const QUrl &path)
{
    if (!path.isLocalFile())
        qWarning() << "URL recived is not a local file. FMH::getIconName" << path;

    if (path.isLocalFile() && QFileInfo(path.toLocalFile()).isDir()) {
        if (folderIcon.contains(path.toString()))
            return folderIcon[path.toString()];
        else {
            const auto icon = FMH::dirConf(QString(path.toString() + "/%1").arg(".directory"))[FMH::MODEL_NAME[FMH::MODEL_KEY::ICON]].toString();
            return icon.isEmpty() ? "folder" : icon;
        }

    } else {
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
        QMimeDatabase mime;
        const auto type = mime.mimeTypeForFile(path.toString());
        return type.iconName();
#else
        KFileItem mime(path);
        return mime.iconName();
#endif
    }
}

QString getMime(const QUrl &path)
{
    if (!path.isLocalFile()) {
        qWarning() << "URL recived is not a local file, FMH::getMime" << path;
        return QString();
    }

    const QMimeDatabase mimedb;
    return mimedb.mimeTypeForFile(path.toLocalFile()).name();
}

bool mimeInherits(const QString baseType, const QString &type)
{
    const QMimeDatabase _m;
    return _m.mimeTypeForName(baseType).inherits(type);
}

FMH::MODEL getFileInfoModel(const QUrl &path)
{
    FMH::MODEL res;
#if defined Q_OS_ANDROID || defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_IOS
    const QFileInfo file(path.toLocalFile());
    if (!file.exists())
        return FMH::MODEL();

    const auto mime = FMH::getMime(path);
    res = FMH::MODEL {{FMH::MODEL_KEY::GROUP, file.group()},
                      {FMH::MODEL_KEY::OWNER, file.owner()},
                      {FMH::MODEL_KEY::SUFFIX, file.completeSuffix()},
                      {FMH::MODEL_KEY::LABEL, /*file.isDir() ? file.baseName() :*/ path == FMH::HomePath ? QStringLiteral("Home") : file.fileName()},
                      {FMH::MODEL_KEY::NAME, file.baseName()},
                      {FMH::MODEL_KEY::DATE, file.birthTime().toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::MODIFIED, file.lastModified().toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::LAST_READ, file.lastRead().toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::MIME, mime},
                      {FMH::MODEL_KEY::SYMLINK, file.symLinkTarget()},
                      {FMH::MODEL_KEY::SYMLINK, file.symLinkTarget()},
                      {FMH::MODEL_KEY::IS_SYMLINK, QVariant(file.isSymLink()).toString()},
                      {FMH::MODEL_KEY::IS_FILE, QVariant(file.isFile()).toString()},
                      {FMH::MODEL_KEY::HIDDEN, QVariant(file.isHidden()).toString()},
                      {FMH::MODEL_KEY::IS_DIR, QVariant(file.isDir()).toString()},
                      {FMH::MODEL_KEY::WRITABLE, QVariant(file.isWritable()).toString()},
                      {FMH::MODEL_KEY::READABLE, QVariant(file.isReadable()).toString()},
                      {FMH::MODEL_KEY::EXECUTABLE, QVariant(file.suffix().endsWith(".desktop")).toString()},
                      {FMH::MODEL_KEY::ICON, FMH::getIconName(path)},
                      {FMH::MODEL_KEY::SIZE, QString::number(file.size()) /*locale.formattedDataSize(file.size())*/},
                      {FMH::MODEL_KEY::PATH, path.toString()},
                      {FMH::MODEL_KEY::THUMBNAIL, path.toString()},
                      {FMH::MODEL_KEY::COUNT, file.isDir() ? QString::number(QDir(path.toLocalFile()).count() - 2) : "0"}};
#else
    KFileItem kfile(path, KFileItem::MimeTypeDetermination::NormalMimeTypeDetermination);

    res = FMH::MODEL {{FMH::MODEL_KEY::LABEL, kfile.name()},
                      {FMH::MODEL_KEY::NAME, kfile.name().remove(kfile.name().lastIndexOf("."), kfile.name().size())},
                      {FMH::MODEL_KEY::DATE, kfile.time(KFileItem::FileTimes::CreationTime).toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::MODIFIED, kfile.time(KFileItem::FileTimes::ModificationTime).toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::LAST_READ, kfile.time(KFileItem::FileTimes::AccessTime).toString(Qt::TextDate)},
                      {FMH::MODEL_KEY::PATH, kfile.mostLocalUrl().toString()},
                      {FMH::MODEL_KEY::THUMBNAIL, kfile.localPath()},
                      {FMH::MODEL_KEY::SYMLINK, kfile.linkDest()},
                      {FMH::MODEL_KEY::IS_SYMLINK, QVariant(kfile.isLink()).toString()},
                      {FMH::MODEL_KEY::HIDDEN, QVariant(kfile.isHidden()).toString()},
                      {FMH::MODEL_KEY::IS_DIR, QVariant(kfile.isDir()).toString()},
                      {FMH::MODEL_KEY::IS_FILE, QVariant(kfile.isFile()).toString()},
                      {FMH::MODEL_KEY::WRITABLE, QVariant(kfile.isWritable()).toString()},
                      {FMH::MODEL_KEY::READABLE, QVariant(kfile.isReadable()).toString()},
                      {FMH::MODEL_KEY::EXECUTABLE, QVariant(kfile.isDesktopFile()).toString()},
                      {FMH::MODEL_KEY::MIME, kfile.mimetype()},
                      {FMH::MODEL_KEY::GROUP, kfile.group()},
                      {FMH::MODEL_KEY::ICON, kfile.iconName()},
                      {FMH::MODEL_KEY::SIZE, QString::number(kfile.size())},
                      {FMH::MODEL_KEY::THUMBNAIL, kfile.mostLocalUrl().toString()},
                      {FMH::MODEL_KEY::OWNER, kfile.user()},
                      {FMH::MODEL_KEY::COUNT, kfile.isLocalFile() && kfile.isDir() ? QString::number(QDir(kfile.localPath()).count() - 2) : "0"}};
#endif
    return res;
}

QVariantMap getFileInfo(const QUrl &path)
{
    return FMH::toMap(FMH::getFileInfoModel(path));
}

FMH::MODEL getDirInfoModel(const QUrl &path, const QString &type = QString())
{
    auto res = getFileInfoModel(path);
    res[FMH::MODEL_KEY::TYPE] = type;
    return res;
}

QVariantMap getDirInfo(const QUrl &path, const QString &type = QString())
{
    return FMH::toMap(FMH::getDirInfoModel(path, type));
}

}