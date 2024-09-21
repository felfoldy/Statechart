//
//  StatechartEditor.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

struct TransitionDescription: Identifiable {
    enum AnchorUnit {
        case top, bottom, left, right
    }
    
    var id: String { "\(base) -> \(target)" }
    
    var base: String
    var target: String
    private(set) var anchor: AnchorUnit?
    
    mutating func anchored(to anchor: AnchorUnit) {
        if self.anchor != anchor {
            self.anchor = anchor
        }
    }
}

@Observable
class StatechartViewModel<Context> {
    var stateMachine: StateMachine<Context>
    let spacing: CGFloat
    var layout: StatechartLayoutCache?
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

struct StatechartView<Context, NodeContent: View>: View {
    @State var model: StatechartViewModel<Context>
    let stateView: (AnyState<Context>) -> NodeContent
    
    var chart: StateMachine<Context> { model.stateMachine }
    
    var nodes: [AnyState<Context>] {
        chart.states.values.sorted(by: { $0.name < $1.name })
    }

    @Environment(\.statechartLayoutMaker) private var layoutMaker
    
    init(model: StatechartViewModel<Context>, @ViewBuilder stateView: @escaping (AnyState<Context>) -> NodeContent) {
        _model = .init(initialValue: model)
        self.stateView = stateView
    }
    
    var body: some View {
        StatechartLayout(model: $model, layoutMaker: layoutMaker) {
            ForEach(nodes) { state in
                stateView(state)
                    .modifier(StateViewModifier(model: $model,
                                                state: state))
            }
        }
        .environment(\.activeStateId, chart.activeState?.id)
        .animation(.bouncy, value: chart.activeState?.id)
        .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
            ForEach($model.transitions) { transition in
                TransitionView(transition: transition, anchors: anchors)
            }
        }
    }
}

extension StatechartView {
    init(stateMachine: StateMachine<Context>, spacing: CGFloat = 40,
         @ViewBuilder stateView: @escaping (AnyState<Context>) -> NodeContent) {
        self.init(model: .init(stateMachine: stateMachine, spacing: spacing),
                  stateView: stateView)
    }
}

#Preview {
    struct Context {
        var selectable: String?
    }

    let stateMachine = StateMachine<Context>(
        name: "Chart",
        states: [
            AnyState(
                StateMachine(name: "ASubstates",
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
            StatechartView(stateMachine: stateMachine) { state in
                Button {
                    var context = Context(selectable: state.name)
                    stateMachine.update(context: &context)
                } label: {
                    VStack {
                        Text(state.name)
                        
                        if let stateMachine = state.stateMachine {
                            StatechartView(stateMachine: stateMachine, spacing: 20) { state in
                                Button(state.name) {}
                                    .buttonStyle(.stateNode)
                            }
                            .disabled(true)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.1))
                            }
                            .statechartLayout(.stack(.vertical))
                        }
                    }
                }
                .buttonStyle(.stateNode)
            }
            .onAppear {
                stateMachine.enter(context: &context)
            }
            .padding()
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(stateMachine.name)
    }
}
