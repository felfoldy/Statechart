//
//  StateGraphLayout.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

struct NodeAnchor {
    enum Anchor {
        case top, bottom, left, right
    }
    
    let name: String
    let anchor: Anchor
    
    func anchor(in rect: CGRect) -> CGPoint {
        switch anchor {
        case .top: CGPoint(x: rect.midX, y: rect.minY)
        case .bottom: CGPoint(x: rect.midX, y: rect.maxY)
        case .left: CGPoint(x: rect.minX, y: rect.midY)
        case .right: CGPoint(x: rect.maxX, y: rect.midY)
        }
    }
}

struct TransitionDescription: Identifiable {
    var id: Set<String> { [base.name, target.name] }
    
    var base: NodeAnchor
    var target: NodeAnchor
}

struct StateGraphLayoutDescription<Context> {
    var offsets: [String : CGPoint]
    var transitions: [TransitionDescription]

    init(graph: StateGraph<Context>) {
        let offsets = graph.states.keys
            .sorted(by: <)
            .enumerated()
            .map { index, value in
                (name: value, x: index * 200)
            }

        self.offsets = Dictionary(grouping: offsets, by: \.name)
            .mapValues { values in
                CGPoint(x: values[0].x, y: 0)
            }
        
        transitions = graph.transitions.values
            .flatMap { $0 }
            .map { transition in
                TransitionDescription(
                    base: NodeAnchor(name: transition.base, anchor: .right),
                    target: NodeAnchor(name: transition.target, anchor: .left)
                )
            }
    }
    
    mutating func finalize(key: String, translation: CGSize) {
        let oldOffset = offsets[key] ?? .zero
        let newOffset = CGPoint(x: oldOffset.x + translation.width, y: oldOffset.y + translation.height)
        
        offsets[key] = newOffset
        
        if let min = offsets.values.map(\.x).min(), min != 0 {
            for (key, value) in offsets {
                offsets[key]?.x = value.x - min
            }
        }
        
        if let min = offsets.values.map(\.y).min(), min != 0 {
            for (key, value) in offsets {
                offsets[key]?.y = value.y - min
            }
        }
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

struct StateGraphLayout<Context>: Layout {
    @Binding var description: StateGraphLayoutDescription<Context>
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        subviews
            .compactMap { view -> CGRect? in
                guard let id = view[NodeIdentifierValueKey.self],
                      let offset = description.offsets[id] else {
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
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for view in subviews {
            guard let id = view[NodeIdentifierValueKey.self],
                  let offset = description.offsets[id] else {
                continue
            }
            
            let newOffset = CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y)
            
            view.place(at: newOffset, proposal: proposal)
        }
    }
}
