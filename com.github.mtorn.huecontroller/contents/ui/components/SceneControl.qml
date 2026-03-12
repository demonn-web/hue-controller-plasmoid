/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * SceneControl.qml - Card for a scene with room selector and apply button.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: sceneControl
    property string sceneId: ""
    property string sceneName: "Scene"
    property var sceneLights: []
    property var hueApi: null
    property var roomsModel: null
    signal applyToRoom(string roomId)

    implicitHeight: contentLayout.implicitHeight + Kirigami.Units.smallSpacing * 2

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.disabledTextColor
        border.width: 1
        opacity: 0.3
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "view-pim-tasks"
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            PlasmaComponents.Label {
                text: sceneControl.sceneName
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                text: (sceneLights ? sceneLights.length : 0) + " lights"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.7
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.ComboBox {
                id: roomSelector
                Layout.fillWidth: true
                model: compatibleRooms
                textRole: "name"
                visible: compatibleRooms.length > 0
            }

            PlasmaComponents.Button {
                text: "Apply"
                enabled: compatibleRooms.length > 0
                onClicked: {
                    var selectedRoom = compatibleRooms[roomSelector.currentIndex]
                    if (selectedRoom) {
                        sceneControl.applyToRoom(selectedRoom.id)
                    }
                }
            }
        }

        PlasmaComponents.Label {
            text: "No compatible rooms found."
            visible: compatibleRooms.length === 0
            opacity: 0.6
            Layout.fillWidth: true
        }
    }

    // Helper to filter compatible rooms (subset matching: all scene lights exist in room).
    property var compatibleRooms: {
        if (!roomsModel || !sceneLights) return []
            var compatible = []
            for (var i = 0; i < roomsModel.count; i++) {
                var room = roomsModel.get(i)
                var allMatch = true
                for (var j = 0; j < sceneLights.length; j++) {
                    if (!room.lights.includes(sceneLights[j])) {
                        allMatch = false
                        break
                    }
                }
                if (allMatch) {
                    compatible.push(room)
                }
            }
            return compatible
    }
}
