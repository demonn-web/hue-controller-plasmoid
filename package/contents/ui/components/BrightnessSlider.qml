/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * BrightnessSlider.qml - Slider with a small debounce to reduce API spam.
 */

import QtQuick
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root
    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property var lightId: ""
    signal moved()
    signal editingFinished(var finalValue)

    implicitWidth: 200
    implicitHeight: slider.implicitHeight


    PlasmaComponents.Slider {
        id: slider
        anchors.fill: parent
        from: 0
        to: 100
        stepSize: 1

        onMoved: {
            debounceTimer.restart()
            root.moved()
        }

        onPressedChanged: {
            if (!pressed) {
                // On release, emit the final value immediately.
                debounceTimer.stop()
                root.editingFinished(value)
            }
        }
    }
    // Debounce updates so we don't spam the bridge while dragging.
    Timer {
        id: debounceTimer
        interval: 200
        repeat: false
        onTriggered: {
            root.editingFinished(slider.value)
        }
    }
}
