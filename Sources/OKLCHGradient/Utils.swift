import SwiftUI

extension Array where Element == Color {
    var evenlyDistributedStops: [Gradient.Stop] {
        enumerated().map { offset, color in
            Gradient.Stop(color: color, location: CGFloat(offset) / CGFloat(count - 1))
        }
    }
}
