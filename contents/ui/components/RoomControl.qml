/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * RoomControl.qml - Card for a room or zone.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: roomControl
    property string roomId: ""
    property string roomName: "Room"
    property bool isOn: false
    property int brightness: 0
    property int lightCount: 0
    signal toggled(bool on)
    signal userBrightnessChange(int value)
    signal roomClicked()

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
                source: "go-home"
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium

                MouseArea {
                    anchors.fill: parent
                    onClicked: roomControl.roomClicked()
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                PlasmaComponents.Label {
                    text: roomControl.roomName
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    text: roomControl.lightCount + " lights"
                    Layout.fillWidth: true
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.7
                }
            }
            PlasmaComponents.Switch {
                checked: roomControl.isOn
                onCheckedChanged: {
                    if (checked !== roomControl.isOn) {
                        roomControl.toggled(checked)
                    }
                }
            }
        }
        BrightnessSlider {
            Layout.fillWidth: true
            visible: roomControl.isOn
            value: roomControl.brightness
            onEditingFinished: (val) => {
                if (val !== roomControl.brightness) {
                    roomControl.userBrightnessChange(val)
                }
            }
        }
    }
}
