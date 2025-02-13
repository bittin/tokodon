// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.14 as Kirigami
import org.kde.kmasto 1.0
import Qt.labs.platform 1.1
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm
import QtGraphicalEffects 1.0

Kirigami.ScrollablePage {
    id: root

    property var account

    readonly property ProfileEditorBackend backend : ProfileEditorBackend {
        account: root.account
        onSendNotification: applicationWindow().showPassiveNotification(message)
    }

    title: i18n("Profile Editor")
    leftPadding: 0
    rightPadding: 0

    Component {
        id: openFileDialog
        FileDialog {
            signal chosen(string path)
            title: i18n("Please choose a file")
            folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
            onAccepted: chosen(file)
        }
    }

    ColumnLayout {
        MobileForm.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            contentItem: ColumnLayout {
                spacing: 0

                Rectangle {
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 9
                    Layout.fillWidth: true
                    clip: true
                    color: Kirigami.Theme.backgroundColor
                    Kirigami.Theme.colorSet: Kirigami.Theme.View

                    Image {
                        anchors.centerIn: parent
                        source: backend.backgroundUrl
                        fillMode: Image.PreserveAspectFit
                        visible: backend.backgroundUrl
                    }

                    QQC2.Pane {
                        id: pane
                        background: Item {
                            // Background image
                            Image {
                                id: bg
                                width: pane.width
                                height: pane.height
                                source: backend.backgroundUrl
                            }

                            FastBlur {
                                id: blur
                                source: bg
                                radius: 48
                                width: pane.width
                                height: pane.height
                            }
                            ColorOverlay {
                                width: pane.width
                                height: pane.height
                                source: blur
                                color: "#66808080"
                            }
                            Rectangle {
                                id: strip
                                color: "#66F0F0F0"
                                anchors.bottom: parent.bottom;
                                height: 2 * Kirigami.Units.gridUnit
                                width: parent.width
                                visible: children.length > 0
                            }
                        }
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        contentItem: RowLayout {
                            implicitHeight: Kirigami.Units.gridUnit * 5
                            Kirigami.Avatar {
                                source: backend.avatarUrl
                            }

                            Column {
                                Layout.fillWidth: true
                                Kirigami.Heading {
                                    level: 5
                                    text: backend.displayName
                                    type: Kirigami.Heading.Primary
                                }
                                QQC2.Label {
                                    text: '@' + account.username + '@' + account.instanceName
                                }
                            }
                        }
                    }
                }

                MobileForm.FormTextFieldDelegate {
                    label: i18n("Display Name")
                    text: backend.displayName
                    onTextChanged: backend.displayName = text
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.AbstractFormDelegate {
                    background: Item {}
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        QQC2.Label {
                            text: i18n("Bio")
                            Layout.fillWidth: true
                        }
                        QQC2.TextArea {
                            id: bioField
                            Layout.fillWidth: true
                            text: backend.note
                            onTextChanged: backend.note = text
                        }
                    }
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.AbstractFormDelegate {
                    background: Item {}
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        QQC2.Label {
                            text: i18n("Header")
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            QQC2.RoundButton {
                                id: headerUpload
                                icon.name: 'download'
                                property var fileDialog: null;
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    if (fileDialog !== null) {
                                        return;
                                    }

                                    fileDialog = openFileDialog.createObject(QQC2.ApplicationWindow.Overlay)

                                    fileDialog.chosen.connect(function(receivedSource) {
                                        headerUpload.fileDialog = null;
                                        if (!receivedSource) {
                                            return;
                                        }
                                        backend.backgroundUrl = receivedSource;
                                    });
                                    fileDialog.onRejected.connect(function() {
                                        headerUpload.fileDialog = null;
                                    });
                                    fileDialog.open();
                                }
                            }
                            QQC2.Label {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillWidth: true
                                text: i18n("PNG, GIF or JPG. At most 2 MB. Will be downscaled to 1500x500px")
                                wrapMode: Text.WordWrap
                            }
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            color: Kirigami.Theme.negativeTextColor
                            text: backend.backgroundUrlError
                            wrapMode: Text.WordWrap
                        }

                        Kirigami.LinkButton {
                            text: i18n("Delete")
                            color: Kirigami.Theme.negativeTextColor
                            Layout.bottomMargin: Kirigami.Units.largeSpacing
                            onClicked: backend.backgroundUrl = ''
                        }
                    }
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.AbstractFormDelegate {
                    background: Item {}
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        QQC2.Label {
                            text: i18n("Avatar")
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            QQC2.RoundButton {
                                id: avatarUpload
                                icon.name: 'download'
                                property var fileDialog: null;
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    if (fileDialog !== null) {
                                        return;
                                    }

                                    fileDialog = openFileDialog.createObject(QQC2.ApplicationWindow.Overlay)

                                    fileDialog.chosen.connect(function(receivedSource) {
                                        avatarUpload.fileDialog = null;
                                        if (!receivedSource) {
                                            return;
                                        }
                                        backend.avatarUrl = receivedSource;
                                    });
                                    fileDialog.onRejected.connect(function() {
                                        avatarUpload.fileDialog = null;
                                    });
                                    fileDialog.open();
                                }
                            }
                            QQC2.Label {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillWidth: true
                                text: i18n('PNG, GIF or JPG. At most 2 MB. Will be downscaled to 400x400px')
                                wrapMode: Text.WordWrap
                            }
                        }

                        QQC2.Label {
                            visible: text.length > 0
                            Layout.fillWidth: true
                            text: backend.avatarUrlError
                            wrapMode: Text.WordWrap
                            color: Kirigami.Theme.negativeTextColor
                        }

                        Kirigami.LinkButton {
                            text: i18n("Delete")
                            Layout.bottomMargin: Kirigami.Units.largeSpacing
                            color: Kirigami.Theme.negativeTextColor
                            onClicked: backend.avatarUrl = ''
                        }
                    }
                }
            }
        }

        MobileForm.FormCard {
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            contentItem: ColumnLayout {
                spacing: 0

                MobileForm.FormComboBoxDelegate {
                    id: box
                    text: i18n("Default status privacy")
                    model: [
                        {
                            "display": i18n("Public post"),
                            "value": "public"
                        },
                        {
                            "display": i18n("Unlisted post"),
                            "value": "unlisted"
                        },
                        {
                            "display": i18n("Followers-only post"),
                            "value": "private"
                        },
                        {
                            "display": i18n("Direct post"),
                            "value": "direct"
                        },
                    ]
                    textRole: "display"
                    valueRole: "value"
                    Component.onCompleted: box.currentIndex = box.indexOfValue(backend.privacy)
                    Connections {
                        target: backend
                        function onPrivacyChanged() {
                            box.currentIndex = box.indexOfValue(backend.privacy)
                        }
                    }
                    onCurrentIndexChanged: backend.privacy = model[currentIndex].value
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormCheckDelegate {
                    text: i18n("Mark by default content as sensitive")
                    checked: backend.sensitive
                    onCheckedChanged: backend.sensitive = checked
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormCheckDelegate {
                    text: i18n("Require follow requests")
                    checked: backend.locked
                    onCheckedChanged: backend.locked = checked
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormCheckDelegate {
                    text: i18n("This is a bot account")
                    checked: backend.bot
                    onCheckedChanged: backend.bot = checked
                }

                MobileForm.FormDelegateSeparator {}

                MobileForm.FormCheckDelegate {
                    text: i18n("Suggest account to others")
                    checked: backend.discoverable
                    onCheckedChanged: backend.discoverable = checked
                }
            }
        }
    }

    footer: QQC2.ToolBar {
        height: visible ? implicitHeight : 0
        contentItem: RowLayout {
            Item {
                Layout.fillWidth: true
            }

            QQC2.Button {
                text: i18n("Reset")
                icon.name: 'edit-reset'
                Layout.margins: Kirigami.Units.smallSpacing
                onClicked: backend.fetchAccountInfo()
            }

            QQC2.Button {
                text: i18n("Apply")
                icon.name: 'dialog-ok'
                enabled: backend.backgroundUrlError.length === 0 && backend.avatarUrlError.length === 0
                Layout.margins: Kirigami.Units.smallSpacing
                onClicked: backend.save()
            }
        }
    }
}
