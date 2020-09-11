#include "fileloader.h"

using namespace FMH;

std::function<FMH::MODEL(const QUrl &url)> FileLoader::informer =  &FMH::getFileInfoModel;

FileLoader::FileLoader(QObject *parent) : QObject(parent)
  ,m_thread ( new QThread )
{
    qRegisterMetaType<QDir::Filters>("QDir::Filters");
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
    this->moveToThread(m_thread);
    connect(m_thread, &QThread::finished, m_thread, &QObject::deleteLater);
    connect(this, &FileLoader::start, this, &FileLoader::getFiles);
    m_thread->start();
}

FileLoader::~FileLoader()
{
    m_thread->quit();
    m_thread->wait();
}

void FileLoader::requestPath(const QList<QUrl> &urls, const bool &recursive, const QStringList &nameFilters, const QDir::Filters &filters, const uint &limit)
{
    qDebug()<<"FROM file loader"<< urls;
    emit this->start(urls, recursive, nameFilters, filters, limit);
}

void FileLoader::getFiles(QList<QUrl> paths, bool recursive, const QStringList &nameFilters, const QDir::Filters &filters, uint limit)
{
    qDebug()<<"GETTING FILES";
    const uint m_bsize = 5000; //maximum batch size
    uint count = 0; //total count
    uint i = 0; //count per batch
    uint batch = 0; //batches count
    MODEL_LIST res;
    MODEL_LIST res_batch;

    for(const auto &path : paths)
    {
        if (QFileInfo(path.toLocalFile()).isDir() && path.isLocalFile() && fileExists(path))
        {
            QDirIterator it(path.toLocalFile(), nameFilters, filters, recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags);

            while (it.hasNext())
            {
                const auto url = QUrl::fromLocalFile(it.next());

                MODEL map = FileLoader::informer(url);

                emit itemReady(map);
                res << map;
                res_batch << map;
                i++;
                count++;

                if(i == m_bsize) //send a batch
                {
                    emit itemsReady(res_batch);
                    res_batch.clear ();
                    batch++;
                    i = 0;
                }

                if(count == limit)
                    break;
            }
        }

        if(count == limit)
            break;
    }
    emit itemsReady(res_batch);
    emit finished(res);
}
