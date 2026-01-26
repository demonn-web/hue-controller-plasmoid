/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * FullRepresentation.qml - Popup content shown when the tray icon is clicked.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

import "pages"
import "components"

Item {
    id: fullRoot
    property var hueApi

    implicitWidth: Kirigami.Units.gridUnit * 20
    implicitHeight: Kirigami.Units.gridUnit * 10
    clip: true

    Layout.minimumWidth: Kirigami.Units.gridUnit * 15
    Layout.minimumHeight: 0


    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing

            StatusIndicator {
                id: statusIndicator
                status: hueApi ? hueApi.status : "Disconnected"
            }
            PlasmaComponents.Label {
                text: "Hue Controller"
                font.bold: true
                Layout.fillWidth: true
            }
            PlasmaComponents.Switch {
                id: masterSwitch
                text: "All"
                enabled: hueApi && hueApi.lightsModel && hueApi.lightsModel.count > 0
                onClicked: {
                    if (hueApi) hueApi.toggleAll(checked)
                }
            }
        }
        Binding {
            target: masterSwitch
            property: "checked"
            value: hueApi ? hueApi.allLightsOn : false
        }
        Kirigami.InlineMessage {
            id: errorMessage
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.smallSpacing
            type: Kirigami.MessageType.Error
            showCloseButton: true
            visible: text.length > 0
        }
        PlasmaComponents.TabBar {
            id: tabBar
            Layout.fillWidth: true

            PlasmaComponents.TabButton {
                text: "Rooms"
            }
            PlasmaComponents.TabButton {
                text: "Lights"
            }

            PlasmaComponents.TabButton {
                text: "Settings"
                icon.name: "configure"
            }
        }
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0
            currentIndex: tabBar.currentIndex
            RoomsPage {
                hueApi: fullRoot.hueApi
                roomsModel: hueApi ? hueApi.roomsModel : null
            }

            LightsPage {
                hueApi: fullRoot.hueApi
                lightsModel: hueApi ? hueApi.lightsModel : null
            }

            SettingsPage {
                hueApi: fullRoot.hueApi
            }
        }
    }
    // Show errors from the API layer in the inline banner.
    function showErrorMessage(msg) {
        errorMessage.text = msg
        errorMessage.visible = true
    }
}
