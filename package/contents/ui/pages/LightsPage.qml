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
import "../../code/HueConversions.js" as HueConv

Item {
    id: lightsPage
    property var hueApi
    property var lightsModel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            visible: lightsListView.count === 0
            text: "No lights found."
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
                    isOn: model.on || false
                    brightness: model.brightness || 0
                    hueApi: lightsPage.hueApi

                    onToggled: (newState) => {
                        hueApi.putLight(lightId, { "on": newState })
                        // Optimistic update
                        lightsModel.setProperty(index, "on", newState)
                    }

                    onUserBrightnessChange: (newValue) => {
                        hueApi.putLight(lightId, { "dimming": { "brightness": newValue } })
                        // Optimistic update
                        lightsModel.setProperty(index, "brightness", newValue)
                    }

                    onColorChanged: (newColor) => {
                        var hue = newColor.hsvHue
                        var sat = newColor.hsvSaturation
                        hueApi.setLightColor(lightId, hue, sat)
                    }

                    onTemperatureChanged: (kelvin) => {
                        hueApi.setLightTemperature(lightId, kelvin)
                    }
                }
            }
        }
    }
}
