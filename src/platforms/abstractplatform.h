#ifndef ABSTRACTPLATFORM_H
#define ABSTRACTPLATFORM_H

#include <QObject>
#include <QUrl>
#include <QList>
#include <QString>

/**
 * @brief The AbstractPlatform class
 * Defines abstract methods and properties that are common to be implemeted by each different platform Maui supports.
 * For detailed information check each platform  own's implementation
 */
class AbstractPlatform : public QObject
{
    Q_OBJECT

public:
    explicit AbstractPlatform(QObject * parent= nullptr);
    
public slots:

    /**
     * @brief shareFiles
     * @param urls
     */
   virtual void shareFiles(const QList<QUrl> &urls) = 0;

    /**
     * @brief shareText
     * @param urls
     */
   virtual void shareText(const QString &urls) = 0;

    /**
     * @brief openUrl
     * @param url
     */
   virtual void openUrl(const QUrl &url) = 0;

    /**
     * @brief hasKeyboard
     * @return
     */
   virtual bool hasKeyboard() = 0;

    /**
     * @brief hasMouse
     * @return
     */
    virtual bool hasMouse() = 0;

    virtual void notify(const QString &title, const QString &message, const QString &icon, const QString &imageUrl);

signals:
    void hasKeyboardChanged();
    void hasMouseChanged();
    void shareFilesRequest(QStringList urls);

};

#endif //ABSTRACTPLATFORM_H
