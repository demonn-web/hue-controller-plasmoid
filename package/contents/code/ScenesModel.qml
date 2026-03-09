
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * ScenesModel.qml - ListModel for Hue scenes.
 *
 * Roles: id, name, lights (array of light IDs).
 */

import QtQuick

ListModel {
    id: scenesModel
    // Find a scene by id.
    function getScene(sceneId) {
        for (var i = 0; i < count; i++) {
            if (get(i).id === sceneId) {
                return get(i)
            }
        }
        return null
    }
}
