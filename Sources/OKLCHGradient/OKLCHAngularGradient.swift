import SwiftUI

public struct OKLCHAngularGradient: ShapeStyle, View {
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
    
    public init(gradient: Gradient, center: UnitPoint, startAngle: Angle, endAngle: Angle) {
        self.stops = gradient.stops
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
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
