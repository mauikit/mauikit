#include "syntaxhighlighterutil.h"

#include <QDebug>
#include <QVector>
#include <KSyntaxHighlighting/Repository>
#include <KSyntaxHighlighting/Definition>

SyntaxHighlighterUtil::SyntaxHighlighterUtil()
{
    repo = new KSyntaxHighlighting::Repository();
}

QList<QString> SyntaxHighlighterUtil::getLanguageNameList()
{
    QList<QString> languages;

    for (KSyntaxHighlighting::Definition def : repo->definitions()) {
        languages.append(def.name());
    }

    return languages;
}

QString SyntaxHighlighterUtil::getLanguageNameFromFileName(QString fileName)
{
    return repo->definitionForFileName(fileName).name();
}
