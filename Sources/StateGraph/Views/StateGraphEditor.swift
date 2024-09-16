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
    
    init(graph: StateGraph<Context>) {
        self.graph = graph
        
        layout = StateGraphLayoutDescription(graph: graph)
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
            .offset(translation)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        translation = value.translation
                    }
                    .onEnded { value in
                        withAnimation {
                            translation = .zero
                            layout.finalize(key: state.id,
                                            translation: value.translation)
                        }
                    }
            )
            .background {
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    // Left anchor.
                    AnchorHandleView()
                        .offset(y: size.height / 2)
                    
                    // Right anchor.
                    AnchorHandleView()
                        .offset(x: size.width,
                                y: size.height / 2)
                    
                    // Top anchor.
                    AnchorHandleView()
                        .offset(x: size.width / 2)
                    
                    // Bottom anchor.
                    AnchorHandleView()
                        .offset(x: size.width / 2,
                                y: size.height)
                }
                .opacity(translation == .zero ? 1 : 0)
            }
            .layoutStateID(state.id)
            .environment(\.stateId, state.id)
            .environment(\.stateTranslation, translation != .zero)
    }
}

struct AnchorHandleView: View {
    @SwiftUI.State private var isHovered: Bool = false
    
    var body: some View {
        Button {} label: {
            Circle()
                .frame(width: 20, height: 20)
                .padding(8)
        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .buttonStyle(.plain)
        .offset(x: -18, y: -18)
        .opacity(isHovered ? 1 : 0.2)
        .highPriorityGesture(
            DragGesture()
                .onChanged { value in
                    print(value.location)
                }
                .onEnded { value in
                    print("ended")
                    isHovered = false
                }
        )
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
