#ifndef FMSTATIC_H
#define FMSTATIC_H

#include "fmh.h"
#include <QObject>

#include "mauikit_export.h"

/**
 * @brief The FMStatic class
 * STatic file management methods, this class has a constructor only to register to QML, however all methods are static.
 */
class MAUIKIT_EXPORT FMStatic : public QObject
{
    Q_OBJECT
public:
    explicit FMStatic(QObject *parent = nullptr);

public slots:
    /**
     * @brief search
     * Search for files in a path using filters
     * @param query
     * Term to be searched, such as ".qml" or "music"
     * @param path
     * The path to perform the search upon
     * @param hidden
     * If should also search for hidden files
     * @param onlyDirs
     * If only searching for directories and not files
     * @param filters
     * List of filter patterns such as {"*.qml"}, it can use regular expressions
     * @return
     * The search results are returned as a FMH::MODEL_LIST
     */
    static FMH::MODEL_LIST search(const QString &query, const QUrl &path, const bool &hidden = false, const bool &onlyDirs = false, const QStringList &filters = QStringList());

    /**
     * @brief getDevices
     * Devices mounted to the file system
     * @return
     * Represented as a FMH::MODEL_LIST
     */
    static FMH::MODEL_LIST getDevices();

    /**
     * @brief getDefaultPaths
     * A model list of the default paths in most systems, such as Home, Pictures, Video, Downloads, Music and Documents folders
     * @return
     */
    static FMH::MODEL_LIST getDefaultPaths();

    /**
     * @brief packItems
     * Given a list of path URLs pack all the info of such files as a FMH::MODEL_LIST
     * @param items
     * List of local URLs
     * @param type
     * The type of the list of urls, such as local, remote etc. This value is inserted with the key FMH::MODEL_KEY::TYPE
     * @return
     */
    static FMH::MODEL_LIST packItems(const QStringList &items, const QString &type);

    /**
     * @brief copy
     * Perfom a copy of the files to the passed destination
     * @param urls
     * List of URLs to be copy
     * @param destinationDir
     * Destination
     * @return
     * Return if the operation has been succesfull
     */
    static bool copy(const QList<QUrl> &urls, const QUrl &destinationDir);

    /**
     * @brief cut
     * Perform a move/cut of a list of files to a destination. This function also moves the associated tags if the tags component has been enabled COMPONENT_TAGGING
     * @param urls
     * List of URLs to be moved
     * @param where
     * Destination path
     * @return
     * If the operation has been sucessfull
     */
    static bool cut(const QList<QUrl> &urls, const QUrl &where);

    /**
     * @brief cut
     * @param urls
     * @param where
     * @param name
     * New name of the files to be moved
     * @return
     */
    static bool cut(const QList<QUrl> &urls, const QUrl &where, const QString &name);

    /**
     * @brief removeFiles
     * List of files to be removed completely. This function also removes the assciated tags to the files if the tagging component has been enabled COMPONENT_TAGGING
     * @param urls
     * @return
     * If the operation has been sucessfull
     */
    static bool removeFiles(const QList<QUrl> &urls);

    /**
     * @brief removeDir
     * Remove a directory recursively
     * @param path
     * Path URL to be rmeoved
     * @return
     * If the operation has been sucessfull
     */
    static bool removeDir(const QUrl &path);

    /**
     * @brief formatSize
     * Format a file size
     * @param size
     * size in bytes
     * @return
     * Formated into a readable string
     */
    static QString formatSize(const int &size);

    /**
     * @brief formatTime
     * Format a milliseconds value to a readable format
     * @param value
     * Milliseconds
     * @return
     * Readable formated value
     */
    static QString formatTime(const qint64 &value);

    /**
     * @brief formatDate
     * Given a date string, a format and a intended format return a readable string
     * @param dateStr
     * Date format
     * @param format
     * Intended format, by default "dd/MM/yyyy"
     * @param initFormat
     * Date format
     * @return
     */
    static QString formatDate(const QString &dateStr, const QString &format = QString("dd/MM/yyyy"), const QString &initFormat = QString());

    /**
     * @brief homePath
     * The default home path in different systems
     * @return
     */
    static QString homePath();

    /**
     * @brief parentDir
     * Given a file url return its parent directory
     * @param path
     * The file URL
     * @return
     * The parent directory URL if it exists otherwise returns the passed URL
     */
    static QUrl parentDir(const QUrl &path);

    /**
     * @brief getDirInfo
     * Get info of a directory packed as a QVariantMap model
     * @param path
     * Path URL
     * @return
     */
    static QVariantMap getDirInfo(const QUrl &path);

    /**
     * @brief getFileInfo
     * Get file info
     * @param path
     * @return
     * File info packed as a QVariantMap model
     */
    static QVariantMap getFileInfo(const QUrl &path);

    /**
     * @brief isDefaultPath
     * Checks if a given path URL is a default path as in returned by the defaultPaths method
     * @param path
     * @return
     */
    static bool isDefaultPath(const QString &path);

    /**
     * @brief isDir
     * If a local file URL is a directory
     * @param path
     * File URL
     * @return
     */
    static bool isDir(const QUrl &path);

    /**
     * @brief isCloud
     * If a path is a URL server instead of a local file
     * @param path
     * @return
     */
    static bool isCloud(const QUrl &path);

    /**
     * @brief fileExists
     * Checks if a local file exists in the file system
     * @param path
     * File URL
     * @return
     * Existance
     */
    static bool fileExists(const QUrl &path);

    /**
     * if the url is a file path then it returns its directory
     * and if it is a directory returns the same path
     * */
    /**
     * @brief fileDir
     * Gives the directory URL path of a file,  and if it is a directory returns the same path
     * @param path
     * File path URL
     * @return
     * The directory URL
     */
    static QString fileDir(const QUrl &path);

    /* SETTINGS */
    /**
     * @brief saveSettings
     * Saves a key-value settings into a config file determined by the application name and org. This is a interface to the Utils utility that takes care of resolving the right path for the config file.
     * @param key
     * Key of the setting
     * @param value
     * Value fo the key setting
     * @param group
     * The group to which the key belongs
     */
    static void saveSettings(const QString &key, const QVariant &value, const QString &group);

    /**
     * @brief loadSettings
     * Loads a setting value
     * @param key
     * Setting key
     * @param group
     * Setting group
     * @param defaultValue
     * In case the setting key is not present use this default value
     * @return
     * A QVariant holding the setting value
     */
    static QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue);

    /**
     * @brief dirConf
     * The config values of a directory, such values can be any from iconname to specific ones. The config file is stored in the directory as .dir
     * @param path
     * @return
     */
    static const QVariantMap dirConf(const QUrl &path);

    /**
     * @brief setDirConf
     * Write a config key-value to the directory config file
     * @param path
     * @param group
     * @param key
     * @param value
     */
    static void setDirConf(const QUrl &path, const QString &group, const QString &key, const QVariant &value);

    /**
     * @brief checkFileType
     * Checks if a mimetype belongs to a file type, for example image/jpg belong to the type FMH::FILTER_TYPE
     * @param type
     * FMH::FILTER_TYPE value
     * @param mimeTypeName
     * @return
     */
    static bool checkFileType(const int &type, const QString &mimeTypeName);

    /**
     * @brief moveToTrash
     * Moves to the trash can the file URLs. The associated tags are kept in case the files are restored.
     * @param urls
     */
    static void moveToTrash(const QList<QUrl> &urls);

    /**
     * @brief emptyTrash
     * Empty the trash casn
     */
    static void emptyTrash();

    /**
     * @brief rename
     * Rename a file to a new name
     * @param url
     * File URL to be renamed
     * @param name
     * The short new name of the file, not the new URL, for setting a new URl use cut instead.
     * @return
     */
    static bool rename(const QUrl &url, const QString &name);

    /**
     * @brief createDir
     * Creates a directory given a base path and a directory name
     * @param path
     * Base directory path
     * @param name
     * New directory name
     * @return
     * If the operation was sucessfull
     */
    static bool createDir(const QUrl &path, const QString &name);

    /**
     * @brief createFile
     * Creates a file given the base directory path and a short file name
     * @param path
     * Base directory path
     * @param name
     * Name of the new file to be created with the extension
     * @return
     */
    static bool createFile(const QUrl &path, const QString &name);

    /**
     * @brief createSymlink
     * Creates a symlink
     * @param path
     * File to be symlinked
     * @param where
     * Destination of the symlink
     * @return
     */
    static bool createSymlink(const QUrl &path, const QUrl &where);

    /**
     * @brief openUrl
     * Given a URL it tries to open it using the default app associated to it
     * @param url
     * The URL to be open
     * @return
     */
    static bool openUrl(const QUrl &url);

    /**
     * @brief openLocation
     * Open with the default file manager a list of URLs
     * @param urls
     */
    static void openLocation(const QStringList &urls);

    /**
     * @brief isFav
     * Checks if a file URL has been marked as favorite. This works if the tagging component has been enabled, otherwise returns fase as default.
     * @param url
     * The file URL to be checked
     * @param strict
     * Strictly check if the file has been marked as favorite by the app making the request or not
     * @return
     */
    static bool isFav(const QUrl &url, const bool &strict = false);

    /**
     * @brief unFav
     * If the file has been marked as favorite then the tag is removed. This works if the tagging component has been enabled, otherwise returns fase as default.
     * @param url
     * The file URL
     * @return
     * If the operation has been sucessfull
     */
    static bool unFav(const QUrl &url);

    /**
     * @brief fav
     * Marks a file URL as favorite.  This works if the tagging component has been enabled, otherwise returns fase as default.
     * @param url
     * File URL
     * @return
     * If the operation has been sucessfull
     */
    static bool fav(const QUrl &url);

    /**
     * @brief toggleFav
     * Toogle the fav tag of a given file, meaning, if a file is marked as fav then the tag gets removed and if it is not marked then the fav tag gets added.
     * @param url
     * The file URL
     * @return
     * If the operation has been sucessfull
     */
    static bool toggleFav(const QUrl &url);

    /**
     * @brief getTagUrls
     * Shortcut for gettings a list of file URLs associated to a tag, the resulting list of URLs can be filtered by regular expression or by mimetype and limited
     * @param tag
     * The tag to look up
     * @param filters
     * The regular expresions list
     * @param strict
     * If strict then the URLs returned are only associated to the application making the call, meaning, that such tag was added by such application only.
     * @param limit
     * The maximum limit number of URLs to be returned
     * @param mime
     * The mimetype filtering, for example, "image/\*" or "image/png", "audio/mp4"
     * @return
     */
    static QList<QUrl> getTagUrls(const QString &tag, const QStringList &filters, const bool &strict = false, const int &limit = 9999, const QString &mime = "");

    /**
     * @brief getTags
     * Get all the tags avaliable with detailed information packaged as a FMH::MODEL_LIST
     * @param limit
     * Maximum numbers of tags
     * @return
     * Model of tags
     */
    static FMH::MODEL_LIST getTags(const int &limit = 5);

    /**
     * @brief getTagContent
     * Gets a model of the files associated with a tag
     * @param tag
     * The lookup tag
     * @param filters
     * Filters as regular expression
     * @return
     * Model of files associated
     */
    static FMH::MODEL_LIST getTagContent(const QString &tag, const QStringList &filters = {});

    /**
     * @brief getUrlTags
     * Return a model of tags associated to a file URL
     * @param url
     * The file URL
     * @return
     * Modle of the tags
     */
   static FMH::MODEL_LIST getUrlTags(const QUrl &url);

    /**
     * @brief urlTagExists
     * Checks if a tag is a associated with a file URL
     * @param url
     * File URL
     * @param tag
     * The lookup tag
     * @return
     * If the tag exists and is associated ot the file
     */
    static bool urlTagExists(const QUrl &url, const QString tag);

    /**
     * @brief addTagToUrl
     * Adds a tag to a given file URL
     * @param tag
     * The wanted tag, if the tag doesnt exists it is created
     * @param url
     * The file URL
     * @return
     * If the operation has been sucessfull
     */
    static bool addTagToUrl(const QString tag, const QUrl &url);

    /**
     * @brief removeTagToUrl
     * Removes a tag from a file URl if the tags exists
     * @param tag
     * the lookup tag
     * @param url
     * The file URL
     * @return
     * If the operation has been sucessfull
     */
    static bool removeTagToUrl(const QString tag, const QUrl &url);

    /**
     * @brief bookmark
     * Add a URL to the places bookmarks
     * @param url
     * The file URL to be bookmarked
     */
    static void bookmark(const QUrl &url);

    /**
     * @brief nameFilters
     * Given a filter type return a list of associated name filters, as in suffixes.
     * @param type
     * The filter type to be mapped to a FMH::FILTER_TYPE
     */
    static QStringList nameFilters(const int &type);
};

#endif // FMSTATIC_H
