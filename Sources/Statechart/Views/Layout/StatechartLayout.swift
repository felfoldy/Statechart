//
//  StatechartLayout.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

private struct NodeIdentifierValueKey: LayoutValueKey {
    static let defaultValue: String? = nil
}

struct StatechartLayout<Context>: Layout {
    @Binding var model: StatechartViewModel<Context>
    let layoutMaker: any StatechartLayoutMaker

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutCache) -> CGSize {
        subviews
            .compactMap { view -> CGRect? in
                guard let id = view[NodeIdentifierValueKey.self],
                      let rect = cache.rects[id] else {
                    return nil
                }

                return rect
            }
            .reduce(CGRect.zero) { result, rect in
                result.union(rect)
            }
            .size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutCache) {
        for view in subviews {
            guard let id = view[NodeIdentifierValueKey.self],
                  let offset = cache.rects[id]?.origin else {
                continue
            }

            let newOffset = CGPoint(x: bounds.minX + offset.x,
                                    y: bounds.minY + offset.y)

            view.place(at: newOffset, proposal: proposal)
        }
    }
    
    func makeCache(subviews: Subviews) -> StatechartLayoutCache {
        if let cache = model.layout {
            return cache
        }

        let stateDimensions = subviews.compactMap { view -> (String, CGSize)? in
            guard let id = view[NodeIdentifierValueKey.self] else {
                return nil
            }
            
            let size = view.sizeThatFits(.unspecified)
            return (id, size)
        }
        
        let cache = layoutMaker.make(stateDimensions: stateDimensions,
                                     spacing: model.spacing)
        model.layout = cache
        return cache
    }
}

extension View {
    func layoutStateID(_ id: String) -> some View {
        layoutValue(key: NodeIdentifierValueKey.self, value: id)
    }
}
