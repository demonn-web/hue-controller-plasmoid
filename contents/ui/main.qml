/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * main.qml - Plasmoid entry point that wires models, API client, and views.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import "../code" as HueCode
import "UiConstants.js" as UiConstants
import "components"

PlasmoidItem {
    // System tray popups behave better with a fixed size.
    readonly property int popupWidth: Kirigami.Units.gridUnit * 20
    readonly property int popupHeight: Kirigami.Units.gridUnit * 10
    property int pollIntervalSeconds: {
        var configured = Plasmoid.configuration.pollInterval || UiConstants.pollIntervalDefault
        return Math.max(UiConstants.pollIntervalMin, Math.min(UiConstants.pollIntervalMax, configured))
    }

    Layout.preferredWidth: popupWidth
    Layout.preferredHeight: popupHeight
    id: root

    // CompactRepresentation toggles expansion manually.
    activationTogglesExpanded: false
    toolTipMainText: "Hue Controller"
    toolTipSubText: hueApiClient ? hueApiClient.status : "Disconnected"
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Turn on all"
            enabled: hueApiClient && (hueApiClient.status === "Ready" || hueApiClient.status === "Paired")
            onTriggered: hueApiClient.toggleAll(true)
        },
        PlasmaCore.Action {
            text: "Turn off all"
            enabled: hueApiClient && (hueApiClient.status === "Ready" || hueApiClient.status === "Paired")
            onTriggered: hueApiClient.toggleAll(false)
        }
    ]
    HueCode.LightsModel { id: lightsModel }
    HueCode.RoomsModel { id: roomsModel }
    HueCode.HueApiClient {
        id: hueApiClient
        bridgeIp: Plasmoid.configuration.bridgeIp
        username: Plasmoid.configuration.username
        lightsModel: lightsModel
        roomsModel: roomsModel
        onBridgeDiscovered: (ip) => {
            Plasmoid.configuration.bridgeIp = ip
        }
        onPairingSuccess: (user) => {
            Plasmoid.configuration.username = user
            hueApiClient.refreshData()
        }
        onPairingError: (msg) => {
            showError("Pairing Error: " + msg)
        }
        onDiscoveryError: (msg) => {
            showError("Discovery Error: " + msg)
        }
        onRequestError: (endpoint, msg) => {
            showError("Request Error (" + endpoint + "): " + msg)
        }
    }
    function showError(msg) {
        // fullRepresentationItem appears after the popup is created.
        if (Plasmoid.fullRepresentationItem) {
            Plasmoid.fullRepresentationItem.showErrorMessage(msg)
        }
    }
    Component.onCompleted: {
        if (Plasmoid.configuration.bridgeIp && Plasmoid.configuration.username) {
            hueApiClient.refreshData()
        }
    }
    onPollIntervalSecondsChanged: {
        if (pollIntervalSeconds > 0) {
            pollTimer.restart()
        }
    }
    Timer {
        id: pollTimer
        interval: pollIntervalSeconds * 1000
        repeat: true
        running: pollIntervalSeconds > 0
        onTriggered: hueApiClient.refreshData()
    }
    compactRepresentation: CompactRepresentation {
        plasmoidItem: root
        hueApi: hueApiClient
    }
    fullRepresentation: FullRepresentation {
        id: fullRep
        hueApi: hueApiClient
    }
}
