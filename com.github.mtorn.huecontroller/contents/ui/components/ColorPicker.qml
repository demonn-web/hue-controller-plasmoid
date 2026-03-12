/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * ColorPicker.qml - Simple color and temperature picker.
 * Rewritten version with fix for unintended temperature resets on initialization.
 * Changed tempSlider signal from onValueChanged to onMoved to prevent automatic API calls during component creation.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: colorPicker
    property bool supportsColor: true
    property bool supportsTemperature: true
    property color selectedColor: "white"
    property int colorTemperature: 4000
    property color pendingColor: "white"
    property int pendingTemperature: 4000
    signal colorSelected(color newColor)
    signal temperatureSelected(int kelvin)

    implicitHeight: contentLayout.implicitHeight

    function queueColor(newColor) {
        pendingColor = newColor
        colorDebounce.restart()
    }

    function applyHueSaturation(hue, saturation) {
        var safeHue = (isNaN(hue) || hue < 0) ? 0 : hue
        var safeSat = Math.max(0, Math.min(1, saturation))
        // HSV: saturation 0 should become white (value at 1.0).
        selectedColor = Qt.hsva(safeHue, safeSat, 1.0, 1.0)
        hexInput.text = selectedColor.toString().toUpperCase()
        queueColor(selectedColor)
    }

    function emitColorNow() {
        colorDebounce.stop()
        colorSelected(pendingColor)
    }

    function queueTemperature(kelvin) {
        pendingTemperature = kelvin
        tempDebounce.restart()
    }

    function emitTemperatureNow() {
        tempDebounce.stop()
        temperatureSelected(pendingTemperature)
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
        PlasmaComponents.TabBar {
            id: modeTabBar
            Layout.fillWidth: true
            visible: colorPicker.supportsColor && colorPicker.supportsTemperature

            PlasmaComponents.TabButton {
                text: "Color"
            }
            PlasmaComponents.TabButton {
                text: "Temperature"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            currentIndex: modeTabBar.currentIndex
            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    radius: Kirigami.Units.smallSpacing

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#FF0000" }
                        GradientStop { position: 0.17; color: "#FFFF00" }
                        GradientStop { position: 0.33; color: "#00FF00" }
                        GradientStop { position: 0.5; color: "#00FFFF" }
                        GradientStop { position: 0.67; color: "#0000FF" }
                        GradientStop { position: 0.83; color: "#FF00FF" }
                        GradientStop { position: 1.0; color: "#FF0000" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: (mouse) => {
                            var hue = mouse.x / width
                            var sat = saturationSlider.value / 100
                            colorPicker.applyHueSaturation(hue, sat)
                        }
                    }
                }
                PlasmaComponents.Slider {
                    id: saturationSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: 100

                    onMoved: {
                        var hue = colorPicker.selectedColor.hsvHue
                        colorPicker.applyHueSaturation(hue, value / 100)
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    Rectangle {
                        width: Kirigami.Units.gridUnit * 2
                        height: Kirigami.Units.gridUnit * 1.5
                        radius: Kirigami.Units.smallSpacing
                        color: colorPicker.selectedColor
                        border.width: 1
                        border.color: Kirigami.Theme.disabledTextColor
                    }
                    PlasmaComponents.TextField {
                        id: hexInput
                        Layout.fillWidth: true
                        placeholderText: "#RRGGBB"
                        text: colorPicker.selectedColor.toString().toUpperCase()
                        maximumLength: 7

                        onAccepted: {
                            var hexColor = text.trim()
                            // Normalize input and validate.
                            if (hexColor.length > 0 && hexColor[0] !== '#') {
                                hexColor = '#' + hexColor
                            }
                            if (/^#[0-9A-Fa-f]{6}$/.test(hexColor)) {
                                colorPicker.selectedColor = hexColor
                                hexInput.text = colorPicker.selectedColor.toString().toUpperCase()
                                colorPicker.queueColor(colorPicker.selectedColor)
                            }
                        }
                    }
                    PlasmaComponents.Button {
                        text: "Apply"
                        onClicked: hexInput.accepted()
                    }
                }
            }


            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    radius: Kirigami.Units.smallSpacing

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#FF9329" }
                        GradientStop { position: 0.5; color: "#FFFFFF" }
                        GradientStop { position: 1.0; color: "#9DBEFF" }
                    }
                }
                PlasmaComponents.Slider {
                    id: tempSlider
                    Layout.fillWidth: true
                    from: 2000
                    to: 6500
                    value: colorPicker.colorTemperature
                    stepSize: 100

                    onMoved: {
                        colorPicker.colorTemperature = value
                        colorPicker.queueTemperature(value)
                    }

                    onPressedChanged: {
                        if (!pressed) {
                            colorPicker.emitTemperatureNow()
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: "Warm"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.7
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: tempSlider.value + "K"
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: "Cool"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.7
                    }
                }
            }
        }
    }

    onSelectedColorChanged: {
        if (!saturationSlider.pressed) {
            var sat = selectedColor.hsvSaturation
            if (isNaN(sat) || sat < 0) sat = 0
                saturationSlider.value = Math.round(sat * 100)
        }
    }

    Timer {
        id: colorDebounce
        interval: 200
        repeat: false
        onTriggered: {
            colorPicker.emitColorNow()
        }
    }

    Timer {
        id: tempDebounce
        interval: 200
        repeat: false
        onTriggered: {
            colorPicker.emitTemperatureNow()
        }
    }
}
