/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * LightsPage.qml - List of individual lights.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "../components"

Item {
    id: lightsPage
    property var hueApi
    property var lightsModel
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        PlasmaComponents.Label {
            visible: lightsListView.count === 0
            text: "No lights found.\nMake sure your bridge is connected."
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: 0.6
        }
        Item {
            id: lightsListWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: lightsListView
                anchors.fill: parent
                anchors.rightMargin: (lightsScrollBar.size < 1 ? (lightsScrollBar.implicitWidth + Kirigami.Units.smallSpacing) : 0)
                model: lightsModel
                spacing: Kirigami.Units.smallSpacing
                clip: true
                ScrollBar.vertical: ScrollBar {
                    id: lightsScrollBar
                    parent: lightsListView.parent
                    anchors.top: lightsListView.top
                    anchors.bottom: lightsListView.bottom
                    anchors.left: lightsListView.right
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    policy: ScrollBar.AsNeeded
                }

                delegate: LightControl {
                    width: lightsListView.width

                    lightId: model.id || ""
                    lightName: model.name || "Unknown Light"
                    lightOn: model.on || false
                    lightBrightness: model.brightness || 0

                    onToggle: (id, newState) => {
                        if (hueApi) hueApi.putLight(id, { "on": { "on": newState } })
                        if (lightsModel) {
                            lightsModel.setProperty(index, "on", newState)
                        }
                        if (hueApi) {
                            hueApi.updateAllLightsOn()
                        }
                    }

                    onBrightnessChange: (id, newValue) => {
                        if (hueApi) hueApi.putLight(id, { "dimming": { "brightness": newValue } })
                        if (lightsModel) {
                            lightsModel.setProperty(index, "brightness", newValue)
                        }
                    }

                    onColorChange: (id, hue, sat) => {
                        if (hueApi) hueApi.setLightColor(id, hue, sat)
                    }

                    onTemperatureChange: (id, kelvin) => {
                        if (hueApi) hueApi.setLightTemperature(id, kelvin)
                    }
                }
            }
        }
    }
}
