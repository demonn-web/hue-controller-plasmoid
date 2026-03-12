/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * StatusIndicator.qml - Small status dot for connection state.
 */

import QtQuick
import org.kde.kirigami as Kirigami
import "StatusColors.js" as StatusColors

Rectangle {
    id: root
    property string status: "unknown"

    width: 10
    height: 10
    radius: width / 2
    color: StatusColors.statusToColor(
        status,
        Kirigami.Theme.positiveTextColor,
        Kirigami.Theme.negativeTextColor,
        Kirigami.Theme.neutralTextColor,
        Kirigami.Theme.disabledTextColor
    )
    Behavior on color {
        ColorAnimation { duration: 200 }
    }
}
