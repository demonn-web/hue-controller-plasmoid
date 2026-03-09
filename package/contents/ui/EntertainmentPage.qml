/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * EntertainmentPage.qml - List of entertainment areas.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "../components"
import "../../code/HueConversions.js" as HueConv

Item {
    id: entertainmentPage
    property var hueApi
    property var roomsModel  // Reusing roomsModel, but filtering for type "Entertainment"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        PlasmaComponents.Label {
            visible: entertainmentListView.count === 0
            text: "No entertainment areas found.\nConfigure in the Hue app or check bridge connection."
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: 0.6
        }
        Item {
            id: entertainmentListWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: entertainmentListView
                anchors.fill: parent
                anchors.rightMargin: (entertainmentScrollBar.size < 1 ? (entertainmentScrollBar.implicitWidth + Kirigami.Units.smallSpacing) : 0)
                model: entertainmentModel
                spacing: Kirigami.Units.smallSpacing
                clip: true
                ScrollBar.vertical: ScrollBar {
                    id: entertainmentScrollBar
                    parent: entertainmentListView.parent
                    anchors.top: entertainmentListView.top
                    anchors.bottom: entertainmentListView.bottom
                    anchors.left: entertainmentListView.right
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    policy: ScrollBar.AsNeeded
                }

                delegate: RoomControl {  // Reusing RoomControl for simplicity
                    width: entertainmentListView.width

                    roomId: model.id || ""
                    roomName: model.name || "Unknown Area"
                    isOn: model.on || false
                    brightness: model.brightness || 0
                    lightCount: model.lightCount || 0
                    hueApi: entertainmentPage.hueApi
                    roomLights: model.lights || []

                    onToggled: (newState) => {
                        hueApi.putGroup(roomId, { "on": newState })
                        // Optimistic update
                        entertainmentModel.setProperty(index, "on", newState)
                    }

                    onUserBrightnessChange: (newValue) => {
                        var briVal = HueConv.percentToBri(newValue)
                        hueApi.putGroup(roomId, { "bri": briVal })
                        // Optimistic update
                        entertainmentModel.setProperty(index, "brightness", newValue)
                    }
                }
            }
        }
    }

    // Filtered model for entertainment areas
    ListModel {
        id: entertainmentModel
        Component.onCompleted: updateModel()
    }

    function updateModel() {
        entertainmentModel.clear()
        if (roomsModel) {
            console.log("Updating Entertainment model - rooms count: " + roomsModel.count)  // Debug log
            for (var i = 0; i < roomsModel.count; i++) {
                var item = roomsModel.get(i)
                console.log("Room " + item.name + " type: " + item.type)  // Debug log for types
                if (item.type === "Entertainment") {
                    entertainmentModel.append(item)
                }
            }
        } else {
            console.log("roomsModel is null - no entertainment areas loaded")
        }
    }

    Connections {
        target: hueApi
        function onDataRefreshed() {
            updateModel()
        }
    }
}
