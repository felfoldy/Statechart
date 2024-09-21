//
//  StateViewModifier.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import SwiftUI

struct StateViewModifier<Context>: ViewModifier {
    @Binding var model: StatechartViewModel<Context>
    let state: AnyState<Context>
    
    @State private var translation: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            // Sets anhor preference.
            .setBoundsAnchor(for: state.id)
            // Add anchor arrows to the edges.
            .stateAnchorsView(stateId: state.id,
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
                            model.layout?.move(node: state.id,
                                               by: value.translation)
                        }
                    }
            )
            // Add set id for layout.
            .layoutStateID(state.id)
            // Set other environment values.
            .environment(\.stateId, state.id)
            .environment(\.stateTranslation, translation != .zero)
    }
}
