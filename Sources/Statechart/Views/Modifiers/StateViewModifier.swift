//
//  StateViewModifier.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import SwiftUI

struct StateViewModifier<Context>: ViewModifier {
    @Binding var model: StatechartViewModel<Context>
    let state: any StateNode<Context>
    
    @State private var translation: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            // Sets anhor preference.
            .setBoundsAnchor(for: state.name)
            // Add anchor arrows to the edges.
            .stateAnchorsView(stateId: state.name,
                              transitions: model.transitions)
            // StateView translation.
            .offset(translation)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                    }
                    .onEnded { value in
                        // Update layout with the new translation.
                        withAnimation {
                            translation = .zero
                            model.layout?.move(node: state.name,
                                               by: value.translation)
                        }
                    }
            )
            // Add set id for layout.
            .layoutStateID(state.name)
            // Set other environment values.
            .environment(\.stateId, state.name)
            .environment(\.stateTranslation, translation != .zero)
    }
}

extension View {
    func stateViewEnvironment<Context>(model: Binding<StatechartViewModel<Context>>, state: any StateNode<Context>) -> some View {
        modifier(StateViewModifier(model: model, state: state))
    }
}
