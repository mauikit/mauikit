#ANDROID_EXTRA_LIBS += $$PWD/libKF5Attica.so

#LIBS += -L$$PWD/./ -lKF5Attica

#INCLUDEPATH += $$PWD/headers
#DEPENDPATH += $$PWD/headers

#LIBS += -lc++_shared

QT += core network

HEADERS += \
        $$PWD/src/accountbalance.h \
        $$PWD/src/accountbalanceparser.h \
        $$PWD/src/achievement.h \
        $$PWD/src/achievementparser.h \
        $$PWD/src/buildservice.h \
        $$PWD/src/buildserviceparser.h \
        $$PWD/src/buildservicejob.h \
        $$PWD/src/buildservicejobparser.h \
        $$PWD/src/buildservicejoboutput.h \
        $$PWD/src/buildservicejoboutputparser.h \
        $$PWD/src/activity.h \
        $$PWD/src/activityparser.h \
        $$PWD/src/atticabasejob.h \
        $$PWD/src/atticautils.h \
        $$PWD/src/privatedata.h \
        $$PWD/src/privatedataparser.h \
        $$PWD/src/category.h \
        $$PWD/src/categoryparser.h \
        $$PWD/src/comment.h \
        $$PWD/src/commentparser.h \
        $$PWD/src/config.h \
        $$PWD/src/configparser.h \
        $$PWD/src/content.h \
        $$PWD/src/contentparser.h \
        $$PWD/src/deletejob.h \
        $$PWD/src/distribution.h \
        $$PWD/src/distributionparser.h \
        $$PWD/src/downloaddescription.h \
        $$PWD/src/downloaditem.h \
        $$PWD/src/downloaditemparser.h \
        $$PWD/src/event.h \
        $$PWD/src/eventparser.h \
        $$PWD/src/folder.h \
        $$PWD/src/folderparser.h \
        $$PWD/src/forum.h \
        $$PWD/src/forumparser.h \
        $$PWD/src/getjob.h \
        $$PWD/src/homepageentry.h \
        $$PWD/src/homepagetype.h \
        $$PWD/src/homepagetypeparser.h \
        $$PWD/src/icon.h \
        $$PWD/src/itemjob.h \
        $$PWD/src/knowledgebaseentry.h \
        $$PWD/src/knowledgebaseentryparser.h \
        $$PWD/src/license.h \
        $$PWD/src/licenseparser.h \
        $$PWD/src/listjob_inst.h \
        $$PWD/src/message.h \
        $$PWD/src/messageparser.h \
        $$PWD/src/metadata.h \
        $$PWD/src/parser.h \
        $$PWD/src/person.h \
        $$PWD/src/personparser.h \
        $$PWD/src/platformdependent_v2.h \
        $$PWD/src/postfiledata.h \
        $$PWD/src/postjob.h \
        $$PWD/src/project.h \
        $$PWD/src/projectparser.h \
        $$PWD/src/putjob.h \
        $$PWD/src/remoteaccount.h \
        $$PWD/src/remoteaccountparser.h \
        $$PWD/src/provider.h \
        $$PWD/src/providermanager.h \
        $$PWD/src/publisher.h \
        $$PWD/src/publisherparser.h \
        $$PWD/src/publisherfield.h \
        $$PWD/src/publisherfieldparser.h \
        $$PWD/src/qtplatformdependent.h \
        $$PWD/src/topic.h \
        $$PWD/src/topicparser.h \

SOURCES += \
        $$PWD/src/accountbalance.cpp \
        $$PWD/src/accountbalanceparser.cpp \
        $$PWD/src/achievement.cpp \
        $$PWD/src/achievementparser.cpp \
        $$PWD/src/buildservice.cpp \
        $$PWD/src/buildserviceparser.cpp \
        $$PWD/src/buildservicejob.cpp \
        $$PWD/src/buildservicejobparser.cpp \
        $$PWD/src/buildservicejoboutput.cpp \
        $$PWD/src/buildservicejoboutputparser.cpp \
        $$PWD/src/activity.cpp \
        $$PWD/src/activityparser.cpp \
        $$PWD/src/atticabasejob.cpp \
        $$PWD/src/atticautils.cpp \
        $$PWD/src/privatedata.cpp \
        $$PWD/src/privatedataparser.cpp \
        $$PWD/src/category.cpp \
        $$PWD/src/categoryparser.cpp \
        $$PWD/src/comment.cpp \
        $$PWD/src/commentparser.cpp \
        $$PWD/src/config.cpp \
        $$PWD/src/configparser.cpp \
        $$PWD/src/content.cpp \
        $$PWD/src/contentparser.cpp \
        $$PWD/src/deletejob.cpp \
        $$PWD/src/distribution.cpp \
        $$PWD/src/distributionparser.cpp \
        $$PWD/src/downloaddescription.cpp \
        $$PWD/src/downloaditem.cpp \
        $$PWD/src/downloaditemparser.cpp \
        $$PWD/src/event.cpp \
        $$PWD/src/eventparser.cpp \
        $$PWD/src/folder.cpp \
        $$PWD/src/folderparser.cpp \
        $$PWD/src/forum.cpp \
        $$PWD/src/forumparser.cpp \
        $$PWD/src/getjob.cpp \
        $$PWD/src/homepageentry.cpp \
        $$PWD/src/homepagetype.cpp \
        $$PWD/src/homepagetypeparser.cpp \
        $$PWD/src/icon.cpp \
        $$PWD/src/itemjob.cpp \
        $$PWD/src/knowledgebaseentry.cpp \
        $$PWD/src/knowledgebaseentryparser.cpp \
        $$PWD/src/license.cpp \
        $$PWD/src/licenseparser.cpp \
        $$PWD/src/listjob_inst.cpp \
        $$PWD/src/message.cpp \
        $$PWD/src/messageparser.cpp \
        $$PWD/src/metadata.cpp \
        $$PWD/src/parser.cpp \
        $$PWD/src/person.cpp \
        $$PWD/src/personparser.cpp \
        $$PWD/src/platformdependent_v2.cpp \
        $$PWD/src/postfiledata.cpp \
        $$PWD/src/postjob.cpp \
        $$PWD/src/project.cpp \
        $$PWD/src/projectparser.cpp \
        $$PWD/src/putjob.cpp \
        $$PWD/src/remoteaccount.cpp \
        $$PWD/src/remoteaccountparser.cpp \
        $$PWD/src/provider.cpp \
        $$PWD/src/providermanager.cpp \
        $$PWD/src/publisher.cpp \
        $$PWD/src/publisherparser.cpp \
        $$PWD/src/publisherfield.cpp \
        $$PWD/src/publisherfieldparser.cpp \
        $$PWD/src/qtplatformdependent.cpp \
        $$PWD/src/topic.cpp \
        $$PWD/src/topicparser.cpp \

DEPENDPATH += \
    $$PWD/src \

INCLUDEPATH += \
     $$PWD/src  \


