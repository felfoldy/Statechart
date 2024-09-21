//
//  StatechartEditor.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

@Observable
class StatechartEditorModel<Context> {
    var stateMachine: StateMachine<Context>
    var layout: StatechartLayoutCache?
    var transitions: [TransitionDescription]
    
    init(chart: StateMachine<Context>) {
        self.stateMachine = chart
        transitions = chart.transitions.values
            .flatMap { $0 }
            .map { transition in
                TransitionDescription(base: transition.base,
                                      target: transition.target)
            }
    }
}

struct StatechartView<Context, NodeContent: View>: View {
    @SwiftUI.State var model: StatechartEditorModel<Context>
    let stateView: (AnyState<Context>) -> NodeContent
    
    var chart: StateMachine<Context> { model.stateMachine }
    
    var nodes: [AnyState<Context>] {
        chart.states.values.sorted(by: { $0.name < $1.name })
    }
    
    init(model: StatechartEditorModel<Context>, @ViewBuilder stateView: @escaping (AnyState<Context>) -> NodeContent) {
        _model = .init(initialValue: model)
        self.stateView = stateView
    }
    
    var body: some View {
        StatechartLayout(model: $model) {
            ForEach(nodes) { state in
                StateView(model: $model, state: state, stateView: stateView)
            }
        }
        .environment(\.activeStateId, chart.activeState.id)
        .animation(.bouncy, value: chart.activeState.id)
        .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
            ForEach($model.transitions) { transition in
                TransitionView(transition: transition, anchors: anchors)
            }
        }
    }
}

extension StatechartView {
    init(chart: StateMachine<Context>,
         @ViewBuilder stateView: @escaping (AnyState<Context>) -> NodeContent) {
        self.init(model: .init(chart: chart), stateView: stateView)
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
    
    return NavigationStack {
        let chart = StateMachine<Context>(
            name: "Chart",
            states: [
                AnyState(
                    StateMachine(name: "ASubstates",
                                 states: [.state("empty"), .state("other")],
                                 transitions: [:],
                                 entryId: "empty")
                ),
                
                .state("Default"),
                .state("Other"),
                .state("Other2"),
            ],
            transitions: [
                "Default" : [
                    Transition("Default", "Other", condition: Context.Condition(target: "Other")),
                    Transition("Default", "Other2", condition: Context.Condition(target: "Other2")),
                ],
                "Other" : [
                    Transition("Other", "Default", condition: Context.Condition(target: "Default")),
                    Transition("Other", "Other2", condition:.constant(true)),
                ],
                "Other2" : [
                    Transition("Other2", "Default", condition: Context.Condition(target: "Default")),
                ],
            ],
            entryId: "Default"
        )

        ScrollView([.horizontal, .vertical]) {
            StatechartView(chart: chart) { state in
                Button {
                    var context = Context(selectable: state.name)
                    chart.update(context: &context)
                } label: {
                    VStack {
                        Text(state.name)
                        
                        if let stateMachine = state.stateMachine {
                            StatechartView(chart: stateMachine) { state in
                                Button(state.name) {}
                                    .buttonStyle(.stateNode)
                            }
                            .disabled(true)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.1))
                            }
                        }
                    }
                }
                .buttonStyle(.stateNode)
            }.padding()
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(chart.name)
    }
}
