//
//  StatechartLayoutCache.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import Foundation

public struct StatechartLayoutCache {
    var rects: [String : CGRect]

    init(rects: [String : CGRect]) {
        self.rects = rects
    }
    
    mutating func move(node: String, by translation: CGSize) {
        let oldOffset = rects[node]?.origin ?? .zero
        let newOffset = CGPoint(x: oldOffset.x + translation.width,
                                y: oldOffset.y + translation.height)
        
        rects[node]?.origin = newOffset
        
        // Reposition the offsets to the top-left.
        let minX = rects.values.map(\.minX).min() ?? 0
        let minY = rects.values.map(\.minY).min() ?? 0
        
        if minX == 0 && minY == 0 { return }
        
        for (key, value) in rects {
            rects[key]?.origin = CGPoint(x: value.minX - minX,
                                         y: value.minY - minY)
        }
    }
}
