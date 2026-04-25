//
//  CGPoint+Helpers.swift
//  archero-echo
//
//  Vector math utilities for CGPoint.
//

import CoreGraphics

extension CGPoint {

    /// Distance to another point.
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt((x - point.x) * (x - point.x) + (y - point.y) * (y - point.y))
    }

    /// Length (magnitude) of the vector.
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }

    /// Returns a normalized (unit-length) version of this vector.
    func normalized() -> CGPoint {
        let len = length
        guard len > 0 else { return .zero }
        return CGPoint(x: x / len, y: y / len)
    }

    // MARK: - Operators

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    static func * (scalar: CGFloat, point: CGPoint) -> CGPoint {
        return point * scalar
    }
}
