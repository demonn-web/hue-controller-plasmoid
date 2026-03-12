/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * RoomsModel.qml - ListModel for rooms and zones.
 *
 * Roles: id, name, lightCount, lights, on, brightness, type, scene (optional).
 */

import QtQuick

ListModel {
    id: roomsModel
    // Find a room by id.
    function getRoom(roomId) {
        for (var i = 0; i < count; i++) {
            if (get(i).id === roomId) {
                return get(i)
            }
        }
        return null
    }
}
