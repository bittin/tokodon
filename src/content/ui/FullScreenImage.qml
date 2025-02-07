// SPDX-FileCopyrightText: 2019 Black Hat <bhat@encom.eu.org>
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import Qt.labs.qmlmodels 1.0
import QtMultimedia 5.15

import org.kde.kirigami 2.15 as Kirigami
import org.kde.kmasto 1.0

QQC2.Popup {
    id: root

    required property var model
    property alias currentIndex: view.currentIndex

    property int imageWidth: -1
    property int imageHeight: -1

    width: parent.width
    height: parent.height

    parent: QQC2.Overlay.overlay
    closePolicy: QQC2.Popup.CloseOnEscape
    modal: true
    padding: 0
    background: null

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        QQC2.Control {
            Layout.fillWidth: true

            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Kirigami.ActionToolBar {
                    Layout.fillWidth: true
                    alignment: Qt.AlignRight
                    actions: [
                        Kirigami.Action {
                            text: i18n("Zoom in")
                            icon.name: "zoom-in"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: {
                                view.currentItem.scaleFactor = view.currentItem.scaleFactor + 0.25
                                if (view.currentItem.scaleFactor > 3) {
                                    view.currentItem.scaleFactor = 3
                                }
                            }
                        },
                        Kirigami.Action {
                            text: i18n("Zoom out")
                            icon.name: "zoom-out"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: {
                                view.currentItem.scaleFactor = view.currentItem.scaleFactor - 0.25
                                if (view.currentItem.scaleFactor < 0.25) {
                                    view.currentItem.scaleFactor = 0.25
                                }
                            }
                        },
                        Kirigami.Action {
                            text: i18n("Rotate left")
                            icon.name: "image-rotate-left-symbolic"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: view.currentItem.rotationAngle = view.currentItem.rotationAngle - 90
                            enabled: root.model[root.currentIndex].attachmentType === Attachment.Image
                        },
                        Kirigami.Action {
                            text: i18n("Rotate right")
                            icon.name: "image-rotate-right-symbolic"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: view.currentItem.rotationAngle = view.currentItem.rotationAngle + 90
                            enabled: root.model[root.currentIndex].attachmentType === Attachment.Image
                        },
                        Kirigami.Action {
                            text: i18n("Save as")
                            icon.name: "document-save"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: {
                                const dialog = saveAsDialog.createObject(QQC2.ApplicationWindow.overlay, {
                                    url: view.currentItem.image.source,
                                })
                                dialog.open();
                                dialog.currentFile = dialog.folder + "/" + FileHelper.fileName(view.currentItem.image.source);
                            }
                        },
                        Kirigami.Action {
                            text: i18n("Close")
                            icon.name: "dialog-close"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: root.close()
                        }
                    ]
                }
            }

            background: Rectangle {
                color: Kirigami.Theme.alternateBackgroundColor
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
            }
        }

        component StandardImageAnimation: NumberAnimation {
            duration: Kirigami.Units.longDuration; easing.type: Easing.InOutCubic
        }

        component StandardRotation: Rotation {
            required property var item
            required property var container

            origin {
                x: item.width / 2
                y: item.height / 2
            }

            angle: container.rotationAngle

            Behavior on angle {
                StandardImageAnimation {}
            }
        }

        component StandardScale: Scale {
            required property var item
            required property var container

            origin {
                x: item.width / 2
                y: item.height / 2
            }

            xScale: container.scaleFactor
            yScale: container.scaleFactor

            Behavior on xScale {
                StandardImageAnimation {}
            }
            Behavior on yScale {
                StandardImageAnimation {}
            }
        }

        ListView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            focus: true
            keyNavigationEnabled: true
            keyNavigationWraps: true
            model: root.model
            orientation: ListView.Horizontal
            clip: true
            delegate: DelegateChooser {
                role: "attachmentType"
                DelegateChoice {
                    roleValue: Attachment.Image

                    Item {
                        id: imageContainer
                        width: ListView.view.width
                        height: ListView.view.height

                        required property var modelData

                        property alias image: imageItem

                        property var scaleFactor: 1
                        property int rotationAngle: 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.close()
                        }

                        Image {
                            id: imageItem

                            property var rotationInsensitiveWidth: Math.min(modelData.originalWidth, imageContainer.width - Kirigami.Units.largeSpacing * 2)
                            property var rotationInsensitiveHeight: Math.min(modelData.originalHeight, imageContainer.height - Kirigami.Units.largeSpacing * 2)

                            anchors.centerIn: parent
                            width: rotationAngle % 180 === 0 ? rotationInsensitiveWidth : rotationInsensitiveHeight
                            height: rotationAngle % 180 === 0 ? rotationInsensitiveHeight : rotationInsensitiveWidth
                            fillMode: Image.PreserveAspectFit
                            clip: true
                            source: modelData.url

                            MouseArea {
                                anchors.centerIn: parent
                                width: parent.paintedWidth
                                height: parent.paintedHeight
                            }

                            Behavior on width {
                                StandardImageAnimation {}
                            }
                            Behavior on height {
                                StandardImageAnimation {}
                            }

                            Image {
                                anchors.centerIn: parent
                                width: imageItem.width
                                height: imageItem.height
                                source: modelData.blurhash !== "" ? ("image://blurhash/" + modelData.blurhash) : ""
                                visible: parent.status !== Image.Ready
                            }

                            transform: [
                                StandardRotation {
                                    item: image
                                    container: imageContainer
                                },
                                StandardScale {
                                    item: image
                                    container: imageContainer
                                }
                            ]
                        }
                    }
                }

                DelegateChoice {
                    roleValue: Attachment.GifV

                    Item {
                        id: videoContainer
                        width: ListView.view.width
                        height: ListView.view.height

                        required property var modelData

                        property alias video: videoItem

                        property var scaleFactor: 1
                        property int rotationAngle: 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.close()
                        }

                        Video {
                            id: videoItem

                            anchors.centerIn: parent
                            width: videoContainer.width
                            height: videoContainer.height
                            clip: true
                            source: modelData.url
                            autoPlay: true
                            loops: MediaPlayer.Infinite
                            flushMode: VideoOutput.FirstFrame

                            MouseArea {
                                anchors.centerIn: parent
                                width: parent.paintedWidth
                                height: parent.paintedHeight
                            }

                            Behavior on width {
                                StandardImageAnimation {}
                            }
                            Behavior on height {
                                StandardImageAnimation {}
                            }

                            Image {
                                anchors.centerIn: parent
                                width: videoItem.width
                                height: videoItem.height
                                source: modelData.blurhash !== "" ? ("image://blurhash/" + modelData.blurhash) : ""
                                visible: parent.status === MediaPlayer.Loading
                            }

                            transform: [
                                StandardScale {
                                    item: video
                                    container: videoContainer
                                }
                            ]
                        }
                    }
                }
            }

            QQC2.RoundButton {
                anchors {
                    left: parent.left
                    leftMargin: Kirigami.Units.largeSpacing
                    verticalCenter: parent.verticalCenter
                }
                width: Kirigami.Units.gridUnit * 2
                height: width
                icon.name: "arrow-left"
                visible: !Kirigami.Settings.isMobile && view.currentIndex > 0
                Keys.forwardTo: view
                Accessible.name: i18n("Previous image")
                onClicked: view.currentIndex -= 1
            }

            QQC2.RoundButton {
                anchors {
                    right: parent.right
                    rightMargin: Kirigami.Units.largeSpacing
                    verticalCenter: parent.verticalCenter
                }
                width: Kirigami.Units.gridUnit * 2
                height: width
                icon.name: "arrow-right"
                visible: !Kirigami.Settings.isMobile && view.currentIndex < view.count - 1
                Keys.forwardTo: view
                Accessible.name: i18n("Next image")
                onClicked: view.currentIndex += 1
            }
        }

        QQC2.Control {
            Layout.fillWidth: true
            visible: root.model[view.currentIndex].description

            contentItem: QQC2.Label {
                Layout.leftMargin: Kirigami.Units.largeSpacing
                wrapMode: Text.WordWrap

                text: root.model[view.currentIndex].description

                font.weight: Font.Bold
            }

            background: Rectangle {
                color: Kirigami.Theme.alternateBackgroundColor
            }

            Kirigami.Separator {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.top
                }
                height: 1
            }
        }
    }

    Component {
        id: saveAsDialog
        FileDialog {
            property var url
            fileMode: FileDialog.SaveFile
            folder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
            onAccepted: {
                if (!currentFile) {
                    return;
                }
                console.log(url, currentFile, AccountManager.selectedAccount)
                FileHelper.downloadFile(AccountManager.selectedAccount, url, currentFile)
            }
        }
    }

    onClosed: {
        applicationWindow().isShowingFullScreenImage = false;
        view.currentItem.scaleFactor = 1;
        view.currentItem.rotationAngle = 0;
    }

    onOpened: {
        applicationWindow().isShowingFullScreenImage = true;
    }
}
