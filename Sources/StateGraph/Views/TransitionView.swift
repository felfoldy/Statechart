//
//  TransitionView.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-16.
//

import SwiftUI

struct TransitionView: View {
    let transition: TransitionDescription
    let anchors: [String : Anchor<CGRect>]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let baseAnchor = anchors[transition.base.name],
                      let targetAnchor = anchors[transition.target.name] else {
                    return
                }
                
                let baseRect = geometry[baseAnchor]
                let targetRect = geometry[targetAnchor]
                
                let base = transition.base.anchor(in: baseRect)
                let target = transition.target.anchor(in: targetRect)
                
                let midX = (base.x + target.x) / 2
                let midY = (base.y + target.y) / 2
                
                let control1: CGPoint = switch transition.base.anchor {
                case .left, .right: CGPoint(x: midX, y: base.y)
                case .bottom, .top: CGPoint(x: base.x, y: midY)
                }
                
                let control2: CGPoint = switch transition.target.anchor {
                case .left, .right: CGPoint(x: midX, y: target.y)
                case .bottom, .top: CGPoint(x: target.x, y: midY)
                }
                
                path.move(to: base)
                path.addCurve(
                    to: target,
                    control1: control1,
                    control2: control2
                )
            }
            .stroke(.secondary,
                    style: StrokeStyle(lineWidth: 4, lineJoin: .round))
        }
    }
}
