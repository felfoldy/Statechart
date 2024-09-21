//
//  StateView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import SwiftUI

struct StateView<Context, NodeContent: View>: View {
    @Binding var model: StatechartEditorModel<Context>
    let state: AnyState<Context>
    let stateView: (AnyState<Context>) -> NodeContent
    
    @SwiftUI.State private var translation: CGSize = .zero
    
    var body: some View {
        stateView(state)
            .setBoundsAnchor(for: state.id)
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
                        withAnimation {
                            translation = .zero
                            model.layout?.move(node: state.id, by: value.translation)
                        }
                    }
            )
            .layoutStateID(state.id)
            .environment(\.stateId, state.id)
            .environment(\.stateTranslation, translation != .zero)
    }
}
