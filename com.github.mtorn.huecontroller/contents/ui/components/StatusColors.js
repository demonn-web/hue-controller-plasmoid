/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * StatusColors.js - Shared status-to-color mapping for UI indicators.
 */
.pragma library

function statusToColor(status, positive, negative, neutral, disabled, fallback) {
    switch (status) {
        case "Connected":
        case "Bridge Found":
        case "Paired":
        case "Ready":
            return positive

        case "Disconnected":
        case "Connection Failed":
        case "Discovery Failed":
        case "Discovery Rate Limited":
        case "Auth Failed":
        case "Pairing Error":
            return negative

        case "Discovering...":
        case "Pairing...":
        case "Refreshing...":
        case "Press Link Button":
            return neutral

        default:
            return fallback !== undefined ? fallback : disabled
    }
}
