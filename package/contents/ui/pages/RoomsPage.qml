/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * RoomsPage.qml - List of rooms and zones.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "../components"
import "../../code/HueConversions.js" as HueConv

Item {
    id: roomsPage
    property var hueApi
    property var roomsModel
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        PlasmaComponents.Label {
            visible: roomsListView.count === 0
            text: "No rooms found.\nConfigure rooms in the Hue app."
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: 0.6
        }
        Item {
            id: roomsListWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: roomsListView
                anchors.fill: parent
                anchors.rightMargin: (roomsScrollBar.size < 1 ? (roomsScrollBar.implicitWidth + Kirigami.Units.smallSpacing) : 0)
                model: roomsModel
                spacing: Kirigami.Units.smallSpacing
                clip: true
                ScrollBar.vertical: ScrollBar {
                    id: roomsScrollBar
                    parent: roomsListView.parent
                    anchors.top: roomsListView.top
                    anchors.bottom: roomsListView.bottom
                    anchors.left: roomsListView.right
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    policy: ScrollBar.AsNeeded
                }

                delegate: RoomControl {
                    width: roomsListView.width

                    roomId: model.id || ""
                    roomName: model.name || "Unknown Room"
                    isOn: model.on || false
                    brightness: model.brightness || 0
                    lightCount: model.lightCount || 0
                    hueApi: roomsPage.hueApi
                    roomLights: model.lights || []

                    onToggled: (newState) => {
                        hueApi.putGroup(roomId, { "on": newState })
                        // Optimistic update to keep the UI snappy.
                        roomsModel.setProperty(index, "on", newState)
                    }

                    onUserBrightnessChange: (newValue) => {
                        // Bridge expects 0-254 brightness.
                        var briVal = HueConv.percentToBri(newValue)
                        hueApi.putGroup(roomId, { "bri": briVal })
                        // Optimistic update to keep the UI snappy.
                        roomsModel.setProperty(index, "brightness", newValue)
                    }
                }
            }
        }
    }
}
