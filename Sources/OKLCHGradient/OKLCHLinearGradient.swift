import SwiftUI

public struct OKLCHLinearGradient: ShapeStyle {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchLinearGradient(
            .boundingRect,
            .colorArray(colors),
            .float2(startPoint.x, startPoint.y),
            .float2(endPoint.x, endPoint.y)
        )
    }
}
