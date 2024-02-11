#include <metal_stdlib>

using namespace metal;

half sRGBComponentToLinearsRGBComponent(half component) {
    if (component <= 0.04045h) {
        return component / 12.92h;
    } else {
        return pow((component + 0.055h) / 1.055h, 2.4h);
    }
}

half4 sRGBToLinearsRGB(half4 sRGB) {
    return half4(
        sRGBComponentToLinearsRGBComponent(sRGB.x),
        sRGBComponentToLinearsRGBComponent(sRGB.y),
        sRGBComponentToLinearsRGBComponent(sRGB.z),
        sRGB.w
    );
}

half4 linearsRGBToOKLAB(half4 sRGB) {
    half l = 0.4122214708 * sRGB.x + 0.5363325363 * sRGB.y + 0.0514459929 * sRGB.z;
    half m = 0.2119034982 * sRGB.x + 0.6806995451 * sRGB.y + 0.1073969566 * sRGB.z;
    half s = 0.0883024619 * sRGB.x + 0.2817188376 * sRGB.y + 0.6299787005 * sRGB.z;
    
    half l_ = pow(l, 1.0h / 3.0h);
    half m_ = pow(m, 1.0h / 3.0h);
    half s_ = pow(s, 1.0h / 3.0h);
    
    return half4(
        0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
        sRGB.w
    );
}

half4 oklabToOKLCH(half4 oklab) {
    half c = sqrt(pow(oklab.y, 2) + pow(oklab.z, 2));
    half h = atan2(oklab.z, oklab.y) * (180.0h / M_PI_F);
    
    return half4(oklab.x, c, half((int(h) % 360 + 360) % 360), oklab.w);
}

half linearsRGBComponentTosRGBComponent(half component) {
    if (component <= 0.0031308h) {
        return 12.92h * component;
    } else {
        return 1.055h * pow(component, 1.0h / 2.4h) - 0.055h;
    }
}

half4 linearsRGBTosRGB(half4 linearsRGB) {
    return half4(
        linearsRGBComponentTosRGBComponent(linearsRGB.x),
        linearsRGBComponentTosRGBComponent(linearsRGB.y),
        linearsRGBComponentTosRGBComponent(linearsRGB.z),
        linearsRGB.w
    );
}

half4 oklabToLinearsRGB(half4 oklab) {
    half l_ = oklab.x + 0.3963377774h * oklab.y + 0.2158037573h * oklab.z;
    half m_ = oklab.x - 0.1055613458h * oklab.y - 0.0638541728h * oklab.z;
    half s_ = oklab.x - 0.0894841775h * oklab.y - 1.2914855480h * oklab.z;
    
    half l = l_ * l_ * l_;
    half m = m_ * m_ * m_;
    half s = s_ * s_ * s_;
    
    return half4(
        +4.0767416621h * l - 3.3077115913h * m + 0.2309699292h * s,
        -1.2684380046h * l + 2.6097574011h * m - 0.3413193965h * s,
        -0.0041960863h * l - 0.7034186147h * m + 1.7076147010h * s,
        oklab.w
    );
}

half4 oklchToOKLAB(half4 oklch) {
    half hDegrees = isnan(oklch.z) ? 0.0h : (oklch.z * (M_PI_F / 180.0h));
    half a = oklch.y * cos(hDegrees);
    half b = oklch.y * sin(hDegrees);
    return half4(oklch.x, a, b, oklch.w);
}

[[ stitchable ]] half4 oklchLinearGradient(
    float2 position,
    float4 bounds,
    device const half4 *colors,
    int colorCount,
    device const float *stops,
    int stopCount,
    float2 startPosition,
    float2 endPosition
) {
    half2 direction = half2(normalize(endPosition - startPosition));
    half2 distanceFromStart = half2(position - startPosition);
    half2 normalized = half2(distanceFromStart.x / bounds.z, distanceFromStart.y / bounds.w);
    half progress = clamp(dot(normalized, direction), 0.0h, 1.0h);
    progress = clamp(progress, half(stops[0]), half(stops[stopCount - 1]));
    int startIndex = 0;
    int endIndex = stopCount - 1;
    
    for (int i = 0; i < stopCount - 1; ++i) {
        if (progress <= stops[i + 1]) {
            startIndex = i;
            endIndex = i + 1;
            break;
        }
    }
    
    half4 startColorInsRGB = colors[startIndex];
    half4 endColorInsRGB = colors[endIndex];
    half lerpFactor = (progress - stops[startIndex]) / (stops[endIndex] - stops[startIndex]);
    half4 startColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(startColorInsRGB)));
    half4 endColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(endColorInsRGB)));
    
    return linearsRGBTosRGB(oklabToLinearsRGB(oklchToOKLAB(mix(startColorInOKLCH, endColorInOKLCH, lerpFactor))));
}

[[ stitchable ]] half4 oklchRadialGradient(
    float2 position,
    float4 bounds,
    device const half4 *colors,
    int colorCount,
    device const float *stops,
    int stopCount,
    float2 center,
    float startRadius,
    float endRadius
) {
    half2 diff = half2(position.x - bounds.z * center.x, position.y - bounds.w * center.y);
    half distanceFromCenter = length(diff);
    half progress = clamp((distanceFromCenter - half(startRadius)) / half(endRadius - startRadius), 0.0h, 1.0h);
    progress = clamp(progress, half(stops[0]), half(stops[stopCount - 1]));
    int startIndex = 0;
    int endIndex = stopCount - 1;
    
    for (int i = 0; i < stopCount - 1; ++i) {
        if (progress <= stops[i + 1]) {
            startIndex = i;
            endIndex = i + 1;
            break;
        }
    }
    
    half4 startColorInsRGB = colors[startIndex];
    half4 endColorInsRGB = colors[endIndex];
    half lerpFactor = (progress - stops[startIndex]) / (stops[endIndex] - stops[startIndex]);
    half4 startColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(startColorInsRGB)));
    half4 endColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(endColorInsRGB)));
    
    return linearsRGBTosRGB(oklabToLinearsRGB(oklchToOKLAB(mix(startColorInOKLCH, endColorInOKLCH, lerpFactor))));
}

[[ stitchable ]] half4 oklchAngularGradient(
    float2 position,
    float4 bounds,
    device const half4 *colors,
    int colorCount,
    device const float *stops,
    int stopCount,
    float2 center,
    float minAngle,
    float maxAngle
) {
    half2 uv = half2(position.x / bounds.z, position.y / bounds.w);
    half2 diff = half2(center.x - uv.x, center.y - uv.y);
    half angle = atan2(diff.y, diff.x) + M_PI_F;
    half midAngle = (minAngle + maxAngle) / 2.0 + M_PI_F;
    if (angle < minAngle) { angle += 2.0 * M_PI_F; }
    if (angle > maxAngle && angle < midAngle) { angle -= 2.0 * M_PI_F; }
    if (angle > maxAngle && angle > midAngle) { angle -= 4.0 * M_PI_F; }
    if (angle < 0.0) { angle += 2.0 * M_PI_F; }
    half progress = saturate((angle - minAngle) / (maxAngle - minAngle));
    progress = clamp(progress, half(stops[0]), half(stops[stopCount - 1]));
    int startIndex = 0;
    int endIndex = stopCount - 1;
    
    for (int i = 0; i < stopCount - 1; ++i) {
        if (progress <= stops[i + 1]) {
            startIndex = i;
            endIndex = i + 1;
            break;
        }
    }
    
    half4 startColorInsRGB = colors[startIndex];
    half4 endColorInsRGB = colors[endIndex];
    half lerpFactor = (progress - stops[startIndex]) / (stops[endIndex] - stops[startIndex]);
    half4 startColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(startColorInsRGB)));
    half4 endColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(endColorInsRGB)));
    
    return linearsRGBTosRGB(oklabToLinearsRGB(oklchToOKLAB(mix(startColorInOKLCH, endColorInOKLCH, lerpFactor))));
}

[[ stitchable ]] half4 oklchEllipticalGradient(
    float2 position,
    float4 bounds,
    device const half4 *colors,
    int colorCount,
    device const float *stops,
    int stopCount,
    float2 center,
    float startRadiusFraction,
    float endRadiusFraction
) {
    half2 uv = half2(position.x / bounds.z, position.y / bounds.w);
    half2 diff = half2(center.x - uv.x, center.y - uv.y);
    half distanceFromCenter = length(diff);
    half delta = half(endRadiusFraction - startRadiusFraction);
    half progress = clamp((distanceFromCenter - half(startRadiusFraction)) / delta, 0.0h, 1.0h);
    progress = clamp(progress, half(stops[0]), half(stops[stopCount - 1]));
    int startIndex = 0;
    int endIndex = stopCount - 1;
    
    for (int i = 0; i < stopCount - 1; ++i) {
        if (progress <= stops[i + 1]) {
            startIndex = i;
            endIndex = i + 1;
            break;
        }
    }
    
    half4 startColorInsRGB = colors[startIndex];
    half4 endColorInsRGB = colors[endIndex];
    half lerpFactor = (progress - stops[startIndex]) / (stops[endIndex] - stops[startIndex]);
    half4 startColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(startColorInsRGB)));
    half4 endColorInOKLCH = oklabToOKLCH(linearsRGBToOKLAB(sRGBToLinearsRGB(endColorInsRGB)));
    
    return linearsRGBTosRGB(oklabToLinearsRGB(oklchToOKLAB(mix(startColorInOKLCH, endColorInOKLCH, lerpFactor))));
}
