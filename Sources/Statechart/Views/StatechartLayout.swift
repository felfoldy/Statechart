//
//  StatechartLayout.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

struct TransitionDescription: Identifiable {
    enum AnchorUnit {
        case top, bottom, left, right
    }
    
    var id: String { "\(base) -> \(target)" }
    
    var base: String
    var target: String
    private(set) var anchor: AnchorUnit?
    
    mutating func anchored(to anchor: AnchorUnit) {
        if self.anchor != anchor {
            self.anchor = anchor
        }
    }
}

struct StatechartLayoutCache {
    var offsets: [String : CGPoint]

    init(offsets: [String : CGPoint]) {
        self.offsets = offsets
    }
    
    mutating func move(node: String, by translation: CGSize) {
        let oldOffset = offsets[node] ?? .zero
        let newOffset = CGPoint(x: oldOffset.x + translation.width,
                                y: oldOffset.y + translation.height)
        
        offsets[node] = newOffset
        
        // Reposition the offsets to the top-left.
        let minX = offsets.values.map(\.x).min() ?? 0
        let minY = offsets.values.map(\.y).min() ?? 0
        
        if minX == 0 && minY == 0 { return }
        
        for (key, value) in offsets {
            offsets[key] = CGPoint(x: value.x - minX, y: value.y - minY)
        }
    }
}

protocol StatechartLayoutMaker {
    var stateDimensions: [(name: String, size: CGSize)] { get }
    var spacing: CGFloat { get }
    
    func make() -> StatechartLayoutCache
}

struct StackLayoutMaker: StatechartLayoutMaker {
    let stateDimensions: [(name: String, size: CGSize)]
    let spacing: CGFloat
    
    func make() -> StatechartLayoutCache {
        var offsets = [String : CGPoint]()
        
        var offset: CGFloat = 0
        
        for (name, size) in stateDimensions {
            offsets[name] = CGPoint(x: offset, y: 0)
            offset += size.width + spacing
        }

        return .init(offsets: offsets)
    }
}

private struct NodeIdentifierValueKey: LayoutValueKey {
    static let defaultValue: String? = nil
}

extension View {
    func layoutStateID(_ id: String) -> some View {
        layoutValue(key: NodeIdentifierValueKey.self, value: id)
    }
}

struct StatechartLayout<Context>: Layout {
    @Binding var model: StatechartEditorModel<Context>

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutCache) -> CGSize {
        subviews
            .compactMap { view -> CGRect? in
                guard let id = view[NodeIdentifierValueKey.self],
                      let offset = cache.offsets[id] else {
                    return nil
                }

                let size = view.sizeThatFits(.infinity)

                return CGRect(origin: offset, size: size)
            }
            .reduce(CGRect.zero) { result, rect in
                result.union(rect)
            }
            .size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutCache) {
        for view in subviews {
            guard let id = view[NodeIdentifierValueKey.self],
                  let offset = cache.offsets[id] else {
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
        
        let cache = StackLayoutMaker(stateDimensions: stateDimensions, spacing: 20)
            .make()
        model.layout = cache
        return cache
    }
}
