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
            .animation(.bouncy, value: graph.activeState.id)
            .padding(40)
            .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
                ForEach($model.layout.transitions) { transition in
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

#Preview {
    struct Context {
        var selectable: String
        
        struct Condition: TransitionCondition {
            let target: String
            
            func evaluate(context: inout Context) -> Bool {
                context.selectable == target
            }
        }
    }
    
    class DrawableStateGraph: StateGraph<Context> {
        init?() {
            super.init(
                name: "Graph",
                states: [
                    .empty("Default"),
                    .empty("Other"),
                    .empty("Other2"),
                ],
                transitions: [
                    "Default" : [
                        Transition("Default", "Other", condition: Context.Condition(target: "Other"))
                    ],
                    "Other" : [
                        Transition("Other", "Default", condition: .constant(false)),
                        Transition("Other", "Other2", condition: .constant(true)),
                    ],
                    "Other2" : [
                        Transition("Other2", "Default") { context in
                            context.selectable == "Default"
                        }
                    ]
                ],
                entryId: "Default"
            )
        }
    }
    
    return NavigationStack {
        let graph = DrawableStateGraph()!
        
        StateGraphEditor(graph: graph) { state in
            Button(state.name) {
                var context = Context(selectable: state.name)
                graph.update(&context)
            }
            .buttonStyle(.stateNode)
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(graph.name)
    }
}
