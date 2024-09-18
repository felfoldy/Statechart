//
//  StateEditor.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

@Observable
class StateGraphEditorModel<Context> {
    var graph: StateGraph<Context>
    var layout: StateGraphLayoutDescription<Context>
    var anchorTranslation: (String, CGPoint)?
    
    init(graph: StateGraph<Context>) {
        self.graph = graph
        layout = .stack(graph: graph)
    }
}

struct StateGraphEditor<Context, NodeContent: View>: View {
    @SwiftUI.State var model: StateGraphEditorModel<Context>
    let stateView: (State<Context>) -> NodeContent
    
    var graph: StateGraph<Context> { model.graph }
    
    var nodes: [State<Context>] {
        graph.states.values.sorted(by: { $0.name < $1.name })
    }
    
    init(model: StateGraphEditorModel<Context>, @ViewBuilder stateView: @escaping (State<Context>) -> NodeContent) {
        _model = .init(initialValue: model)
        self.stateView = stateView
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            StateGraphLayout(description: $model.layout) {
                ForEach(nodes) { state in
                    StateView(layout: $model.layout, state: state, stateView: stateView)
                }
            }
            .environment(\.activeStateId, graph.activeState.id)
            .padding(40)
            .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
                ForEach(model.layout.transitions) { transition in
                    TransitionView(transition: transition, anchors: anchors)
                }
            }
        }
    }
}

extension StateGraphEditor {
    init(graph: StateGraph<Context>,
         @ViewBuilder stateView: @escaping (State<Context>) -> NodeContent) {
        self.init(model: .init(graph: graph), stateView: stateView)
    }
}

struct StateView<Context, NodeContent: View>: View {
    @Binding var layout: StateGraphLayoutDescription<Context>
    
    let state: State<Context>
    let stateView: (State<Context>) -> NodeContent
    
    @SwiftUI.State var translation: CGSize = .zero
    
    var body: some View {
        stateView(state)
            .setBoundsAnchor(for: state.id)
            // Move stateView.
            .offset(translation)
            .simultaneousGesture(
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

#Preview {
    struct Context {}
    
    class DrawableStateGraph: StateGraph<Context> {
        init?() {
            super.init(
                name: "Graph",
                states: [
                    .empty("Default"),
                    .empty("Other"),
                ],
                transitions: [
                    "Default" : [
                        Transition<Context>(base: "Default", target: "Other", condition: { _ in false })
                    ],
                ],
                entryId: "Default"
            )
        }
    }
    
    return NavigationStack {
        let graph = DrawableStateGraph()!
        
        StateGraphEditor(graph: graph) { state in
            Button(state.name) {
                
            }
            .buttonStyle(.stateNode)
        }
        .background(.gray.opacity(0.5))
        .navigationTitle(graph.name)
    }
}
