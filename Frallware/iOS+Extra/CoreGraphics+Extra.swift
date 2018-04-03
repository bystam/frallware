//
//  Copyright © 2018 Frallware. All rights reserved.
//

import CoreGraphics

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}

public extension CGVector {

    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        return CGVector(dx: dx / length, dy: dy / length)
    }
}
