function briToPercent(bri) {
    return Math.round((bri / 254) * 100);
}

function percentToBri(percent) {
    return Math.round((percent / 100) * 254);
}

function hue01ToV1(hue) {
    return Math.round(hue * 65535);
}

function sat01ToV1(sat) {
    return Math.round(sat * 254);
}

function kelvinToMired(kelvin) {
    return Math.round(1000000 / kelvin);
}

// New: Approximate color temperature to RGB (simplified Kelvin to RGB conversion)
function ctToRgb(ct) {
    var temp = 1000000 / ct;  // Mired to Kelvin
    temp = temp / 100;
    var red, green, blue;

    if (temp <= 66) {
        red = 255;
        green = temp;
        green = 99.4708025861 * Math.log(green) - 161.1195681661;
        blue = (temp <= 19) ? 0 : (temp - 10);
        blue = 138.5177312231 * Math.log(blue) - 305.0447927307;
    } else {
        red = temp - 60;
        red = 329.698727446 * Math.pow(red, -0.1332047592);
        green = temp - 60;
        green = 288.1221695283 * Math.pow(green, -0.0755148492);
        blue = 255;
    }

    red = clamp(red, 0, 255);
    green = clamp(green, 0, 255);
    blue = clamp(blue, 0, 255);

    return Qt.rgba(red / 255, green / 255, blue / 255, 1.0);
}

// New: Convert CIE xy to RGB (assuming sRGB, simplified with gamma correction)
function xyToRgb(x, y, bri) {
    var z = 1.0 - x - y;
    var Y = bri;  // Luminance
    var X = (Y / y) * x;
    var Z = (Y / y) * z;

    var r = X * 1.656492 - Y * 0.354851 - Z * 0.255038;
    var g = -X * 0.707196 + Y * 1.655397 + Z * 0.036152;
    var b = X * 0.051713 + Y * 0.121364 + Z * 1.011530;

    // Gamma correction approximation
    r = (r > 0.0031308) ? (1.055 * Math.pow(r, (1 / 2.4)) - 0.055) : 12.92 * r;
    g = (g > 0.0031308) ? (1.055 * Math.pow(g, (1 / 2.4)) - 0.055) : 12.92 * g;
    b = (b > 0.0031308) ? (1.055 * Math.pow(b, (1 / 2.4)) - 0.055) : 12.92 * b;

    r = clamp(r, 0, 1);
    g = clamp(g, 0, 1);
    b = clamp(b, 0, 1);

    return Qt.rgba(r, g, b, 1.0);
}

// Helper clamp function
function clamp(value, min, max) {
    return Math.min(Math.max(value, min), max);
}
