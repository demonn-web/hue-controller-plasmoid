/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * configGeneral.qml - Settings page for the standard Plasma config dialog.
 */

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "../UiConstants.js" as UiConstants

Kirigami.FormLayout {
    id: root

    // Property aliases map to kcfg entries in main.xml.
    property alias cfg_bridgeIp: bridgeIp.text
    property alias cfg_username: username.text
    property alias cfg_pollInterval: pollInterval.value

    TextField {
        id: bridgeIp
        Kirigami.FormData.label: "Bridge IP Address:"
        placeholderText: "e.g., 192.168.1.100"
    }

    TextField {
        id: username
        Kirigami.FormData.label: "API Username:"
        placeholderText: "Auto-generated during pairing"
    }

    SpinBox {
        id: pollInterval
        Kirigami.FormData.label: "Poll Interval (seconds):"
        from: UiConstants.pollIntervalMin
        to: UiConstants.pollIntervalMax
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
    }

    Label {
        text: "Note: To pair with a new bridge, please use the <b>Settings</b> tab inside the widget popup."
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        font.italic: true
        opacity: 0.7
    }
}
