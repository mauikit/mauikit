#ifndef UTILS_WEBDAVREPLY_HPP
#define UTILS_WEBDAVREPLY_HPP

#include <QList>
#include <QNetworkReply>
#include <QObject>
#include <QSslError>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#include "../dto/WebDAVItem.hpp"

#ifdef STATIC_MAUIKIT
class WebDAVReply : public QObject
#else
class MAUIKIT_EXPORT WebDAVReply : public QObject
#endif 
 {
  Q_OBJECT

 public:
  void sendListDirResponseSignal(QNetworkReply* listDirReply,
                                 QList<WebDAVItem> items);
  void sendDownloadResponseSignal(QNetworkReply* downloadReply);
  void sendDownloadProgressResponseSignal(qint64 bytesReceived,
                                          qint64 bytesTotal);
  void sendUploadFinishedResponseSignal(QNetworkReply* uploadReply);
  void sendError(QNetworkReply::NetworkError err);

 signals:
  void listDirResponse(QNetworkReply* listDirReply, QList<WebDAVItem> items);
  void downloadResponse(QNetworkReply* downloadReply);
  void downloadProgressResponse(qint64 bytesReceived, qint64 bytesTotal);
  void uploadFinished(QNetworkReply* uploadReply);
  void error(QNetworkReply::NetworkError err);
};

#endif
