// SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "accountmanager.h"
#include "post.h"
#include <QAbstractListModel>
#include <qabstractitemmodel.h>

class AbstractAccount;
class PostEditorBackend;

class AbstractTimelineModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
public:
    enum CustoRoles {
        IdRole = Qt::UserRole + 1,
        OriginalIdRole,
        UrlRole,
        ContentRole,
        SpoilerTextRole,
        AuthorIdentityRole,
        PublishedAtRole,
        RelativeTimeRole,
        AbsoluteTimeRole,
        SensitiveRole,
        VisibilityRole,

        // Additional content
        AttachmentsRole,
        CardRole,
        ApplicationRole,
        PollRole,
        MentionsRole,

        // Reblog
        IsBoostedRole,
        BoostAuthorIdentityRole,

        // Interaction count
        ReblogsCountRole,
        RepliesCountRole,
        FavouritesCountRole,

        // User self interaction
        FavouritedRole,
        RebloggedRole,
        MutedRole,
        BookmarkedRole,
        PinnedRole,

        // Notification
        NotificationActorIdentityRole,
        TypeRole,

        SelectedRole,
        FiltersRole,

        PostRole,

        ExtraRole, ///< for sub-classes to extend the roles
    };

    AbstractTimelineModel(QObject *parent = nullptr);
    QHash<int, QByteArray> roleNames() const override;
    QVariant postData(Post *post, int role) const;

    bool loading() const;
    void setLoading(bool loading);

    void actionFavorite(const QModelIndex &index, Post *post);
    void actionRepeat(const QModelIndex &index, Post *post);
    void actionRedraft(const QModelIndex &index, Post *post, bool isEdit);
    void actionDelete(const QModelIndex &index, Post *post);

Q_SIGNALS:
    void loadingChanged();
    void postSourceReady(PostEditorBackend *backend, bool isEdit);

protected:
    AbstractAccount *m_account = nullptr;
    bool m_loading = false;
};
