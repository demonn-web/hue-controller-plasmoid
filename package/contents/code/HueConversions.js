/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * HueConversions.js - Shared helpers for Hue v1 unit conversions.
 */
.pragma library

function clamp(value, minValue, maxValue) {
    if (value < minValue) return minValue
    if (value > maxValue) return maxValue
    return value
}

function percentToBri(percent) {
    var p = isNaN(percent) ? 0 : percent
    p = clamp(p, 0, 100)
    return Math.round(p * 254 / 100)
}

function briToPercent(bri) {
    var b = isNaN(bri) ? 0 : bri
    b = clamp(b, 0, 254)
    return Math.round(b / 254 * 100)
}

function hue01ToV1(hue) {
    var h = isNaN(hue) ? 0 : hue
    h = clamp(h, 0, 1)
    return Math.round(h * 65535)
}

function sat01ToV1(sat) {
    var s = isNaN(sat) ? 0 : sat
    s = clamp(s, 0, 1)
    return Math.round(s * 254)
}

function kelvinToMired(kelvin) {
    var k = isNaN(kelvin) ? 0 : kelvin
    if (k <= 0) return 153
    var mired = Math.round(1000000 / k)
    return clamp(mired, 153, 500)
}
