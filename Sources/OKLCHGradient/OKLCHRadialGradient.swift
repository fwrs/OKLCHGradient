import SwiftUI

public struct OKLCHRadialGradient: ShapeStyle, View {
    let stops: [Gradient.Stop]
    let center: UnitPoint
    let startRadius: CGFloat
    let endRadius: CGFloat
    
    public init(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
        self.stops = colors.evenlyDistributedStops
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }
    
    public init(stops: [Gradient.Stop], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
        self.stops = stops
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }
    
    public init(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
        self.stops = gradient.stops
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchRadialGradient(
            .boundingRect,
            .colorArray(stops.map(\.color)),
            .floatArray(stops.map(\.location).map(Float.init)),
            .float2(center.x, center.y),
            .float(startRadius),
            .float(endRadius)
        )
    }
}
