// SPDX-FileCopyrightText: 2023 Joshua Goins <josh@redstrate.com>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QLocale>
#include <QSortFilterProxyModel>

class RawLanguageModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum CustomRoles { NameRole = Qt::UserRole + 1, CodeRole, PreferredRole };

    explicit RawLanguageModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QString getCode(const int index) const;

private:
    QList<QLocale::Language> m_languages;
    QList<QString> m_iso639codes;
    QList<QString> m_preferredLanguages;
};

class LanguageModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit LanguageModel(QObject *parent = nullptr);

    Q_INVOKABLE QString getCode(const int index) const;

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

private:
    RawLanguageModel *m_model = nullptr;
};