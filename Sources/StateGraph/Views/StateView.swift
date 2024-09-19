//
//  StateView.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import SwiftUI

struct StateView<Context, NodeContent: View>: View {
    @Binding var layout: StateGraphLayoutDescription<Context>
    
    let state: State<Context>
    let stateView: (State<Context>) -> NodeContent
    
    @SwiftUI.State private var translation: CGSize = .zero
    
    var body: some View {
        stateView(state)
            .setBoundsAnchor(for: state.id)
            .stateAnchorsView(stateId: state.id,
                              transitions: layout.transitions)
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
                            layout.move(node: state.id, by: value.translation)
                        }
                    }
            )
            .layoutStateID(state.id)
            .environment(\.stateId, state.id)
            .environment(\.stateTranslation, translation != .zero)
    }
}
