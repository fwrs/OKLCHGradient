import SwiftUI

public struct OKLCHAngularGradient: ShapeStyle, View, Sendable {
    let stops: [Gradient.Stop]
    let center: UnitPoint
    let startAngle: Angle
    let endAngle: Angle
    
    public init(colors: [Color], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
        self.stops = colors.evenlyDistributedStops
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
    
    public init(stops: [Gradient.Stop], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
        self.stops = stops
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
    
    public init(gradient: Gradient, center: UnitPoint, startAngle: Angle = .zero, endAngle: Angle = .zero) {
        self.stops = gradient.stops
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
    
    public init(colors: [Color], center: UnitPoint, angle: Angle = .zero) {
        self.stops = colors.evenlyDistributedStops
        self.center = center
        self.startAngle = angle
        self.endAngle = angle + .degrees(360)
    }
    
    public init(stops: [Gradient.Stop], center: UnitPoint, angle: Angle = .zero) {
        self.stops = stops
        self.center = center
        self.startAngle = angle
        self.endAngle = angle + .degrees(360)
    }
    
    public init(gradient: Gradient, center: UnitPoint, angle: Angle = .zero) {
        self.stops = gradient.stops
        self.center = center
        self.startAngle = angle
        self.endAngle = angle + .degrees(360)
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchAngularGradient(
            .boundingRect,
            .colorArray(stops.map(\.color)),
            .floatArray(stops.map(\.location).map(Float.init)),
            .float2(center.x, center.y),
            .float(startAngle.radians),
            .float(endAngle.radians)
        )
    }
}

public extension ShapeStyle where Self == OKLCHAngularGradient {
    static func oklchAngularGradient(_ gradient: Gradient, center: UnitPoint, startAngle: Angle, endAngle: Angle) -> OKLCHAngularGradient {
        OKLCHAngularGradient(gradient: gradient, center: center, startAngle: startAngle, endAngle: endAngle)
    }
    
    static func oklchAngularGradient(colors: [Color], center: UnitPoint, startAngle: Angle, endAngle: Angle) -> OKLCHAngularGradient {
        OKLCHAngularGradient(colors: colors, center: center, startAngle: startAngle, endAngle: endAngle)
    }
    
    static func oklchAngularGradient(stops: [Gradient.Stop], center: UnitPoint, startAngle: Angle, endAngle: Angle) -> OKLCHAngularGradient {
        OKLCHAngularGradient(stops: stops, center: center, startAngle: startAngle, endAngle: endAngle)
    }
}

public extension ShapeStyle where Self == OKLCHAngularGradient {
    static func oklchConicGradient(_ gradient: Gradient, center: UnitPoint, angle: Angle = .zero) -> OKLCHAngularGradient {
        OKLCHAngularGradient(gradient: gradient, center: center, angle: angle)
    }
    
    static func oklchConicGradient(colors: [Color], center: UnitPoint, angle: Angle = .zero) -> OKLCHAngularGradient {
        OKLCHAngularGradient(colors: colors, center: center, angle: angle)
    }
    
    static func oklchConicGradient(stops: [Gradient.Stop], center: UnitPoint, angle: Angle = .zero) -> OKLCHAngularGradient {
        OKLCHAngularGradient(stops: stops, center: center, angle: angle)
    }
}
