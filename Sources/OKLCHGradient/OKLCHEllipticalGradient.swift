import SwiftUI

public struct OKLCHEllipticalGradient: ShapeStyle, View, Sendable {
    let stops: [Gradient.Stop]
    let center: UnitPoint
    let startRadiusFraction: CGFloat
    let endRadiusFraction: CGFloat
    
    public init(colors: [Color], center: UnitPoint, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat) {
        self.stops = colors.evenlyDistributedStops
        self.center = center
        self.startRadiusFraction = startRadiusFraction
        self.endRadiusFraction = endRadiusFraction
    }
    
    public init(stops: [Gradient.Stop], center: UnitPoint, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat) {
        self.stops = stops
        self.center = center
        self.startRadiusFraction = startRadiusFraction
        self.endRadiusFraction = endRadiusFraction
    }
    
    public init(gradient: Gradient, center: UnitPoint, startRadiusFraction: CGFloat, endRadiusFraction: CGFloat) {
        self.stops = gradient.stops
        self.center = center
        self.startRadiusFraction = startRadiusFraction
        self.endRadiusFraction = endRadiusFraction
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchEllipticalGradient(
            .boundingRect,
            .colorArray(stops.map(\.color)),
            .floatArray(stops.map(\.location).map(Float.init)),
            .float2(center.x, center.y),
            .float(startRadiusFraction),
            .float(endRadiusFraction)
        )
    }
}
