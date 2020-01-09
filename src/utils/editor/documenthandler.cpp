/****************************************************************************
 * *
 ** Copyright (C) 2017 The Qt Company Ltd.
 ** Contact: https://www.qt.io/licensing/
 **
 ** This file is part of the examples of the Qt Toolkit.
 **
 ** $QT_BEGIN_LICENSE:BSD$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and The Qt Company. For licensing terms
 ** and conditions see https://www.qt.io/terms-conditions. For further
 ** information use the contact form at https://www.qt.io/contact-us.
 **
 ** BSD License Usage
 ** Alternatively, you may use this file under the terms of the BSD license
 ** as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of The Qt Company Ltd nor the names of its
 **     contributors may be used to endorse or promote products derived
 **     from this software without specific prior written permission.
 **
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

#include "documenthandler.h"

#include <QFile>
#include <QFileInfo>
#include <QFileSelector>
#include <QQmlFile>
#include <QQmlFileSelector>
#include <QQuickTextDocument>
#include <QTextCharFormat>
#include <QTextCodec>
#include <QTextDocument>
#include <QDebug>
#include <QUrl>
#include <QFileSystemWatcher>

#include "fmh.h"
#include "utils.h"

#ifdef STATIC_MAUIKIT
#include <KSyntaxHighlighting/KSyntaxHighlighting/Definition>
#include <KSyntaxHighlighting/KSyntaxHighlighting/Repository>
#include <KSyntaxHighlighting/KSyntaxHighlighting/SyntaxHighlighter>
#include <KSyntaxHighlighting/KSyntaxHighlighting/Theme>
#else
#include <KSyntaxHighlighting/Definition>
#include <KSyntaxHighlighting/Repository>
#include <KSyntaxHighlighting/SyntaxHighlighter>
#include <KSyntaxHighlighting/Theme>
#endif

/**
 * Global Variables
 */
KSyntaxHighlighting::Repository *DocumentHandler::m_repository = nullptr;
int DocumentHandler::m_instanceCount = 0;

Alerts::Alerts(QObject* parent) : QAbstractListModel(parent)
{}

Alerts::~Alerts()
{
	qDebug()<< "REMOVING ALL DOCUMENTS ALERTS";
	for(auto *alert : this->m_alerts)
		delete alert;
}

QVariant Alerts::data(const QModelIndex& index, int role) const
{
	if(role == ROLES::ALERT)
		return QVariant::fromValue(this->m_alerts.at(index.row()));
	
	return QVariant();
}

int Alerts::rowCount(const QModelIndex& parent) const
{
	if (parent.isValid())
		return 0;
	
	return this->m_alerts.count();
}

QHash<int, QByteArray> Alerts::roleNames() const
{
	return {{ROLES::ALERT, "alert"}};
}

void Alerts::append(DocumentAlert *alert)
{
	const auto index = this->rowCount();
	beginInsertRows(QModelIndex(), index, index);
	
	// watch out for when the alert is done: such as when an action is triggered
	connect(alert, &DocumentAlert::done, [&](int index)
	{
		this->beginRemoveRows(QModelIndex(), index, index);
		auto item = this->m_alerts.takeAt(index);
		item->deleteLater();
		this->endRemoveRows();		
	});
	
	alert->setIndex(index);
	this->m_alerts << alert;
	endInsertRows();
}

void FileLoader::loadFile(const QUrl& url)
{
	if (FMH::fileExists(url))
	{		
		QFile file(url.toLocalFile());
		if (file.open(QFile::ReadOnly))
		{		
			const auto array = file.readAll();
			
			const bool isHtml = QFileInfo(url.toLocalFile()).suffix().contains(QLatin1String("htm"));					
			QTextCodec *codec = isHtml ? QTextCodec::codecForHtml(array) : QTextCodec::codecForUtfText(array, QTextCodec::codecForLocale());		
			
			emit this->fileReady(codec->toUnicode(array), url);
		}
	}
}

DocumentAlert * DocumentHandler::externallyModifiedAlert()
{
	auto alert = new DocumentAlert(tr("File changed externally"), tr("You can reload the file or save your changes now"), DocumentAlert::WARNING_LEVEL);
	
	const auto reloadAction = [&]()
	{
		emit this->loadFile(this->fileUrl());
	};
	
	const auto autoReloadAction = [&]()
	{
		this->setAutoReload(true);		
		emit this->loadFile(this->fileUrl());
	};	
		
	alert->setActions({{tr("Reload"), reloadAction}, {tr("Auto Reload"), autoReloadAction}, {tr("Ignore"), [&](){}}});
	return alert;
}

DocumentAlert * DocumentHandler::canNotSaveAlert(const QString &details)
{
	auto alert = new DocumentAlert(tr("File can not be saved"), details, DocumentAlert::DANGER_LEVEL);
	
	alert->setActions({{tr("Ignore"), [&](){}}});
	return alert;
}

DocumentAlert * DocumentHandler::missingAlert()
{	
	auto alert = new DocumentAlert(tr("Your file was removed"), tr("This file does not longer exists in your local storage, however you can save it again"), DocumentAlert::DANGER_LEVEL);
	
	const auto saveAction = [&]()
	{
		this->saveAs(this->fileUrl());
	};
	
	alert->setActions({{tr("Save"), saveAction}});
	return alert;
}

DocumentHandler::DocumentHandler(QObject *parent)
: QObject(parent)
, m_document(nullptr)
, m_watcher(new QFileSystemWatcher(this))	
, m_cursorPosition(-1)
, m_selectionStart(0)
, m_selectionEnd(0)
, m_highlighter(new KSyntaxHighlighting::SyntaxHighlighter(this))
, m_alerts(new Alerts(this))
{
	++m_instanceCount;
	
	//start file loader thread implementation
	{
		FileLoader *m_loader =  new FileLoader;	
		m_loader->moveToThread(&m_worker);
		connect(&m_worker, &QThread::finished, m_loader, &QObject::deleteLater);
		connect(this, &DocumentHandler::loadFile, m_loader, &FileLoader::loadFile);
		connect(m_loader, &FileLoader::fileReady, [&](QString array, QUrl url)
		{       
			if (QTextDocument *doc = textDocument())		
				doc->setModified(false);
			
			this->isRich = QFileInfo(url.toLocalFile()).suffix().contains(QLatin1String("rtf"));//         
			emit this->isRichChanged();
			
			this->setText(array);		
			
			this->setFormatName(DocumentHandler::getLanguageNameFromFileName(url));
			
			emit this->loaded(url);
			
			reset();
		});	
		m_worker.start();	
	}
	//end file loader thread implementation
	
	connect(this->m_watcher, &QFileSystemWatcher::fileChanged, [&](QString url)
	{		
		if(this->fileUrl() == QUrl::fromLocalFile(url))
		{
			//THE FILE WAS REMOVED	
			if(!FMH::fileExists(this->fileUrl()))
			{				
				this->m_alerts->append(DocumentHandler::missingAlert());				
				return;
			}
			
			//THE FILE CHANGED BUT STILL EXISTS LOCALLY
			if(m_internallyModified)
			{
				m_internallyModified = false;
				return;
			}
			
			this->setExternallyModified(true);			
			
			if(!this->m_autoReload)
			{
				this->m_alerts->append(DocumentHandler::externallyModifiedAlert());
				return;				
			}
			
			emit this->loadFile(this->fileUrl());
		}
	});
}

DocumentHandler::~DocumentHandler()
{
	m_worker.quit();
	m_worker.wait();
	
	--m_instanceCount;
	
	if (!m_instanceCount)
	{
		delete DocumentHandler::m_repository;
		DocumentHandler::m_repository = nullptr;
	}	
}

void DocumentHandler::setText(const QString &text)
{
	if (text != m_text)
	{
		m_text = text;
		emit textChanged();
	}
}

bool DocumentHandler::getAutoReload() const
{
	return this->m_autoReload;
}

void DocumentHandler::setAutoReload(const bool& value)
{
	if(value == this->m_autoReload)
		return;
	
	this->m_autoReload = value;
	emit this->autoReloadChanged();
}

bool DocumentHandler::getModified() const
{
	return this->textDocument()->isModified();
}

bool DocumentHandler::getExternallyModified() const
{
	return this->m_externallyModified;
}

void DocumentHandler::setExternallyModified(const bool& value)
{
	if(value == this->m_externallyModified)
		return;
	
	this->m_externallyModified = value;
	emit this->externallyModifiedChanged();
}

void DocumentHandler::setStyle()
{
	if (!DocumentHandler::m_repository)		
		DocumentHandler::m_repository = new KSyntaxHighlighting::Repository();
	
	const auto isDark = UTIL::isDark(this->m_backgroundColor);
	
	const auto style = DocumentHandler::m_repository->defaultTheme(isDark ?KSyntaxHighlighting::Repository::DarkTheme : KSyntaxHighlighting::Repository::LightTheme);	
	
	m_highlighter->setTheme(style);
	
	m_highlighter->setDefinition(DocumentHandler::m_repository->definitionForName(this->m_formatName));	
}

QString DocumentHandler::formatName() const
{
	return this->m_formatName;
}

void DocumentHandler::setFormatName(const QString& formatName)
{
	if (m_formatName != formatName)
	{
		m_formatName = formatName;
		emit this->formatNameChanged();
		
		this->setStyle();		
	}
}

QColor DocumentHandler::getBackgroundColor() const
{
	return this->m_backgroundColor;
}

void DocumentHandler::setBackgroundColor(const QColor& color)
{
	if(this->m_backgroundColor == color)
		return;
	
	this->m_backgroundColor = color;
	emit this->backgroundColorChanged();
	
	this->setStyle();
}

Alerts *DocumentHandler::getAlerts() const
{
	return this->m_alerts;
}

QQuickTextDocument *DocumentHandler::document() const
{
	return m_document;
}

void DocumentHandler::setDocument(QQuickTextDocument *document)
{
	if (document == m_document)
		return;
	
	m_document = document;
	emit documentChanged();
	
	m_highlighter->setDocument(m_document->textDocument());	
}

int DocumentHandler::cursorPosition() const
{
	return m_cursorPosition;
}

void DocumentHandler::setCursorPosition(int position)
{
	if (position == m_cursorPosition)
		return;
	
	m_cursorPosition = position;
	reset();
	emit cursorPositionChanged();
}

int DocumentHandler::selectionStart() const
{
	return m_selectionStart;
}

void DocumentHandler::setSelectionStart(int position)
{
	if (position == m_selectionStart)
		return;
	
	m_selectionStart = position;
	emit selectionStartChanged();
}

int DocumentHandler::selectionEnd() const
{
	return m_selectionEnd;
}

void DocumentHandler::setSelectionEnd(int position)
{
	if (position == m_selectionEnd)
		return;
	
	m_selectionEnd = position;
	emit selectionEndChanged();
}

QString DocumentHandler::fontFamily() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return QString();
	QTextCharFormat format = cursor.charFormat();
	return format.font().family();
}

void DocumentHandler::setFontFamily(const QString &family)
{
	QTextCharFormat format;
	format.setFontFamily(family);
	mergeFormatOnWordOrSelection(format);
	emit fontFamilyChanged();
}

QColor DocumentHandler::textColor() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return QColor(Qt::black);
	QTextCharFormat format = cursor.charFormat();
	return format.foreground().color();
}

void DocumentHandler::setTextColor(const QColor &color)
{
	QTextCharFormat format;
	format.setForeground(QBrush(color));
	mergeFormatOnWordOrSelection(format);
	emit textColorChanged();
}

Qt::Alignment DocumentHandler::alignment() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return Qt::AlignLeft;
	return textCursor().blockFormat().alignment();
}

void DocumentHandler::setAlignment(Qt::Alignment alignment)
{
	QTextBlockFormat format;
	format.setAlignment(alignment);
	QTextCursor cursor = textCursor();
	cursor.mergeBlockFormat(format);
	emit alignmentChanged();
}

bool DocumentHandler::bold() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return false;
	return textCursor().charFormat().fontWeight() == QFont::Bold;
}

void DocumentHandler::setBold(bool bold)
{
	QTextCharFormat format;
	format.setFontWeight(bold ? QFont::Bold : QFont::Normal);
	mergeFormatOnWordOrSelection(format);
	emit boldChanged();
}

bool DocumentHandler::uppercase() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return false;
	return textCursor().charFormat().fontCapitalization() == QFont::AllUppercase;
}

void DocumentHandler::setUppercase(bool uppercase)
{
	QTextCharFormat format;
	format.setFontCapitalization(uppercase ? QFont::AllUppercase : QFont::AllLowercase);
	mergeFormatOnWordOrSelection(format);
	emit uppercaseChanged();
}

bool DocumentHandler::italic() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return false;
	return textCursor().charFormat().fontItalic();
}

void DocumentHandler::setItalic(bool italic)
{
	QTextCharFormat format;
	format.setFontItalic(italic);
	mergeFormatOnWordOrSelection(format);
	emit italicChanged();
}

bool DocumentHandler::underline() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return false;
	return textCursor().charFormat().fontUnderline();
}

void DocumentHandler::setUnderline(bool underline)
{
	QTextCharFormat format;
	format.setFontUnderline(underline);
	mergeFormatOnWordOrSelection(format);
	emit underlineChanged();
}

bool DocumentHandler::getIsRich() const
{
	return this->isRich;
}

int DocumentHandler::fontSize() const
{
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return 0;
	QTextCharFormat format = cursor.charFormat();
	return format.font().pointSize();
}

void DocumentHandler::setFontSize(int size)
{
	if (size <= 0)
		return;
	
	QTextCursor cursor = textCursor();
	if (cursor.isNull())
		return;
	
	if (!cursor.hasSelection())
		cursor.select(QTextCursor::WordUnderCursor);
	
	if (cursor.charFormat().property(QTextFormat::FontPointSize).toInt() == size)
		return;
	
	QTextCharFormat format;
	format.setFontPointSize(size);
	mergeFormatOnWordOrSelection(format);
	emit fontSizeChanged();
}

QString DocumentHandler::fileName() const
{
	const QString filePath = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
	const QString fileName = QFileInfo(filePath).fileName();
	if (fileName.isEmpty())
		return QStringLiteral("untitled.txt");
	return fileName;
}

QString DocumentHandler::fileType() const
{
	return QFileInfo(fileName()).suffix();
}

QUrl DocumentHandler::fileUrl() const
{
	return m_fileUrl;
}

void DocumentHandler::load(const QUrl &fileUrl)
{	
	qDebug()<< "TRYING TO LOAD FILE << " << fileUrl;
	if (fileUrl == m_fileUrl)
		return;
	
	QQmlEngine *engine = qmlEngine(this);
	if (!engine) 
	{
		qWarning() << "load() called before DocumentHandler has QQmlEngine";
		return;
	}
	
	const QUrl path = QQmlFileSelector::get(engine)->selector()->select(fileUrl);
	const QString fileName = QQmlFile::urlToLocalFileOrQrc(path);
	
	m_fileUrl = fileUrl;
	emit fileUrlChanged();
	
	this->m_watcher->addPath(m_fileUrl.toLocalFile());
	
	emit this->loadFile(m_fileUrl);
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
	QTextDocument *doc = this->textDocument();
	if (!doc)
		return;
	
	const QString filePath = fileUrl.toLocalFile();
	const bool isHtml = QFileInfo(filePath).suffix().contains(QLatin1String("html"));
	
	this->m_internallyModified = true;
	
	QFile file(filePath);
	if (!file.open(QFile::WriteOnly | QFile::Truncate | (isHtml ? QFile::NotOpen : QFile::Text)))
	{
		emit error(tr("Cannot save: ") + file.errorString());
		this->m_alerts->append(this->canNotSaveAlert(file.errorString()));
	}else 
	{
		QTextStream out(&file);
		out.setCodec("UTF-8");
		out << (isHtml ? doc->toHtml() : doc->toPlainText()).toUtf8();
		
		file.close();
		
		if (fileUrl == m_fileUrl)
			return;
		
		m_fileUrl = fileUrl;
		emit fileUrlChanged();
		
		doc->setModified(false);
	}	
}

const QString DocumentHandler::getLanguageNameFromFileName(const QUrl& fileName)
{
	if (!DocumentHandler::m_repository)		
		DocumentHandler::m_repository = new KSyntaxHighlighting::Repository();
	
	return DocumentHandler::m_repository->definitionForFileName(fileName.toString()).name();
}

const QStringList DocumentHandler::getLanguageNameList()
{
	if (!DocumentHandler::m_repository)		
		m_repository = new KSyntaxHighlighting::Repository();
	
	const auto definitions = DocumentHandler::m_repository->definitions();
	return std::accumulate(definitions.constBegin(), definitions.constEnd(), QStringList(), [](QStringList &languages, const auto &definition ) -> QStringList
	{
		languages.append(definition.name());	
		return languages;
	});	
}

void DocumentHandler::reset()
{
	emit fontFamilyChanged();
	emit alignmentChanged();
	emit boldChanged();
	emit italicChanged();
	emit underlineChanged();
	emit fontSizeChanged();
	emit textColorChanged();
}

QTextCursor DocumentHandler::textCursor() const
{
	QTextDocument *doc = textDocument();
	if (!doc)
		return QTextCursor();
	
	QTextCursor cursor = QTextCursor(doc);
	if (m_selectionStart != m_selectionEnd) {
		cursor.setPosition(m_selectionStart);
		cursor.setPosition(m_selectionEnd, QTextCursor::KeepAnchor);
	} else {
		cursor.setPosition(m_cursorPosition);
	}
	return cursor;
}

QTextDocument *DocumentHandler::textDocument() const
{
	if (!m_document)
		return nullptr;
	
	return m_document->textDocument();
}

void DocumentHandler::mergeFormatOnWordOrSelection(const QTextCharFormat &format)
{
	QTextCursor cursor = textCursor();
	if (!cursor.hasSelection())
		cursor.select(QTextCursor::WordUnderCursor);
	cursor.mergeCharFormat(format);
}
