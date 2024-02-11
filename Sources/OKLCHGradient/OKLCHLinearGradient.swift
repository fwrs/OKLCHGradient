import SwiftUI

public struct OKLCHLinearGradient: ShapeStyle, View, Sendable {
    let stops: [Gradient.Stop]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.stops = colors.evenlyDistributedStops
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public init(stops: [Gradient.Stop], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.stops = stops
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.stops = gradient.stops
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchLinearGradient(
            .boundingRect,
            .colorArray(stops.map(\.color)),
            .floatArray(stops.map(\.location).map(Float.init)),
            .float2(startPoint.x, startPoint.y),
            .float2(endPoint.x, endPoint.y)
        )
    }
}

public extension ShapeStyle where Self == OKLCHLinearGradient {
    static func oklchLinearGradient(_ gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) -> OKLCHLinearGradient {
        OKLCHLinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
    }
    
    static func oklchLinearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> OKLCHLinearGradient {
        OKLCHLinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    static func oklchLinearGradient(stops: [Gradient.Stop], startPoint: UnitPoint, endPoint: UnitPoint) -> OKLCHLinearGradient {
        OKLCHLinearGradient(stops: stops, startPoint: startPoint, endPoint: endPoint)
    }
}
