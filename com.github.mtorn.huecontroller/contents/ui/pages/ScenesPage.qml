/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * ScenesPage.qml - List of scenes with apply controls.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "../components"

Item {
    id: scenesPage
    property var hueApi
    property var scenesModel
    property var roomsModel  // Passed to filter compatible rooms per scene

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            visible: scenesListView.count === 0
            text: "No scenes found.\nCreate scenes in the Hue app."
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: 0.6
        }

        Item {
            id: scenesListWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: scenesListView
                anchors.fill: parent
                anchors.rightMargin: (scenesScrollBar.size < 1 ? (scenesScrollBar.implicitWidth + Kirigami.Units.smallSpacing) : 0)
                model: scenesModel
                spacing: Kirigami.Units.smallSpacing
                clip: true

                ScrollBar.vertical: ScrollBar {
                    id: scenesScrollBar
                    parent: scenesListView.parent
                    anchors.top: scenesListView.top
                    anchors.bottom: scenesListView.bottom
                    anchors.left: scenesListView.right
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    policy: ScrollBar.AsNeeded
                }

                delegate: SceneControl {
                    width: scenesListView.width

                    sceneId: model.id || ""
                    sceneName: model.name || "Unknown Scene"
                    sceneLights: model.lights || []
                    hueApi: scenesPage.hueApi
                    roomsModel: scenesPage.roomsModel

                    onApplyToRoom: (roomId) => {
                        hueApi.recallScene(roomId, sceneId)
                    }
                }
            }
        }
    }
}
