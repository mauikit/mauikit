#include "syntaxhighlighterutil.h"

#include <QDebug>
#include <QVector>

#ifdef STATIC_MAUIKIT
#include "KSyntaxHighlighting/KSyntaxHighlighting/Repository"
#include "KSyntaxHighlighting/KSyntaxHighlighting/Definition"
#else
#include <KSyntaxHighlighting/Repository>
#include <KSyntaxHighlighting/Definition>
#endif

SyntaxHighlighterUtil::SyntaxHighlighterUtil()
{
    repo = new KSyntaxHighlighting::Repository();
}

QStringList SyntaxHighlighterUtil::getLanguageNameList()
{
	QStringList languages;

    for (KSyntaxHighlighting::Definition def : repo->definitions())
	{
        languages.append(def.name());
    }

    return languages;
}

QString SyntaxHighlighterUtil::getLanguageNameFromFileName(QString fileName)
{
    return repo->definitionForFileName(fileName).name();
}
