/*
 * SPDX-FileCopyrightText: 2026 mtorn <https://github.com/mtorn>
 * SPDX-License-Identifier: MIT
 *
 * HueApiClient.qml - Bridge API client and request helpers.
 *
 * Uses Hue v1 endpoints over HTTP to avoid self-signed cert prompts.
 */

import QtQuick
import QtQml

import "HueConversions.js" as HueConv

QtObject {
    id: hueApi

    property string bridgeIp: ""

    property string username: ""

    property string status: "Disconnected"

    property bool discoveryInFlight: false

    property int discoveryCooldownUntil: 0

    property int discoveryMinIntervalSeconds: 10

    property int discoveryCooldownSeconds: 60

    property int requestTimeoutMs: 10000

    property var lightsModel: null

    property var roomsModel: null

    property var scenesModel: null

    property bool allLightsOn: false

    signal bridgeDiscovered(string ip)

    signal pairingSuccess(string username)

    signal pairingError(string message)

    signal discoveryError(string message)

    signal requestError(string endpoint, string message)

    signal dataRefreshed()

    function discoverBridge() {
        var now = _nowSeconds()
        if (discoveryInFlight) {
            discoveryError("Discovery already in progress.")
            return
        }
        if (now < discoveryCooldownUntil) {
            var remaining = discoveryCooldownUntil - now
            status = "Discovery Rate Limited"
            discoveryError("Discovery is rate-limited. Try again in " + remaining + "s or enter the bridge IP manually.")
            return
        }

        discoveryInFlight = true
        discoveryCooldownUntil = now + discoveryMinIntervalSeconds
        status = "Discovering..."
        var xhr = new XMLHttpRequest()
        var finished = false

        function finishDiscovery() {
            if (finished) return false
                finished = true
                discoveryInFlight = false
                return true
        }

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (!finishDiscovery()) return
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText)
                            if (response.length > 0) {
                                var ip = response[0].internalipaddress
                                bridgeDiscovered(ip)
                                status = "Bridge Found"
                            } else {
                                discoveryError("No Hue Bridge found on network.")
                                status = "Discovery Failed"
                            }
                        } catch (e) {
                            discoveryError("Failed to parse discovery response.")
                            status = "Discovery Failed"
                        }
                    } else if (xhr.status === 429) {
                        var retryAfter = _parseRetryAfter(xhr.getResponseHeader("Retry-After"))
                        var nowRate = _nowSeconds()
                        discoveryCooldownUntil = Math.max(discoveryCooldownUntil, nowRate + retryAfter)
                        status = "Discovery Rate Limited"
                        discoveryError("Discovery rate-limited by Hue service. Try again in " + retryAfter + "s or enter the bridge IP manually.")
                    } else if (xhr.status === 0) {
                        discoveryError("Discovery failed due to a network error.")
                        status = "Discovery Failed"
                    } else {
                        discoveryError("Discovery failed with status: " + xhr.status)
                        status = "Discovery Failed"
                    }
            }
        }

        xhr.onerror = function() {
            if (!finishDiscovery()) return
                discoveryError("Discovery failed due to a network error.")
                status = "Discovery Failed"
        }

        xhr.open("GET", "https://discovery.meethue.com/")
        xhr.send()
    }

    function _nowSeconds() {
        return Math.floor(Date.now() / 1000)
    }

    function _parseRetryAfter(header) {
        if (!header) return discoveryCooldownSeconds

            var asInt = parseInt(header, 10)
            if (!isNaN(asInt) && asInt > 0) return asInt

                var asDate = Date.parse(header)
                if (!isNaN(asDate)) {
                    var diff = Math.ceil((asDate - Date.now()) / 1000)
                    if (diff > 0) return diff
                }

                return discoveryCooldownSeconds
    }

    function createUser(appName, deviceName) {
        if (!bridgeIp) {
            pairingError("Bridge IP not set.")
            return
        }

        status = "Pairing..."

        var xhr = new XMLHttpRequest()
        // Use the legacy /api endpoint to avoid TLS errors on the bridge.
        var url = "http://" + bridgeIp + "/api"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.length > 0) {
                            if (response[0].success) {
                                var newUsername = response[0].success.username
                                pairingSuccess(newUsername)
                                status = "Paired"
                            } else if (response[0].error) {
                                var errType = response[0].error.type
                                if (errType === 101) {
                                    pairingError("Link button not pressed.")
                                    status = "Press Link Button"
                                } else {
                                    pairingError(response[0].error.description)
                                    status = "Pairing Error"
                                }
                            }
                        }
                    } catch (e) {
                        pairingError("Failed to parse pairing response.")
                        status = "Pairing Error"
                    }
                } else {
                    if (xhr.status === 0) {
                        pairingError("Network error - check bridge IP.")
                    } else {
                        pairingError("Request failed: " + xhr.status)
                    }
                    status = "Connection Failed"
                }
            }
        }

        xhr.open("POST", url)
        xhr.setRequestHeader("Content-Type", "application/json")
        var body = JSON.stringify({
            "devicetype": appName + "#" + deviceName
        })
        xhr.send(body)
    }

    function request(method, endpoint, body, callback) {
        if (!bridgeIp || !username) {
            return
        }

        var xhr = new XMLHttpRequest()
        // Stick to v1 HTTP endpoints for now; they work reliably on local bridges.
        var url = "http://" + bridgeIp + "/api/" + username + "/" + endpoint
        var finished = false
        function finishOnce() {
            if (finished) return false
                finished = true
                return true
        }

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (!finishOnce()) return
                    if (xhr.status === 200 || xhr.status === 201 || xhr.status === 204) {
                        if (callback) {
                            try {
                                var response = JSON.parse(xhr.responseText)
                                callback(response)
                            } catch (e) {
                                requestError(endpoint, "Failed to parse response.")
                            }
                        }
                    } else if (xhr.status === 403) {
                        requestError(endpoint, "Authentication failed.")
                        status = "Auth Failed"
                    } else if (xhr.status === 0) {
                        requestError(endpoint, "Network error.")
                        status = "Connection Failed"
                    } else {
                        requestError(endpoint, "Request failed: " + xhr.status)
                    }
            }
        }

        xhr.onerror = function() {
            if (!finishOnce()) return
                requestError(endpoint, "Network error.")
                status = "Connection Failed"
        }

        xhr.ontimeout = function() {
            if (!finishOnce()) return
                requestError(endpoint, "Request timed out.")
                status = "Connection Failed"
        }

        xhr.open(method, url)
        xhr.timeout = requestTimeoutMs

        if (body) {
            xhr.setRequestHeader("Content-Type", "application/json")
            xhr.send(JSON.stringify(body))
        } else {
            xhr.send()
        }
    }

    function refreshData() {
        if (!bridgeIp || !username) return

            status = "Refreshing..."
            getLights()
            getRooms()
            getScenes()
    }

    function getLights() {
        request("GET", "lights", null, parseLights)
    }

    function parseLights(response) {
        if (!response) return
            if (!lightsModel) return

                var seen = Object.create(null)
                // Hue v1 returns an object keyed by light id.
                for (var id in response) {
                    if (response.hasOwnProperty(id)) {
                        seen[id] = true
                        var item = response[id]
                        var name = item.name || "Unknown"
                        var onState = item.state ? item.state.on : false
                        var brightness = item.state && item.state.bri ? HueConv.briToPercent(item.state.bri) : 100

                        // New: Parse current color state
                        var currentColor = "#FFFF00"  // Default to yellow if no color data (fallback for the bug)
                        var colorMode = item.state ? item.state.colormode : "hs"
                        var hue = item.state ? item.state.hue / 65535 : 0.1667  // Normalize to 0-1 for Qt.hsva (yellow hue ~0.1667)
                        var sat = item.state ? item.state.sat / 254 : 1.0  // Normalize to 0-1
                        var ct = item.state ? item.state.ct : 4000  // Default neutral white
                        if (colorMode === "hs" && item.state.hue !== undefined && item.state.sat !== undefined) {
                            currentColor = Qt.hsva(hue, sat, 1.0, 1.0)  // Full value for vibrant color
                        } else if (colorMode === "ct") {
                            // Approximate color temp to RGB (simplified; full conversion in HueConversions.js if needed)
                            currentColor = HueConv.ctToRgb(ct)  // Assume you add this function to HueConversions.js
                        } else if (colorMode === "xy") {
                            // Convert xy to RGB if xy present (add to HueConversions.js if not)
                            var xy = item.state ? item.state.xy : [0.5, 0.5]
                            currentColor = HueConv.xyToRgb(xy[0], xy[1], item.state.bri / 254)
                        }

                        updateModel(lightsModel, id, {
                            "id": id,
                            "name": name,
                            "on": onState,
                            "brightness": brightness,
                            "type": "light",
                            "color": currentColor,  // New property for current color
                            "colorMode": colorMode,  // New
                            "hue": hue,  // New
                            "sat": sat,  // New
                            "ct": ct  // New
                        })
                    }
                }

                // Remove lights that no longer exist on the bridge.
                for (var i = lightsModel.count - 1; i >= 0; i--) {
                    var existingId = lightsModel.get(i).id
                    if (!seen[existingId]) {
                        lightsModel.remove(i)
                    }
                }

                _recomputeAllLightsOn()
                status = "Ready"
                dataRefreshed()
    }

    // Rooms are exposed as "groups" in the v1 API.

    function getRooms() {
        request("GET", "groups", null, parseRooms)
    }

    function parseRooms(response) {
        if (!response) return
            if (!roomsModel) return

                var seen = Object.create(null)
                // Hue v1 returns an object keyed by group id.
                for (var id in response) {
                    if (response.hasOwnProperty(id)) {
                        var item = response[id]
                        var name = item.name || "Unknown Room"
                        var lightIds = item.lights || []
                        var onState = item.state ? item.state.any_on : false
                        var brightness = item.action && item.action.bri ? HueConv.briToPercent(item.action.bri) : 0

                        var type = item.type || "Room"
                        // No longer skip Entertainment; include all for filtering in pages

                        seen[id] = true
                        updateModel(roomsModel, id, {
                            "id": id,
                            "name": name,
                            "lights": lightIds,
                            "lightCount": lightIds.length,
                            "type": type,
                            "on": onState,
                            "brightness": brightness
                        })
                    }
                }

                // Remove rooms that no longer exist on the bridge.
                for (var i = roomsModel.count - 1; i >= 0; i--) {
                    var existingId = roomsModel.get(i).id
                    if (!seen[existingId]) {
                        roomsModel.remove(i)
                    }
                }
    }

    function getScenes() {
        request("GET", "scenes", null, parseScenes)
    }

    function parseScenes(response) {
        if (scenesModel) {
            scenesModel.clear()
            for (var id in response) {
                var scene = response[id]
                scenesModel.append({
                    id: id,
                    name: scene.name || "Unnamed Scene",
                    lights: scene.lights || []
                })
            }
        }
    }

    function recallScene(groupId, sceneId) {
        putGroup(groupId, { "scene": sceneId })
    }

    function putGroup(id, params) {
        request("PUT", "groups/" + id + "/action", params, null)
    }

    function updateModel(model, id, newData) {
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).id === id) {
                model.set(i, newData)
                return
            }
        }
        model.append(newData)
    }

    function putLight(id, params) {
        // Convert the v2-style payload to v1 fields.
        var v1Params = {}
        if (params.on !== undefined) {
            v1Params.on = params.on.on !== undefined ? params.on.on : params.on
        }
        if (params.dimming !== undefined) {
            v1Params.bri = HueConv.percentToBri(params.dimming.brightness)
        }

        request("PUT", "lights/" + id + "/state", v1Params, null)
    }

    function setLightColor(id, hue, sat) {
        // Hue v1 expects hue 0-65535 and sat 0-254.
        var hueValue = HueConv.hue01ToV1(hue)
        var satValue = HueConv.sat01ToV1(sat)

        request("PUT", "lights/" + id + "/state", {
            "hue": hueValue,
            "sat": satValue
        }, null)
    }

    function setLightTemperature(id, kelvin) {
        // Hue expects mireds, clamped to the bridge's supported range.
        var mired = HueConv.kelvinToMired(kelvin)

        request("PUT", "lights/" + id + "/state", {
            "ct": mired
        }, null)
    }

    function toggleAll(state) {
        if (!lightsModel) return

            for (var i = 0; i < lightsModel.count; i++) {
                var id = lightsModel.get(i).id
                request("PUT", "lights/" + id + "/state", { "on": state }, null)
                // Optimistic update keeps the UI responsive.
                lightsModel.setProperty(i, "on", state)
            }

            if (roomsModel) {
                for (var j = 0; j < roomsModel.count; j++) {
                    roomsModel.setProperty(j, "on", state)
                }
            }

            allLightsOn = state
    }

    function updateAllLightsOn() {
        _recomputeAllLightsOn()
    }

    function _recomputeAllLightsOn() {
        if (!lightsModel || lightsModel.count === 0) {
            allLightsOn = false
            return
        }

        var allOn = true
        for (var i = 0; i < lightsModel.count; i++) {
            if (!lightsModel.get(i).on) {
                allOn = false
                break
            }
        }
        allLightsOn = allOn
    }

}
