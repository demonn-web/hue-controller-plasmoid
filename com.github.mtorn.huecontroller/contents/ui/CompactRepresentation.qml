/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * CompactRepresentation.qml - System tray icon representation
 */
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "components/StatusColors.js" as StatusColors

Item {
    id: compactRoot

    property var plasmoidItem
    property var hueApi
    property bool connected: hueApi ? (hueApi.status === "Ready" || hueApi.status === "Paired") : false

    implicitWidth: Kirigami.Units.iconSizes.medium
    implicitHeight: Kirigami.Units.iconSizes.medium

    Layout.minimumWidth: Kirigami.Units.iconSizes.medium
    Layout.minimumHeight: Kirigami.Units.iconSizes.medium

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!plasmoidItem) {
                return
            }
            plasmoidItem.expanded = !plasmoidItem.expanded
        }
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: Qt.resolvedUrl("../hue.png")
        active: hoverHandler.hovered
    }

    Rectangle {
        width: 8
        height: 8
        radius: 4
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: {
            if (!hueApi) return Kirigami.Theme.neutralTextColor
            return StatusColors.statusToColor(
                hueApi.status,
                Kirigami.Theme.positiveTextColor,
                Kirigami.Theme.negativeTextColor,
                Kirigami.Theme.neutralTextColor,
                Kirigami.Theme.disabledTextColor,
                Kirigami.Theme.neutralTextColor
            )
        }
    }
}
