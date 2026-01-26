/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * LightControl.qml - Row widget for a single light.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root
    property string lightId
    property string lightName
    property bool lightOn
    property int lightBrightness
    property bool supportsColor: true
    property bool supportsTemperature: true
    property color lightColor: "#FFD700"
    property bool colorPickerExpanded: false
    signal toggle(string id, bool newState)
    signal brightnessChange(string id, int newValue)
    signal colorChange(string id, real hue, real saturation)
    signal temperatureChange(string id, int kelvin)

    function _clamp(value, minValue, maxValue) {
        return Math.min(maxValue, Math.max(minValue, value))
    }

    function temperatureToColor(kelvin) {
        var k = isNaN(kelvin) || kelvin <= 0 ? 6500 : kelvin
        var temp = k / 100
        var red
        var green
        var blue

        if (temp <= 66) {
            red = 255
            green = 99.4708025861 * Math.log(temp) - 161.1195681661
            if (temp <= 19) {
                blue = 0
            } else {
                blue = 138.5177312231 * Math.log(temp - 10) - 305.0447927307
            }
        } else {
            red = 329.698727446 * Math.pow(temp - 60, -0.1332047592)
            green = 288.1221695283 * Math.pow(temp - 60, -0.0755148492)
            blue = 255
        }

        red = _clamp(red, 0, 255)
        green = _clamp(green, 0, 255)
        blue = _clamp(blue, 0, 255)
        return Qt.rgba(red / 255, green / 255, blue / 255, 1)
    }

    implicitHeight: mainColumn.implicitHeight
    implicitWidth: mainColumn.implicitWidth

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            id: layout
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            Kirigami.Icon {
                source: "im-jabber"
                isMask: true
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                color: root.lightOn ? root.lightColor : Kirigami.Theme.disabledTextColor
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: root.lightName
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                BrightnessSlider {
                    Layout.fillWidth: true
                    value: root.lightBrightness
                    visible: root.lightOn
                    onEditingFinished: (val) => {
                        root.brightnessChange(root.lightId, val)
                    }
                }
            }
            PlasmaComponents.ToolButton {
                visible: root.lightOn && (root.supportsColor || root.supportsTemperature)
                icon.name: "color-picker"
                onClicked: root.colorPickerExpanded = !root.colorPickerExpanded

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: width / 2
                    color: root.lightColor
                    border.width: 1
                    border.color: Kirigami.Theme.disabledTextColor
                    z: -1
                }
            }
            PlasmaComponents.Switch {
                checked: root.lightOn
                onCheckedChanged: {
                    if (checked !== root.lightOn) {
                        root.toggle(root.lightId, checked)
                    }
                }
            }
        }
        ColorPicker {
            id: colorPicker
            Layout.fillWidth: true
            visible: root.colorPickerExpanded && root.lightOn
            supportsColor: root.supportsColor
            supportsTemperature: root.supportsTemperature

            onColorSelected: (newColor) => {
                root.lightColor = newColor
                // Hue expects hue/sat ranges; QML provides HSL floats.
                var hue = newColor.hslHue
                var sat = newColor.hslSaturation
                root.colorChange(root.lightId, hue, sat)
            }

            onTemperatureSelected: (kelvin) => {
                root.lightColor = root.temperatureToColor(kelvin)
                root.temperatureChange(root.lightId, kelvin)
            }
        }
    }
}
