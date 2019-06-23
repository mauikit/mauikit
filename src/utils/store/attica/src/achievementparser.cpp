/*
    This file is part of KDE.

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

#include "achievementparser.h"
#include "atticautils.h"

using namespace Attica;

Achievement Achievement::Parser::parseXml(QXmlStreamReader &xml)
{
    Achievement achievement;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("id")) {
                achievement.setId(xml.readElementText());
            } else if (xml.name() == QLatin1String("content_id")) {
                achievement.setContentId(xml.readElementText());
            } else if (xml.name() == QLatin1String("name")) {
                achievement.setName(xml.readElementText());
            } else if (xml.name() == QLatin1String("description")) {
                achievement.setDescription(xml.readElementText());
            } else if (xml.name() == QLatin1String("explanation")) {
                achievement.setExplanation(xml.readElementText());
            } else if (xml.name() == QLatin1String("points")) {
                achievement.setPoints(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("image")) {
                achievement.setImage(QUrl(xml.readElementText()));
            } else if (xml.name() == QLatin1String("dependencies")) {
                QStringList dependencies = parseXmlDependencies(xml);
                achievement.setDependencies(dependencies);
            } else if (xml.name() == QLatin1String("visibility")) {
                achievement.setVisibility(Achievement::stringToAchievementVisibility(xml.readElementText()));
            } else if (xml.name() == QLatin1String("type")) {
                achievement.setType(Achievement::stringToAchievementType(xml.readElementText()));
            } else if (xml.name() == QLatin1String("options")) {
                QStringList options = parseXmlOptions(xml);
                achievement.setOptions(options);
            } else if (xml.name() == QLatin1String("steps")) {
                achievement.setSteps(xml.readElementText().toInt());
            } else if (xml.name() == QLatin1String("progress")) {
                switch (achievement.type()) {
                case Achievement::FlowingAchievement:
                    achievement.setProgress(QVariant(xml.readElementText().toFloat()));
                    break;
                case Achievement::SteppedAchievement:
                    achievement.setProgress(QVariant(xml.readElementText().toInt()));
                    break;
                case Achievement::NamedstepsAchievement:
                    achievement.setProgress(QVariant(xml.readElementText()));
                    break;
                case Achievement::SetAchievement: {
                    QVariant progress = parseXmlProgress(xml);
                    achievement.setProgress(progress);
                }
                break;
                default:
                    break;
                }
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("achievement")) {
            break;
        }
    }

    return achievement;
}

QStringList Achievement::Parser::parseXmlDependencies(QXmlStreamReader &xml)
{
    QStringList dependencies;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("achievement_id")) {
                dependencies.append(xml.readElementText());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("dependencies")) {
            break;
        }
    }

    return dependencies;
}

QStringList Achievement::Parser::parseXmlOptions(QXmlStreamReader &xml)
{
    QStringList options;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("option")) {
                options.append(xml.readElementText());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("options")) {
            break;
        }
    }

    return options;
}

QVariant Achievement::Parser::parseXmlProgress(QXmlStreamReader &xml)
{
    QStringList progress;

    while (!xml.atEnd()) {
        xml.readNext();

        if (xml.isStartElement()) {
            if (xml.name() == QLatin1String("reached")) {
                progress.append(xml.readElementText());
            }
        } else if (xml.isEndElement() && xml.name() == QLatin1String("progress")) {
            break;
        }
    }

    return progress;
}

QStringList Achievement::Parser::xmlElement() const
{
    return QStringList(QLatin1String("achievement"));
}
