// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include "abstractaccount.h"
#include "post.h"

class Preferences : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Post::Visibility defaultVisibility READ defaultVisibility NOTIFY defaultVisibilityChanged)
    Q_PROPERTY(bool defaultSensitive READ defaultSensitive NOTIFY defaultSensitiveChanged)
    Q_PROPERTY(QString defaultLanguage READ defaultLanguage NOTIFY defaultLanguageChanged)
    Q_PROPERTY(QString extendMedia READ extendMedia NOTIFY extendMediaChanged)
    Q_PROPERTY(bool extendSpoiler READ extendSpoiler NOTIFY extendSpoilerChanged)

public:
    explicit Preferences(AbstractAccount *account);

    Post::Visibility defaultVisibility() const;
    bool defaultSensitive() const;
    QString defaultLanguage() const;
    QString extendMedia() const;
    bool extendSpoiler() const;

Q_SIGNALS:
    void defaultVisibilityChanged();
    void defaultSensitiveChanged();
    void defaultLanguageChanged();
    void extendMediaChanged();
    void extendSpoilerChanged();

private:
    Post::Visibility m_defaultVisibility;
    bool m_defaultSensitive;
    QString m_defaultLanguage;
    QString m_extendMedia;
    bool m_extendSpoiler;
};
