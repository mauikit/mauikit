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

#ifndef DOCUMENTHANDLER_H
#define DOCUMENTHANDLER_H

#include <QFont>
#include <QObject>
#include <QTextCursor>
#include <QUrl>
#include <QThread>
#include <QAbstractListModel>
#include <QDebug>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

QT_BEGIN_NAMESPACE
class QFileSystemWatcher;
class QTextDocument;
class QQuickTextDocument;
QT_END_NAMESPACE

namespace KSyntaxHighlighting 
{
	class Repository;
	class SyntaxHighlighter;
}

struct AlertAction
{
	QString label;
	std::function<void ()> action;
} ;

class DocumentAlert : public QObject
{	
	Q_OBJECT	
	Q_PROPERTY(QString title MEMBER m_title CONSTANT FINAL)
	Q_PROPERTY(QString body MEMBER m_body CONSTANT FINAL)	
	Q_PROPERTY(uint level MEMBER m_level CONSTANT FINAL)	
	
public:	
	enum LEVEL : uint
	{
		INFO_LEVEL = 0,		
		WARNING_LEVEL = 1,
		DANGER_LEVEL = 2
	};
	
	DocumentAlert(const QString &title, const QString &body, const uint &level, const int &id, QObject *parent = nullptr) : QObject(parent)
	{
		this->m_title = title;
		this->m_body = body;
		this->m_level = level;	
		this->m_id = id;
	}
	
	void setIndex(const int &index)
	{
		this->m_index = index;
	}
	
	void setActions(QVector<AlertAction> actions)
	{
		this->m_actions = actions;
	}
	
	int getId() const
	{
		return this->m_id;
	}	

    friend bool operator==(const DocumentAlert &other, const DocumentAlert &other2)
    {
        return other.getId()== other2.getId();
    }

private: 
	QString m_title;
	QString m_body;
	uint m_level;
	int m_index = -1;	
	int m_id = -1;
	
	QVector<AlertAction> m_actions;
	
public slots:
	QStringList actionLabels() const
	{
		return std::accumulate(this->m_actions.constBegin(), this->m_actions.constEnd(), QStringList(), [](QStringList &labels, const AlertAction &action) -> QStringList
		{
			labels << action.label;
			return labels;
		});	
	}
	
	void triggerAction(const int &actionIndex, const int &alertIndex)
	{
		qDebug()<< "TRIGGERING DOCUMENT ACTION AT INDEX << " << actionIndex << alertIndex;
		this->m_actions.at(actionIndex).action();		
		emit this->done(alertIndex);
	}
	
signals:
	void done(int index);
};

class Alerts : public QAbstractListModel
{
	Q_OBJECT
	
public:
	enum ROLES : uint
	{
		ALERT = Qt::DisplayRole + 1
	};
	
	enum ALERT_TYPES : uint 
	{
		MISSING,
		UNSAVED,
		MODIFIED,
		SAVE_ERROR
	};	
	
	explicit Alerts(QObject *parent = nullptr); 
	~Alerts();
	QVariant data(const QModelIndex & index, int role) const override final;
	int rowCount(const QModelIndex &parent = QModelIndex()) const override final;	
	QHash<int, QByteArray> roleNames() const override;
	
	void append(DocumentAlert *alert);

private:
	QVector<DocumentAlert*> m_alerts;	
    bool contains(DocumentAlert * const alert);
}; 

class FileLoader : public QObject
{
	Q_OBJECT
	
public slots:
	void loadFile(const QUrl &url);
	
signals:
	void fileReady(QString array, QUrl url);
};

#ifdef STATIC_MAUIKIT
class DocumentHandler : public QObject
#else
class MAUIKIT_EXPORT DocumentHandler : public QObject
#endif
{
	Q_OBJECT
	
	Q_PROPERTY(QQuickTextDocument *document READ document WRITE setDocument NOTIFY documentChanged)
	Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
	Q_PROPERTY(int selectionStart READ selectionStart WRITE setSelectionStart NOTIFY selectionStartChanged)
	Q_PROPERTY(int selectionEnd READ selectionEnd WRITE setSelectionEnd NOTIFY selectionEndChanged)
	
	Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY textColorChanged)
	Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
	Q_PROPERTY(Qt::Alignment alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
	
	Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY boldChanged)
	Q_PROPERTY(bool uppercase READ uppercase WRITE setUppercase NOTIFY uppercaseChanged)
	Q_PROPERTY(bool italic READ italic WRITE setItalic NOTIFY italicChanged)
	Q_PROPERTY(bool underline READ underline WRITE setUnderline NOTIFY underlineChanged)
	Q_PROPERTY(bool isRich READ getIsRich NOTIFY isRichChanged)
	
	Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
	
	Q_PROPERTY(QString fileName READ fileName NOTIFY fileUrlChanged)
	Q_PROPERTY(QString fileType READ fileType NOTIFY fileUrlChanged)
	Q_PROPERTY(QUrl fileUrl READ fileUrl WRITE setFileUrl NOTIFY fileUrlChanged)
	
	Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
	
	Q_PROPERTY(bool externallyModified READ getExternallyModified WRITE setExternallyModified NOTIFY externallyModifiedChanged)
	Q_PROPERTY(bool modified READ getModified NOTIFY modifiedChanged)
	Q_PROPERTY(bool autoReload READ getAutoReload WRITE setAutoReload NOTIFY autoReloadChanged)	
	
	Q_PROPERTY(QString formatName READ formatName WRITE setFormatName NOTIFY formatNameChanged)
    
    Q_PROPERTY(int currentLineIndex READ getCurrentLineIndex NOTIFY currentLineIndexChanged)
	
	Q_PROPERTY(Alerts *alerts READ getAlerts CONSTANT FINAL)	
	
	Q_PROPERTY(QColor backgroundColor READ getBackgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)	
    
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)	
    
    Q_PROPERTY(bool enableSyntaxHighlighting READ enableSyntaxHighlighting WRITE setEnableSyntaxHighlighting NOTIFY enableSyntaxHighlightingChanged)	
    
	
public:
	explicit DocumentHandler(QObject *parent = nullptr);
	~DocumentHandler();
	
	QQuickTextDocument *document() const;
	void setDocument(QQuickTextDocument *document);
	
	int cursorPosition() const;
	void setCursorPosition(int position);
	
	int selectionStart() const;
	void setSelectionStart(int position);
	
	int selectionEnd() const;
	void setSelectionEnd(int position);
	
	QString fontFamily() const;
	void setFontFamily(const QString &family);
	
	QColor textColor() const;
	void setTextColor(const QColor &color);
	
	Qt::Alignment alignment() const;
	void setAlignment(Qt::Alignment alignment);
	
	bool bold() const;
	void setBold(bool bold);
	
	bool uppercase() const;
	void setUppercase(bool uppercase);
	
	bool italic() const;
	void setItalic(bool italic);
	
	bool underline() const;
	void setUnderline(bool underline);
	
	bool getIsRich() const;
	
	int fontSize() const;
	void setFontSize(int size);
	
	QString fileName() const;
	QString fileType() const;
	QUrl fileUrl() const;
	void setFileUrl(const QUrl &url);
	
	inline QString text() const { return m_text; }
	void setText(const QString &text);
	
	bool getAutoReload() const;
	void setAutoReload(const bool &value);
	
	bool getModified() const;
		
	bool getExternallyModified() const;
	void setExternallyModified(const bool &value);	
	
	QString formatName() const;
	void setFormatName(const QString &formatName);
	
	QColor getBackgroundColor() const;
	void setBackgroundColor(const QColor &color);	
	
	Alerts *getAlerts() const;
    
    QString theme() const;
    void setTheme(const QString &theme);
    
    bool enableSyntaxHighlighting() const;
    void setEnableSyntaxHighlighting(const bool &value);
	
public slots:
	void load(const QUrl &url);
	void saveAs(const QUrl &url);
    void find(const QString &query);
    int lineHeight(const int &line);
    int getCurrentLineIndex();
	
	static const QStringList getLanguageNameList();
	static const QString getLanguageNameFromFileName(const QUrl &fileName);
    static const QStringList getThemes();
    
signals:
	void documentChanged();
	void cursorPositionChanged();
	void selectionStartChanged();
	void selectionEndChanged();
	
	void fontFamilyChanged();
	void textColorChanged();
	void alignmentChanged();
	
	void boldChanged();
	void uppercaseChanged();
	void italicChanged();
	void underlineChanged();
	void isRichChanged();
	
	void fontSizeChanged();
	
	void textChanged();
	void fileUrlChanged();
	
	void loaded(const QUrl &url);
	void error(const QString &message);
	void loadFile(QUrl url);
	
	void autoReloadChanged();
	void externallyModifiedChanged();
	
	void backgroundColorChanged();
	
	void formatNameChanged() const;
	
	void modifiedChanged();
    
    void currentLineIndexChanged();
    
    void enableSyntaxHighlightingChanged();
    void themeChanged();
			
private:
	void reset();
	void setStyle();	
	
	QTextCursor textCursor() const;
	QTextDocument *textDocument() const;
	void mergeFormatOnWordOrSelection(const QTextCharFormat &format);
	
	QQuickTextDocument *m_document;
	QFileSystemWatcher *m_watcher;
	
	int m_cursorPosition;
	int m_selectionStart;
	int m_selectionEnd;
	
	bool isRich = false;
	
	QFont m_font;
	int m_fontSize;
	QUrl m_fileUrl;
	
	QThread m_worker;	
	QString m_text;

	bool m_autoReload = false;
	bool m_externallyModified = false;
	bool m_internallyModified = false;
	
	QColor m_backgroundColor;
	
	static int m_instanceCount;
	QString m_formatName = "None";
	static KSyntaxHighlighting::Repository *m_repository;
	KSyntaxHighlighting::SyntaxHighlighter *m_highlighter;	
    
    bool m_enableSyntaxHighlighting = false;
    QString m_theme;
	
	Alerts *m_alerts;
	DocumentAlert * missingAlert();
	DocumentAlert * externallyModifiedAlert();	
	DocumentAlert * canNotSaveAlert(const QString &details);	
};

#endif // DOCUMENTHANDLER_H
