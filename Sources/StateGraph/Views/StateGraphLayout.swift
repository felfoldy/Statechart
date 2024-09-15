//
//  StateGraphLayout.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

struct StateGraphLayoutDescription<Context> {
    var offsets: [String : CGPoint]

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
        let rect = subviews
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
        
        print(rect)

        return CGSize(width: rect.width, height: rect.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for view in subviews {
            guard let id = view[NodeIdentifierValueKey.self],
                  let offset = description.offsets[id] else {
                continue
            }
            
            view.place(at: offset, proposal: proposal)
        }
    }
}
