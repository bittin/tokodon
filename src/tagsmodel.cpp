// SPDX-FileCopyrightText: 2022 Carl Schwan <carlschwan@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "tagsmodel.h"
#include "abstractaccount.h"
#include <QUrlQuery>

TagsModel::TagsModel(QObject *parent)
    : TimelineModel(parent)
{
    init();
}

TagsModel::~TagsModel() = default;

QString TagsModel::hashtag() const
{
    return m_hashtag;
}

void TagsModel::setHashtag(const QString &hashtag)
{
    if (hashtag == m_hashtag) {
        return;
    }
    m_hashtag = hashtag;
    Q_EMIT hashtagChanged();
    fillTimeline({});
}

QString TagsModel::displayName() const
{
    return QLatin1Char('#') + m_hashtag;
}

void TagsModel::fillTimeline(const QString &fromId)
{
    if (m_hashtag.isEmpty()) {
        return;
    }
    QUrlQuery q;
    if (!fromId.isEmpty()) {
        q.addQueryItem("max_id", fromId);
    }
    auto uri = m_account->apiUrl(QString("/api/v1/timelines/tag/%1").arg(m_hashtag));
    uri.setQuery(q);
    const auto account = m_account;
    const auto hashtag = m_hashtag;

    auto handleError = [this](QNetworkReply *reply) {
        Q_UNUSED(reply);
        setLoading(false);
    };

    m_account->get(
        uri,
        true,
        this,
        [this, account, hashtag, uri](QNetworkReply *reply) {
            if (account != m_account || m_hashtag != hashtag) {
                // Receiving request for an old query
                setLoading(false);
                return;
            }

            fetchedTimeline(reply->readAll());
        },
        handleError);
}
