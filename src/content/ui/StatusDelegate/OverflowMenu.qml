// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-FileCopyrightText: 2023 Joshua Goins <josh@redstrate.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kmasto 1.0

QQC2.Menu {
    id: root

    required property int index
    required property string postId
    required property string url
    required property bool bookmarked
    required property bool isSelf
    required property bool expandedPost

    QQC2.MenuItem {
        text: i18n("Expand This Post")
        onTriggered: Navigation.openThread(root.postId)
        visible: !root.expandedPost
    }

    QQC2.MenuItem {
        text: i18n("Open Original Page")
        onTriggered: {
            Qt.openUrlExternally(root.url)
        }
    }

    QQC2.MenuItem {
        text: i18n("Copy Link to This Post")
        onTriggered: {
            Clipboard.saveText(root.url)
        }
    }

    QQC2.MenuSeparator {}

    QQC2.MenuItem {
        text: root.bookmarked ? i18n("Remove bookmark") : i18n("Bookmark")
        onTriggered: timelineModel.actionBookmark(timelineModel.index(root.index, 0))
    }

    QQC2.MenuSeparator {
        visible: root.isSelf
    }

    QQC2.MenuItem {
        visible: root.isSelf
        text: i18n("Edit")
        onTriggered: timelineModel.actionRedraft(timelineModel.index(root.index, 0), true)
    }

    QQC2.MenuItem {
        visible: root.isSelf
        text: i18n("Delete")
        onTriggered: timelineModel.actionDelete(timelineModel.index(root.index, 0))
    }

    QQC2.MenuItem {
        visible: root.isSelf
        text: i18n("Delete & Re-draft")
        onTriggered: {
            timelineModel.actionRedraft(timelineModel.index(root.index, 0), false)
            timelineModel.actionDelete(timelineModel.index(root.index, 0))
        }
    }
}
