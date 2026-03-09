/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * FullRepresentation.qml - The expanded popup view.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import "pages" as Pages
import "components" as Components

Item {
    id: fullRepresentation
    property var hueApi
    property bool bridgeConfigured: hueApi && hueApi.bridgeIp && hueApi.username

    function showErrorMessage(msg) {
        errorLabel.text = msg
        errorLabel.visible = true
        errorHideTimer.restart()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing

        PlasmaComponents.TabBar {
            id: mainTabBar
            Layout.fillWidth: true
            visible: bridgeConfigured

            PlasmaComponents.TabButton {
                text: "Lights"
            }
            PlasmaComponents.TabButton {
                text: "Rooms"
            }
            PlasmaComponents.TabButton {
                text: "Entertainment"
            }
            PlasmaComponents.TabButton {
                text: "Scenes"
            }
            PlasmaComponents.TabButton {
                text: "Settings"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: bridgeConfigured ? mainTabBar.currentIndex + 1 : 0

            Pages.PairingPage {
                visible: !bridgeConfigured
                hueApi: fullRepresentation.hueApi
            }

            Pages.LightsPage {
                hueApi: fullRepresentation.hueApi
                lightsModel: fullRepresentation.hueApi ? fullRepresentation.hueApi.lightsModel : null
            }

            Pages.RoomsPage {
                hueApi: fullRepresentation.hueApi
                roomsModel: fullRepresentation.hueApi ? fullRepresentation.hueApi.roomsModel : null
            }

            Pages.EntertainmentPage {
                hueApi: fullRepresentation.hueApi
                roomsModel: fullRepresentation.hueApi ? fullRepresentation.hueApi.roomsModel : null
            }

            Pages.ScenesPage {
                hueApi: fullRepresentation.hueApi
                scenesModel: fullRepresentation.hueApi ? fullRepresentation.hueApi.scenesModel : null
                roomsModel: fullRepresentation.hueApi ? fullRepresentation.hueApi.roomsModel : null
            }

            Pages.SettingsPage {
                hueApi: fullRepresentation.hueApi
            }
        }

        PlasmaComponents.Label {
            id: errorLabel
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: false
            color: Kirigami.Theme.negativeTextColor
        }
    }

    Timer {
        id: errorHideTimer
        interval: 5000
        repeat: false
        onTriggered: errorLabel.visible = false
    }
}
