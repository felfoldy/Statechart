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

struct StatechartLayoutDescription {
    var offsets: [String : CGPoint]

    init<Context>(offsets: [String : CGPoint], chart: StateMachine<Context>) {
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

extension StatechartLayoutDescription {
    static func stack<Context>(chart: StateMachine<Context>,
                               spacing: CGFloat = 200) -> Self {
        let mappedOffsets = chart.states.keys
            .sorted(by: <)
            .enumerated()
            .map { index, value in
                (name: value, x: CGFloat(index) * spacing)
            }

        let offsets = Dictionary(grouping: mappedOffsets, by: \.name)
            .mapValues { values in
                CGPoint(x: values[0].x, y: 0)
            }

        return .init(offsets: offsets, chart: chart)
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
    let stateMachine: StateMachine<Context>
    @Binding var description: StatechartLayoutDescription?

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutDescription) -> CGSize {
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
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout StatechartLayoutDescription) {
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
    
    func makeCache(subviews: Subviews) -> StatechartLayoutDescription {
        if let layoutDescription = description {
            return layoutDescription
        } else {
            let description = StatechartLayoutDescription.stack(chart: stateMachine)
            self.description = description
            return description
        }
    }
}
