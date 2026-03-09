/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * LightControl.qml - Card for an individual light.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: lightControl
    property string lightId: ""
    property string lightName: "Light"
    property bool isOn: false
    property int brightness: 0
    property color currentColor: "#FFFF00"  // Fallback
    property string colorMode: "hs"  // From model
    property real hue: 0.1667
    property real sat: 1.0
    property int ct: 4000
    property bool supportsColor: true  // Assume true; adjust based on model if available
    property bool supportsTemperature: true
    property var hueApi: null  // Added this property to fix the assignment error

    signal toggled(bool on)
    signal userBrightnessChange(int value)
    signal colorChanged(color newColor)
    signal temperatureChanged(int kelvin)

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
                source: "lightbulb"
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                PlasmaComponents.Label {
                    text: lightControl.lightName
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            // New: Current color indicator
            Rectangle {
                width: Kirigami.Units.gridUnit * 1.5
                height: Kirigami.Units.gridUnit * 1.5
                radius: Kirigami.Units.smallSpacing
                color: lightControl.currentColor
                border.width: 1
                border.color: Kirigami.Theme.disabledTextColor
                visible: lightControl.isOn && (supportsColor || supportsTemperature)
            }

            PlasmaComponents.Switch {
                checked: lightControl.isOn
                onCheckedChanged: {
                    if (checked !== lightControl.isOn) {
                        lightControl.toggled(checked)
                    }
                }
            }
        }

        BrightnessSlider {
            Layout.fillWidth: true
            visible: lightControl.isOn
            value: lightControl.brightness
            onEditingFinished: (val) => {
                if (val !== lightControl.brightness) {
                    lightControl.userBrightnessChange(val)
                }
            }
        }

        ColorPicker {
            Layout.fillWidth: true
            visible: lightControl.isOn && (supportsColor || supportsTemperature)
            supportsColor: lightControl.supportsColor
            supportsTemperature: lightControl.supportsTemperature
            selectedColor: lightControl.currentColor  // Initialize with fetched color
            colorTemperature: lightControl.ct  // Initialize with fetched ct

            onColorSelected: (newColor) => {
                lightControl.colorChanged(newColor)
            }

            onTemperatureSelected: (kelvin) => {
                lightControl.temperatureChanged(kelvin)
            }
        }
    }
}
