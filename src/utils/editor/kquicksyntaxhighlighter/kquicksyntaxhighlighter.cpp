/********************************************************************
Copyright 2018  Eike Hein <hein@kde.org>

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
*********************************************************************/

#include "kquicksyntaxhighlighter.h"

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

#include <QQuickTextDocument>
#include <QTextDocument>

int KQuickSyntaxHighlighter::m_instanceCount = 0;
KSyntaxHighlighting::Repository *KQuickSyntaxHighlighter::m_repository = nullptr;

KQuickSyntaxHighlighter::KQuickSyntaxHighlighter(QObject *parent) : QObject(parent)
    , m_textEdit(nullptr)
    , m_highlighter(new KSyntaxHighlighting::SyntaxHighlighter(this))
{
    ++m_instanceCount;
}

KQuickSyntaxHighlighter::~KQuickSyntaxHighlighter()
{
    --m_instanceCount;

    if (!m_instanceCount) {
        delete m_repository;
        m_repository = nullptr;
    }
}

QObject *KQuickSyntaxHighlighter::textEdit() const
{
    return m_textEdit;
}

void KQuickSyntaxHighlighter::setTextEdit(QObject *textEdit)
{
    if (m_textEdit != textEdit) {
        m_textEdit = textEdit;
        m_highlighter->setDocument(m_textEdit->property("textDocument").value<QQuickTextDocument *>()->textDocument());
    }
}

QString KQuickSyntaxHighlighter::formatName() const
{
    return m_formatName;
}

void KQuickSyntaxHighlighter::setFormatName(const QString &formatName)
{
    if (m_formatName != formatName) {
        m_formatName = formatName;

        if (!m_repository) {
            m_repository = new KSyntaxHighlighting::Repository();
        }

        m_highlighter->setTheme(m_repository->defaultTheme(KSyntaxHighlighting::Repository::LightTheme));

        m_highlighter->setDefinition(m_repository->definitionForName(m_formatName));
    }
}
