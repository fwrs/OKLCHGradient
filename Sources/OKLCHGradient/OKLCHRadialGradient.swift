import SwiftUI

public struct OKLCHRadialGradient: ShapeStyle, View {
    let colors: [Color]
    let center: UnitPoint
    let startRadius: CGFloat
    let endRadius: CGFloat
    
    public init(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
        self.colors = colors
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderLibrary.bundle(Bundle.module).oklchRadialGradient(
            .boundingRect,
            .colorArray(colors),
            .float2(center.x, center.y),
            .float(startRadius),
            .float(endRadius)
        )
    }
}
