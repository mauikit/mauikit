/*
    This file is part of KDE.

    Copyright 2010 Sebastian Kügler <sebas@kde.org>

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

#include "projecttest.h"

#include <QLabel>
#include <QListWidgetItem>
#include <QMenu>
#include <QMenuBar>
#include <QAction>
#include <QVBoxLayout>

#include <QDebug>

#include <itemjob.h>
#include <listjob.h>
#include <buildservice.h>
#include <buildservicejob.h>
#include <provider.h>
#include <project.h>

using namespace Attica;

ProjectTest::ProjectTest() : QMainWindow(),
    m_mainWidget(nullptr)
{
    m_mainWidget = new QWidget();
    setCentralWidget(m_mainWidget);

    m_editor = new Ui::EditProject();
    m_editor->setupUi(m_mainWidget);

    // Project page
    connect(m_editor->save, SIGNAL(clicked()), this, SLOT(save()));
    connect(m_editor->create, SIGNAL(clicked()), this, SLOT(create()));
    connect(m_editor->deleteProject, SIGNAL(clicked()), this, SLOT(deleteProject()));

    // build service / job page
    connect(m_editor->build, SIGNAL(clicked()), this, SLOT(createBuildServiceJob()));
    connect(m_editor->cancelJob, SIGNAL(clicked()), this, SLOT(cancelBuildServiceJob()));
    connect(m_editor->updateJob, SIGNAL(clicked()), this, SLOT(updateCurrentProject()));
    connect(m_editor->buildServices, SIGNAL(currentItemChanged(QListWidgetItem*,QListWidgetItem*)),
            this, SLOT(selectedBuildServiceChanged(QListWidgetItem*,QListWidgetItem*)));

    QAction *a = new QAction(this);
    a->setText(QLatin1String("Quit"));
    connect(a, SIGNAL(triggered()), SLOT(close()));
    menuBar()->addMenu(QLatin1String("File"))->addAction(a);

    initOcs();
}

ProjectTest::~ProjectTest()
{}

void ProjectTest::initOcs()
{
    m_pm.setAuthenticationSuppressed(true);
    connect(&m_pm, SIGNAL(providerAdded(Attica::Provider)), SLOT(providerAdded(Attica::Provider)));
    m_pm.loadDefaultProviders();
    m_mainWidget->setEnabled(false);
    setStatus(QLatin1String("Loading providers..."));
    //connect(m_serviceUpdates.data(), SIGNAL(mapped(QString)), SLOT(serviceUpdates(QString)));
}

void ProjectTest::providerAdded(const Attica::Provider &provider)
{
    qDebug() << "providerAdded" << provider.baseUrl();
    setStatus(QLatin1String("Provider found:") + provider.baseUrl().toString());
    m_mainWidget->setEnabled(true);

    if (provider.isValid()) {
        QString _id = QLatin1String("1");
        m_provider = provider;

        getProject(_id);

        listProjects();

        listBuildServices();

        Project p;
        p.setId(_id);
        listBuildServiceJobs(p);
    }
}

void ProjectTest::getProject(QString id)
{
    ItemJob<Project> *job = m_provider.requestProject(id);
    connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(projectResult(Attica::BaseJob*)));
    job->start();
    setStatus(QString(QLatin1String("Loading project %")).arg(id));
    m_mainWidget->setEnabled(false);

}

void ProjectTest::listProjects()
{
    ListJob<Project> *job = m_provider.requestProjects();
    connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(projectListResult(Attica::BaseJob*)));
    job->start();
}

void ProjectTest::listBuildServices()
{
    ListJob<BuildService> *job = m_provider.requestBuildServices();
    connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(buildServiceListResult(Attica::BaseJob*)));
    job->start();
}

void ProjectTest::listBuildServiceJobs(const Project &p)
{
    ListJob<BuildServiceJob> *job = m_provider.requestBuildServiceJobs(p);
    connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(buildServiceJobListResult(Attica::BaseJob*)));
    job->start();
}

void ProjectTest::projectResult(Attica::BaseJob *j)
{
    qDebug() << "Project job returned";
    QString output;
    m_mainWidget->setEnabled(true);

    if (j->metadata().error() == Metadata::NoError) {
        Attica::ItemJob<Project> *itemJob = static_cast<Attica::ItemJob<Project> *>(j);
        Attica::Project p = itemJob->result();
        output.append(QLatin1String("Project loaded."));

        projectToUi(p);
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    setStatus(output);
}

void ProjectTest::projectToUi(const Project &p)
{
    m_editor->id->setText(p.id());
    m_editor->name->setText(p.name());
    m_editor->description->setText(p.description());
    m_editor->url->setText(p.url());
    m_editor->summary->setText(p.summary());
    m_editor->developers->setText(p.developers().join(QLatin1String(", ")));
    m_editor->license->setText(p.license());
    m_editor->version->setText(p.version());
    m_editor->requirements->setText(p.requirements());
    m_editor->specFile->setPlainText(p.specFile());
}

Project ProjectTest::uiToProject()
{
    qDebug() << "Saving project";

    Project project = Project();

    project.setId(m_editor->id->text());
    project.setName(m_editor->name->text());
    project.setVersion(m_editor->version->text());
    project.setLicense(m_editor->license->text());
    project.setUrl(m_editor->url->text());
    QStringList _d = m_editor->developers->text().split(QLatin1Char(','));
    QStringList devs;
    foreach (const QString &dev, _d) {
        devs << dev.trimmed();
    }
    project.setDevelopers(devs);
    project.setSummary(m_editor->summary->text());
    project.setDescription(m_editor->description->text());
    project.setRequirements(m_editor->requirements->text());
    project.setSpecFile(m_editor->specFile->toPlainText());

    return project;
}

void ProjectTest::save()
{
    Attica::PostJob *postjob = m_provider.editProject(uiToProject());
    connect(postjob, SIGNAL(finished(Attica::BaseJob*)), SLOT(saveProjectResult(Attica::BaseJob*)));
    postjob->start();
    m_mainWidget->setEnabled(false);
}

void ProjectTest::create()
{
    Attica::PostJob *postjob = m_provider.createProject(uiToProject());
    connect(postjob, SIGNAL(finished(Attica::BaseJob*)), SLOT(createProjectResult(Attica::BaseJob*)));
    postjob->start();
    m_mainWidget->setEnabled(false);
}

void ProjectTest::deleteProject()
{
    Attica::PostJob *postjob = m_provider.deleteProject(uiToProject());
    connect(postjob, SIGNAL(finished(Attica::BaseJob*)), SLOT(deleteProjectResult(Attica::BaseJob*)));
    postjob->start();
    m_mainWidget->setEnabled(false);
}

void ProjectTest::createProjectResult(Attica::BaseJob *j)
{
    qDebug() << "createProject() job returned";
    QString output;
    m_mainWidget->setEnabled(true);

    if (j->metadata().error() == Metadata::NoError) {
        m_currentProjectId = j->metadata().resultingId();
        qDebug() << "Yay, no errors ... resulting ID:" << m_currentProjectId;
        output.append(QString(QLatin1String("Project [%1] successfully created:")).arg(m_currentProjectId));
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    setStatus(output);
}

void ProjectTest::saveProjectResult(Attica::BaseJob *j)
{
    qDebug() << "editProject() job returned";
    QString output;
    m_mainWidget->setEnabled(true);

    if (j->metadata().error() == Metadata::NoError) {
        m_currentProjectId = j->metadata().resultingId();
        qDebug() << "Yay, no errors ... resulting ID:" << m_currentProjectId;
        output.append(QString(QLatin1String("Project [%1] successfully saved.")).arg(m_currentProjectId));
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    setStatus(output);
}

void ProjectTest::deleteProjectResult(Attica::BaseJob *j)
{
    qDebug() << "deleteProject() job returned";
    QString output;
    m_mainWidget->setEnabled(true);

    if (j->metadata().error() == Metadata::NoError) {
        qDebug() << "Yay, no errors ... deleted project.";
        output.append(QString(QLatin1String("Project [%1] successfully deleted")).arg(m_currentProjectId));
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    setStatus(output);
    m_currentProjectId.clear();
    projectToUi(Project());
}

void ProjectTest::projectListResult(Attica::BaseJob *j)
{
    qDebug() << "Project list job returned";
    QString output = QLatin1String("<b>Projects:</b>");
    m_mainWidget->setEnabled(true);

    if (j->metadata().error() == Metadata::NoError) {
        Attica::ListJob<Project> *listJob = static_cast<Attica::ListJob<Project> *>(j);
        qDebug() << "Yay, no errors ...";
        QStringList projectIds;

        foreach (const Project &p, listJob->itemList()) {
            m_projects[p.id()] = p;
            qDebug() << "New project:" << p.id() << p.name();
            output.append(QString(QLatin1String("<br />%1 (%2)")).arg(p.name(), p.id()));
            projectIds << p.id();
            m_editor->projects->insertItem(0, p.name(), p.id());
            // TODO: start project jobs here
        }
        if (listJob->itemList().isEmpty()) {
            output.append(QLatin1String("No Projects found."));
        }
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    qDebug() << output;
    setStatus(output);
}

void ProjectTest::buildServiceListResult(Attica::BaseJob *j)
{
    qDebug() << "BuildService list job returned";
    QString output = QLatin1String("<b>BuildServices:</b>");
    //m_mainWidget->setEnabled(true); // fixme: tab

    if (j->metadata().error() == Metadata::NoError) {
        Attica::ListJob<BuildService> *listJob = static_cast<Attica::ListJob<BuildService> *>(j);
        qDebug() << "Yay, no errors ...";

        foreach (const BuildService &bs, listJob->itemList()) {
            m_buildServices[bs.id()] = bs;
            qDebug() << "New OBS:" << bs.id() << bs.name() << bs.url();
            output.append(QString(QLatin1String("<br />%1 (%2) at %3")).arg(bs.name(), bs.id(), bs.url()));
            QListWidgetItem *new_bs = new QListWidgetItem(bs.name(), m_editor->buildServices);
            new_bs->setData(Qt::UserRole, QVariant(bs.id()));

            m_editor->accountsServers->insertItem(0, bs.name(), bs.id());
            //QListWidgetItem* new_bsa = new QListWidgetItem(bs.name(), m_editor->accountsServers);
            //new_bsa->setData(Qt::UserRole, QVariant(bs.id()));

        }
        if (listJob->itemList().isEmpty()) {
            output.append(QLatin1String("No OBS'en found."));
        }
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    qDebug() << output;
    //setBuildStatus(output);
}

void ProjectTest::buildServiceJobListResult(Attica::BaseJob *j)
{
    qDebug() << "BuildServiceJobList list job returned";
    QString output = QLatin1String("<b>BuildServiceJobs: </b>");
    //m_mainWidget->setEnabled(true); // fixme: tab

    if (j->metadata().error() == Metadata::NoError) {
        Attica::ListJob<BuildServiceJob> *listJob = static_cast<Attica::ListJob<BuildServiceJob> *>(j);
        qDebug() << "Yay, no errors. Items found:" << listJob->itemList().count();

        foreach (const BuildServiceJob &bsj, listJob->itemList()) {
            m_buildServiceJobs[bsj.id()] = bsj;
            qDebug() << "New BuildServiceJob:" << bsj.id() << bsj.name() << bsj.target();
            output.append(QString(QLatin1String("<br />%1 (%2) for %3")).arg(bsj.name(), bsj.id(), bsj.target()));
            QListWidgetItem *new_bsj = new QListWidgetItem(bsj.name(), m_editor->buildServiceJobs);
            new_bsj->setData(Qt::UserRole, QVariant(bsj.id()));
        }
        if (listJob->itemList().isEmpty()) {
            output.append(QLatin1String("No jobs found."));
        }
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    qDebug() << output;
    //setBuildStatus(output);
}

void ProjectTest::selectedBuildServiceChanged(QListWidgetItem *current, QListWidgetItem *previous)
{
    Q_UNUSED(previous)
    qDebug() << "current item changed to " << current->data(Qt::UserRole).toString();
    m_editor->targets->clear();
    QList<Target> targetlist = m_buildServices[current->data(Qt::UserRole).toString()].targets();
    foreach (const Target &t, targetlist) {
        //m_editor->targets->insertItems(0, m_buildServices[current->data(Qt::UserRole).toString()].targets());
        m_editor->targets->insertItem(0, t.name, t.id);
        // FIXME: target id.
        qDebug() << "target:" << t.name << t.id;
    }
}

void ProjectTest::createBuildServiceJob()
{
    BuildServiceJob b = BuildServiceJob();
    b.setProjectId(m_editor->projects->itemData(m_editor->projects->currentIndex()).toString());
    b.setTarget(m_editor->targets->itemData(m_editor->targets->currentIndex()).toString());
    b.setBuildServiceId(m_editor->buildServices->currentItem()->data(Qt::UserRole).toString());
    b.setTarget(m_editor->targets->itemData(m_editor->targets->currentIndex()).toString());

    ///*
    qDebug() << "Create build job:" << m_editor->targets->itemData(m_editor->targets->currentIndex()).toString() << m_editor->targets->currentIndex() << m_editor->targets->itemData(m_editor->targets->currentIndex());
    qDebug() << "Project:" << b.projectId();
    qDebug() << "Target:" << b.target();
    qDebug() << "Buildservice:" << b.buildServiceId();
    //*/
    Attica::PostJob *j = m_provider.createBuildServiceJob(b);
    connect(j, SIGNAL(finished(Attica::BaseJob*)), this, SLOT(buildServiceJobCreated(Attica::BaseJob*)));
    j->start();
    setStatus(QLatin1String("Starting a build job on the server."));
}

void ProjectTest::cancelBuildServiceJob()
{
    const QString bsj_id = m_editor->buildServiceJobs->currentItem()->data(Qt::UserRole).toString();
    qDebug() << "Cancelling build job:" << bsj_id;
    BuildServiceJob b = BuildServiceJob();
    b.setId(bsj_id);
    Attica::PostJob *j = m_provider.cancelBuildServiceJob(b);
    connect(j, SIGNAL(finished(Attica::BaseJob*)), this, SLOT(buildServiceJobCanceled(Attica::BaseJob*)));
    j->start();
}

void ProjectTest::buildServiceJobCanceled(Attica::BaseJob *j)
{
    //m_mainWidget->setEnabled(true); // fixme: tab
    QString output;
    if (j->metadata().error() == Metadata::NoError) {
        qDebug() << "job canceled.";
        // TODO: refresh jobs
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    qDebug() << output;
    updateCurrentProject();
    setStatus(output);
}

void ProjectTest::buildServiceJobCreated(Attica::BaseJob *j)
{
    qDebug() << "JOB CREATED!!!!!!!!!!!!!!!!";
    //m_mainWidget->setEnabled(true); // fixme: tab
    QString output;
    if (j->metadata().error() == Metadata::NoError) {
        qDebug() << "job created. I think.";
        // TODO: refresh jobs
    } else if (j->metadata().error() == Metadata::OcsError) {
        output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
    } else if (j->metadata().error() == Metadata::NetworkError) {
        output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
    } else {
        output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
    }
    qDebug() << "New BuildServiceJob created with ID:" << j->metadata().resultingId();
    qDebug() << output;
    updateCurrentProject();
    setStatus(output);
}

void ProjectTest::setStatus(QString status)
{
    qDebug() << "[ii] Status:" << status;
    m_editor->status->setText(status);
}

QString ProjectTest::currentProject()
{
    return m_editor->projects->itemData(m_editor->projects->currentIndex()).toString();
}

void ProjectTest::updateCurrentProject()
{
    m_editor->buildServiceJobs->clear();
    qDebug() << "Updating project ...";
    Project p = Project();
    p.setId(currentProject());
    listBuildServiceJobs(p);
}

