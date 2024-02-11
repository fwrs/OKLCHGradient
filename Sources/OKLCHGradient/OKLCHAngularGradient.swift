import SwiftUI

public struct OKLCHAngularGradient: ShapeStyle, View {
    let colors: [Color]
    let center: UnitPoint
    let startAngle: Angle
    let endAngle: Angle
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchAngularGradient(
            .boundingRect,
            .colorArray(colors),
            .float2(center.x, center.y),
            .float(startAngle.radians),
            .float(endAngle.radians)
        )
    }
}
