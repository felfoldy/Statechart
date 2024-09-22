//
//  StatechartEditor.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

enum NodeAnchor {
    case top, bottom, left, right
}

struct TransitionDescription: Identifiable {
    var id: String { "\(base) -> \(target)" }
    
    var base: String
    var target: String
    private(set) var anchor: NodeAnchor?
    
    mutating func anchored(to anchor: NodeAnchor) {
        if self.anchor != anchor {
            self.anchor = anchor
        }
    }
}

@Observable
class StatechartViewModel<Context> {
    var stateMachine: StateMachine<Context>
    let spacing: CGFloat
    var layout: StateMachineLayoutCache?
    var transitions: [TransitionDescription]
    
    init(stateMachine: StateMachine<Context>, spacing: CGFloat) {
        self.stateMachine = stateMachine
        self.spacing = spacing
        transitions = stateMachine.transitions
            .flatMap(\.value)
            .map { transition in
                TransitionDescription(base: transition.sourceId,
                                      target: transition.targetId)
            }
    }
}

public struct StatechartView<Context,
                      StateContent: View,
                      StateMachineContent: View>: View {
    @State var model: StatechartViewModel<Context>
    let stateView: (AnyState<Context>) -> StateContent
    let stateMachineView: (StateMachine<Context>) -> StateMachineContent
    
    @Environment(\.statechartLayoutMaker) private var layoutMaker
    
    public var body: some View {
        let activeStateId = model.stateMachine.activeState?.id
        StateMachineLayout(model: $model, layoutMaker: layoutMaker) {
            ForEach(model.stateMachine.states) { state in
                if let stateMachine = state.stateMachine, StateMachineContent.self != EmptyView.self {
                    stateMachineView(stateMachine).modifier(
                        StateViewModifier(model: $model, state: state)
                    )
                } else {
                    stateView(state).modifier(
                        StateViewModifier(model: $model, state: state)
                    )
                }
            }
        }
        .environment(\.entryStateId, model.stateMachine.entryId)
        .environment(\.activeStateId, activeStateId)
        .animation(.bouncy, value: activeStateId)
        .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
            ForEach($model.transitions) { transition in
                TransitionView(transition: transition, anchors: anchors)
            }
        }
    }
}

public extension StatechartView {
    init(
        stateMachine: StateMachine<Context>,
        spacing: CGFloat = 40,
        @ViewBuilder stateView: @escaping (AnyState<Context>) -> StateContent,
        @ViewBuilder subStateMachine: @escaping (StateMachine<Context>) -> StateMachineContent
    ) {
        self.init(
            model: .init(stateMachine: stateMachine, spacing: spacing),
            stateView: stateView,
            stateMachineView: subStateMachine
        )
    }
}

public extension StatechartView where StateMachineContent == EmptyView {
    init(
        stateMachine: StateMachine<Context>,
        spacing: CGFloat = 40,
        @ViewBuilder stateView: @escaping (AnyState<Context>) -> StateContent
    ) {
        self.init(
            model: .init(stateMachine: stateMachine, spacing: spacing),
            stateView: stateView,
            stateMachineView: { _ in EmptyView() }
        )
    }
}

struct Context {
    var selectable: String?
}

#Preview {
    let stateMachine = StateMachine<Context>(
        name: "Chart",
        states: [
            AnyState(
                StateMachine(name: "Subgraph",
                             states: [.state("empty"), .state("other")],
                             transitions: [],
                             entryId: "empty")
            ),
            
                .state("Default"),
            .state("Other"),
            .state("Other2"),
        ],
        transitions: [
            .transition("Other", "Default", .constant(false)),
            .transition("Default", "Other") { $0.selectable == "Other" },
            .transition("Other2", "Default") { $0.selectable == "Default" },
            .transition("Other", "Other2", .constant(true)),
        ],
        entryId: "Default"
    )
    
    var context = Context()
    
    return NavigationStack {
        ScrollView([.horizontal, .vertical]) {
            StatechartView(stateMachine: stateMachine, spacing: 20) { state in
                Button(state.name) {
                    var context = Context(selectable: state.name)
                    stateMachine.update(context: &context)
                }
            } subStateMachine: { stateMachine in
                Button(stateMachine.name) {}
                    .buttonStyle(.detailedState {
                        StatechartView(stateMachine: stateMachine) { state in
                            StateView { Text(state.name) }
                        }
                    })
            }
            .onAppear {
                stateMachine.enter(context: &context)
            }
            .padding()
            .buttonStyle(.stateNode)
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(stateMachine.name)
    }
}
