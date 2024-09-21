//
//  StatechartLayoutMaker.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import Foundation
import enum SwiftUI.Axis

public protocol StatechartLayoutMaker {
    func make(stateDimensions: [(name: String, size: CGSize)],
              spacing: CGFloat) -> StatechartLayoutCache
}

// MARK: - Stack

public struct StackLayoutMaker: StatechartLayoutMaker {
    let direction: Axis
    
    public func make(stateDimensions: [(name: String, size: CGSize)],
                     spacing: CGFloat) -> StatechartLayoutCache {
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

        return StatechartLayoutCache(rects: rects)
    }
}

public extension StatechartLayoutMaker where Self == StackLayoutMaker {
    static func stack(_ direction: Axis) -> Self {
        StackLayoutMaker(direction: direction)
    }
}
