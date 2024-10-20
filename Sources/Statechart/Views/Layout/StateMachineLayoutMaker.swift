//
//  StateMachineLayoutMaker.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import Foundation
import enum SwiftUI.Axis

public protocol StateMachineLayoutMaker {
    func make(stateDimensions: [(name: String, size: CGSize)],
              spacing: CGFloat) -> StateMachineLayoutCache
}

// MARK: - Stack

public struct StackLayoutMaker: StateMachineLayoutMaker {
    let direction: Axis
    
    public func make(stateDimensions: [(name: String, size: CGSize)],
                     spacing: CGFloat) -> StateMachineLayoutCache {
        var rects = [String : CGRect]()
        var offset: CGFloat = 0
        
        for (name, size) in stateDimensions {
            switch direction {
            case .horizontal:
                rects[name] = CGRect(origin: CGPoint(x: offset, y: 0),
                                     size: size)
                offset += size.width + spacing
            case .vertical:
                rects[name] = CGRect(origin: CGPoint(x: 0, y: offset),
                                     size: size)
                offset += size.height + spacing
            }
        }

        return StateMachineLayoutCache(rects: rects)
    }
}

public extension StateMachineLayoutMaker where Self == StackLayoutMaker {
    static func stack(_ direction: Axis) -> Self {
        StackLayoutMaker(direction: direction)
    }
}

// MARK: - Radial

public struct RadialLayoutMaker: StateMachineLayoutMaker {
    public func make(stateDimensions: [(name: String, size: CGSize)],
                     spacing: CGFloat) -> StateMachineLayoutCache {
        let N = stateDimensions.count
        
        let diagonals = stateDimensions
            .map { _, size in
                sqrt(size.width * size.width + size.height * size.height)
            }
        
        var maxNodeDistance: CGFloat = 0.0

        for i in 0..<N {
            let diagonal1 = diagonals[i]
            let diagonal2 = diagonals[(i + 1) % N]
            let halfDiagonal = (diagonal1 + diagonal2) / 2
            maxNodeDistance = max(halfDiagonal + spacing, maxNodeDistance)
        }
        
        let radius = maxNodeDistance / (2 * sin(.pi / Double(N)))

        let angle = (2 * .pi) / CGFloat(N)

        var rects = [String: CGRect]()

        for (index, (name, size)) in stateDimensions.enumerated() {
            let angle = angle * CGFloat(index) + .pi
            let x = radius * cos(angle) - size.width / 2
            let y = radius * sin(angle) - size.height / 2
            let origin = CGPoint(x: x, y: y)
            let rect = CGRect(origin: origin, size: size)
            rects[name] = rect
        }

        var cache = StateMachineLayoutCache(rects: rects)
        cache.reposition()
        return cache
    }
}

public extension StateMachineLayoutMaker where Self == RadialLayoutMaker {
    static var radial: Self {
        RadialLayoutMaker()
    }
}