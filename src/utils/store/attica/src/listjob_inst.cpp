/*
    This file is part of KDE.

    Copyright (c) 2009 Eckhart Wörner <ewoerner@kde.org>
    Copyright (c) 2011 Laszlo Papp <djszapi@archlinux.us>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "listjob.cpp"
#include "itemjob.cpp"
#include "parser.cpp"

#include "accountbalance.h"
#include "accountbalanceparser.h"
#include "achievement.h"
#include "achievementparser.h"
#include "activity.h"
#include "activityparser.h"
#include "buildservice.h"
#include "buildserviceparser.h"
#include "buildservicejob.h"
#include "buildservicejobparser.h"
#include "buildservicejoboutput.h"
#include "buildservicejoboutputparser.h"
#include "privatedata.h"
#include "privatedataparser.h"
#include "category.h"
#include "categoryparser.h"
#include "comment.h"
#include "commentparser.h"
#include "config.h"
#include "configparser.h"
#include "content.h"
#include "contentparser.h"
#include "distribution.h"
#include "distributionparser.h"
#include "downloaditemparser.h"
#include "event.h"
#include "eventparser.h"
#include "folder.h"
#include "folderparser.h"
#include "forum.h"
#include "forumparser.h"
#include "homepagetype.h"
#include "homepagetypeparser.h"
#include "knowledgebaseentry.h"
#include "knowledgebaseentryparser.h"
#include "license.h"
#include "licenseparser.h"
#include "message.h"
#include "messageparser.h"
#include "person.h"
#include "personparser.h"
#include "project.h"
#include "projectparser.h"
#include "publisher.h"
#include "publisherparser.h"
#include "publisherfield.h"
#include "publisherfieldparser.h"
#include "remoteaccount.h"
#include "remoteaccountparser.h"
#include "topic.h"
#include "topicparser.h"

namespace Attica
{

template class ListJob<Achievement>;
template class ListJob<Activity>;
template class ListJob<BuildServiceJob>;
template class ListJob<BuildService>;
template class ListJob<Category>;
template class ListJob<Comment>;
template class ListJob<Content>;
template class ListJob<Distribution>;
template class ListJob<DownloadItem>;
template class ListJob<Event>;
template class ListJob<Folder>;
template class ListJob<Forum>;
template class ListJob<HomePageType>;
template class ListJob<KnowledgeBaseEntry>;
template class ListJob<License>;
template class ListJob<Message>;
template class ListJob<Person>;
template class ListJob<Topic>;
template class ItemJob<Project>;
template class ItemJob<Publisher>;
template class ItemJob<RemoteAccount>;

template class ItemPostJob<BuildService>;
template class ItemPostJob<BuildServiceJob>;
template class ItemPostJob<Project>;
template class ItemPostJob<Publisher>;
template class ItemPostJob<RemoteAccount>;

template class ListJob<Project>;
template class ListJob<Publisher>;
template class ListJob<PublisherField>;
template class ListJob<RemoteAccount>;

template class ItemJob<AccountBalance>;
template class ItemJob<Achievement>;
template class ItemJob<BuildServiceJob>;
template class ItemJob<BuildServiceJobOutput>;
template class ItemJob<BuildService>;
template class ItemJob<Forum>;
template class ItemJob<PrivateData>;
template class ItemJob<Config>;
template class ItemJob<Content>;
template class ItemJob<DownloadItem>;
template class ItemJob<Event>;
template class ItemJob<KnowledgeBaseEntry>;
template class ItemJob<Message>;
template class ItemJob<Person>;
template class ItemPostJob<Achievement>;
template class ItemPostJob<Content>;
template class ItemPostJob<Comment>;
template class ItemPostJob<Forum>;

template class ItemPutJob<Achievement>;

template class ItemDeleteJob<Achievement>;

template class Parser<AccountBalance>;
template class Parser<Achievement>;
template class Parser<Activity>;
template class Parser<BuildService>;
template class Parser<BuildServiceJob>;
template class Parser<BuildServiceJobOutput>;
template class Parser<PrivateData>;
template class Parser<Category>;
template class Parser<Comment>;
template class Parser<Config>;
template class Parser<Content>;
template class Parser<Distribution>;
template class Parser<DownloadItem>;
template class Parser<Event>;
template class Parser<Folder>;
template class Parser<Forum>;
template class Parser<HomePageType>;
template class Parser<KnowledgeBaseEntry>;
template class Parser<License>;
template class Parser<Message>;
template class Parser<Person>;
template class Parser<Project>;
template class Parser<Publisher>;
template class Parser<PublisherField>;
template class Parser<RemoteAccount>;
template class Parser<Topic>;

}
