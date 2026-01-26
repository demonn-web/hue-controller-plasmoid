/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * SettingsPage.qml - Bridge setup, pairing, and polling options.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../UiConstants.js" as UiConstants

Item {
    id: settingsPage
    property var hueApi
    property bool hasApiKey: (Plasmoid.configuration.username && Plasmoid.configuration.username.length > 0) ||
        (hueApi && hueApi.username && hueApi.username.length > 0)
    property string errorMessage: ""

    function showError(msg) {
        errorMessage = msg
    }

    Connections {
        target: hueApi
        function onDiscoveryError(msg) { settingsPage.showError("Discovery Error: " + msg) }
        function onPairingError(msg) { settingsPage.showError("Pairing Error: " + msg) }
        function onRequestError(endpoint, msg) { settingsPage.showError("Request Error (" + endpoint + "): " + msg) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        Kirigami.FormLayout {
            Layout.fillWidth: true
            PlasmaComponents.TextField {
                id: bridgeIpField
                Kirigami.FormData.label: "Bridge IP:"
                placeholderText: "e.g., 192.168.1.100"
                text: hueApi ? hueApi.bridgeIp : (Plasmoid.configuration.bridgeIp || "")
                onEditingFinished: {
                    Plasmoid.configuration.bridgeIp = text
                    if (hueApi) hueApi.bridgeIp = text
                }
            }
            PlasmaComponents.SpinBox {
                id: pollIntervalSpinBox
                Kirigami.FormData.label: "Poll Interval (s):"
                from: UiConstants.pollIntervalMin
                to: UiConstants.pollIntervalMax
                value: Plasmoid.configuration.pollInterval || UiConstants.pollIntervalDefault
                onValueModified: {
                    Plasmoid.configuration.pollInterval = value
                }
            }
        }
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Auto-discover Bridge"
            icon.name: "edit-find"
            onClicked: {
                settingsPage.errorMessage = ""
                if (hueApi) hueApi.discoverBridge()
            }
        }
        Kirigami.InlineMessage {
            id: settingsErrorMessage
            Layout.fillWidth: true
            text: settingsPage.errorMessage
            type: Kirigami.MessageType.Error
            visible: settingsPage.errorMessage.length > 0
            actions: [
                Kirigami.Action {
                    icon.name: "dialog-close"
                    text: "Dismiss"
                    onTriggered: settingsPage.errorMessage = ""
                }
            ]
        }
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            text: "Bridge Pairing"
            font.bold: true
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Press the link button on your Hue Bridge, then click 'Pair' below."
            opacity: 0.7
        }
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Pair with Bridge"
            icon.name: "network-connect"
            enabled: bridgeIpField.text.length > 0
            onClicked: {
                settingsPage.errorMessage = ""
                if (hueApi) {
                    hueApi.bridgeIp = bridgeIpField.text
                    hueApi.createUser("plasma-hue", "kde-desktop")
                }
            }
        }
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Clear API Username"
            icon.name: "edit-clear"
            visible: hasApiKey
            onClicked: {
                Plasmoid.configuration.username = ""
                if (hueApi) hueApi.username = ""
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
