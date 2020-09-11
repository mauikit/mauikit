#include <QtCore>
#include <QtQuick>

/*
class QfShareItem *
brief Manager to use share logic.
 *
author Andrew Shapovalov*/

class QfShareItem : public QQuickPaintedItem
{

Q_OBJECT
Q_PROPERTY(QString shareString READ getShareString WRITE setShareString NOTIFY shareStringChanged)
Q_PROPERTY(QUrl shareUrl READ getShareUrl WRITE setShareUrl NOTIFY shareUrlChanged)
private:
/** The share string info.*/
QString m_shareString;
/* The share link.*/
QUrl m_shareUrl;
/*
brief Strip all HTML tags from string.
 *
param body The source string. *
return Plain text.
 *
author Andrew Shapovalov*/
QString stripHTMLTags(QString body);
/**
brief Works with all applications events.
 *
param obj The object which call event. *
param event The event of call.
 *
author Andrew Shapovalov*/
bool eventFilter(QObject* obj, QEvent* event);
/**
brief Share current content.
 *
author Andrew Shapovalov*/
void shareCurrentContent();
public:
/**
brief Create a new object.
 *
param parent Parent object. *
author Andrew Shapovalov*/
 explicit QfShareItem(QQuickPaintedItem *parent = nullptr);

 //Others
 /*
brief Called when current object will redrawing. *
param painter The object for draw data.
 *
author Andrew Shapovalov*/
void paint(QPainter painter);
//Getters
/*
brief Get share content string.
 *
return Share string content. *
author Andrew Shapovalov*/
 inline QString getShareString(){return m_shareString;}

 /**
brief Get share url. *
return Share url.
 *
author Andrew Shapovalov*/
inline QUrl getShareUrl(){return m_shareUrl;}
//Setters
/**
brief Set share content string.
 *
param value Share string content. *
author Andrew Shapovalov*/
 inline void setShareString(QString value){m_shareString = value; emit shareStringChanged(m_shareString);}

 /**
brief Set share url. *
param value Share url.
 *
author Andrew Shapovalov*/
inline void setShareUrl(QUrl value){m_shareUrl = value; emit shareUrlChanged(m_shareUrl);}
/**
brief Share content and url.
 *
param text The text of share. *
param url The url to share.
 *
author Andrew Shapovalov*/
Q_INVOKABLE void shareContent(QString text = QString(), QUrl url = QUrl());
signals:
/**
brief Called when share content string was changed.
 *
param value Share string content. *
author Andrew Shapovalov*/
 void shareStringChanged(QString value);

 /**
brief Called when share url was changed. *
param value Share url.
 *
author Andrew Shapovalov*/
void shareUrlChanged(QUrl value);
/**
brief Called when user select share service.
 *
param serviceName The name of selected service. *
author Andrew Shapovalov*/
 void selectedService(QString serviceName);

 public slots:
};


