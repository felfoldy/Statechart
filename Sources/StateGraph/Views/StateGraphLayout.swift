//
//  StateGraphLayout.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

enum AnchorType: CaseIterable {
    case top, bottom, left, right
}

struct NodeAnchorDescription {
    let name: String
    let anchor: AnchorType
    
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
    
    var base: NodeAnchorDescription
    var target: NodeAnchorDescription
}

struct StateGraphLayoutDescription<Context> {
    var offsets: [String : CGPoint]
    var transitions: [TransitionDescription]

    init(offsets: [String : CGPoint], transitions: [TransitionDescription]) {
        self.offsets = offsets
        self.transitions = transitions
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

extension StateGraphLayoutDescription {
    static func stack(graph: StateGraph<Context>) -> Self {
        let mappedOffsets = graph.states.keys
            .sorted(by: <)
            .enumerated()
            .map { index, value in
                (name: value, x: index * 200)
            }

        let offsets = Dictionary(grouping: mappedOffsets, by: \.name)
            .mapValues { values in
                CGPoint(x: values[0].x, y: 0)
            }
        
        let transitions = graph.transitions.values
            .flatMap { $0 }
            .map { transition in
                TransitionDescription(
                    base: NodeAnchorDescription(name: transition.base, anchor: .right),
                    target: NodeAnchorDescription(name: transition.target, anchor: .left)
                )
            }

        return .init(offsets: offsets, transitions: transitions)
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
            
            let newOffset = CGPoint(x: bounds.minX + offset.x,
                                    y: bounds.minY + offset.y)
            
            view.place(at: newOffset, proposal: proposal)
        }
    }
}
