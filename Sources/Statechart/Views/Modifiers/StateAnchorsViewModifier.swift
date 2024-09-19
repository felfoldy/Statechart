//
//  StateAnchorsViewModifier.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import SwiftUI

struct StateAnchorsViewModifier: ViewModifier {
    let stateId: String
    let transitions: [TransitionDescription]
    
    @SwiftUI.State private var animationSource: String?
    
    func body(content: Content) -> some View {
        content.background {
            let transitions = transitions
                .filter { $0.target == stateId }
            
            let anchors = Array(Set(
                transitions.compactMap(\.anchor)
            ))
            
            let animateAnchor = transitions
                .first { $0.base == animationSource }?.anchor
            
            ForEach(anchors, id: \.self) { anchor in
                Group {
                    switch anchor {
                    case .top:
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 16))
                            .offset(x: 0, y: -12)
                            .frame(maxHeight: .infinity, alignment: .top)
                    case .bottom:
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 16))
                            .offset(x: 0, y: +12)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    case .left:
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 16))
                            .offset(x: -12, y: 0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    case .right:
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.system(size: 16))
                            .offset(x: +12, y: 0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .foregroundStyle(anchor == animateAnchor ? AnyShapeStyle(.link) : AnyShapeStyle(.selection))
            }
            .onReceive(
                NotificationCenter.default
                    .stateTransitionPublisher()
            ) { base, target in
                guard target == stateId else {
                    return
                }
                
                withAnimation(.interactiveSpring) {
                    animationSource = base
                }
                
                withAnimation(.easeOut.delay(0.5)) {
                    animationSource = nil
                }
            }
        }
    }
}

extension View {
    func stateAnchorsView(stateId: String, transitions: [TransitionDescription]) -> some View {
        modifier(StateAnchorsViewModifier(stateId: stateId, transitions: transitions))
    }
}
