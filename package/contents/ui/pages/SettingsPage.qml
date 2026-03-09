/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * SettingsPage.qml - Configuration for poll interval, bridge IP, and pairing.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: settingsPage
    property var hueApi

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: "Hue Bridge Setup"
            font.bold: true
            Layout.fillWidth: true
        }

        PlasmaComponents.TextField {
            id: bridgeIpField
            placeholderText: "Bridge IP (e.g., 192.168.1.100)"
            text: hueApi ? hueApi.bridgeIp : ""
            Layout.fillWidth: true
            onEditingFinished: {
                if (hueApi) {
                    hueApi.bridgeIp = text.trim()
                    Plasmoid.configuration.bridgeIp = text.trim()
                }
            }
        }

        PlasmaComponents.Button {
            text: "Discover Bridge"
            Layout.fillWidth: true
            onClicked: {
                if (hueApi) hueApi.discoverBridge()
            }
        }

        PlasmaComponents.Label {
            text: hueApi ? hueApi.status : "Disconnected"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Kirigami.Theme.disabledTextColor
        }

        PlasmaComponents.TextField {
            id: usernameField
            placeholderText: "Username (auto-generated after pairing)"
            text: hueApi ? hueApi.username : ""
            readOnly: true
            Layout.fillWidth: true
        }

        PlasmaComponents.Button {
            text: "Pair with Bridge"
            Layout.fillWidth: true
            enabled: hueApi && hueApi.bridgeIp && !hueApi.username
            onClicked: {
                if (hueApi) hueApi.createUser("Hue Controller", "Plasma Widget")
            }
        }

        PlasmaComponents.Label {
            text: "Press the link button on your Hue Bridge before pairing."
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: hueApi && hueApi.status === "Press Link Button"
            color: Kirigami.Theme.negativeTextColor
        }

        Item { height: Kirigami.Units.largeSpacing }

        PlasmaComponents.Label {
            text: "Poll Interval (seconds)"
            Layout.fillWidth: true
        }

        PlasmaComponents.SpinBox {
            from: 0
            to: 3600
            value: Plasmoid.configuration.pollInterval
            editable: true
            Layout.fillWidth: true
            onValueModified: (newValue) => {
                Plasmoid.configuration.pollInterval = newValue
            }
        }

        PlasmaComponents.Button {
            text: "Clear Pairing"
            Layout.fillWidth: true
            onClicked: {
                Plasmoid.configuration.username = ""
                if (hueApi) hueApi.username = ""
            }
        }
    }
}
