//
//  StatechartEditor.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

@Observable
class StatechartEditorModel<Context> {
    var chart: Statechart<Context>
    var layout: StatechartLayoutDescription
    var anchorTranslation: (String, CGPoint)?
    
    init(chart: Statechart<Context>) {
        self.chart = chart
        layout = .stack(chart: chart)
    }
}

struct StatechartEditor<Context, NodeContent: View>: View {
    @SwiftUI.State var model: StatechartEditorModel<Context>
    let stateView: (State<Context>) -> NodeContent
    
    var chart: Statechart<Context> { model.chart }
    
    var nodes: [State<Context>] {
        chart.states.values.sorted(by: { $0.name < $1.name })
    }
    
    init(model: StatechartEditorModel<Context>, @ViewBuilder stateView: @escaping (State<Context>) -> NodeContent) {
        _model = .init(initialValue: model)
        self.stateView = stateView
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            StatechartLayout(description: $model.layout) {
                ForEach(nodes) { state in
                    StateView(layout: $model.layout, state: state, stateView: stateView)
                }
            }
            .environment(\.activeStateId, chart.activeState.id)
            .animation(.bouncy, value: chart.activeState.id)
            .padding(40)
            .backgroundPreferenceValue(BoundsAnchorPreferenceKey.self) { anchors in
                ForEach($model.layout.transitions) { transition in
                    TransitionView(transition: transition, anchors: anchors)
                }
            }
        }
    }
}

extension StatechartEditor {
    init(chart: Statechart<Context>,
         @ViewBuilder stateView: @escaping (State<Context>) -> NodeContent) {
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
    
    class PreviewStatechart: Statechart<Context> {
        init?() {
            super.init(
                name: "Chart",
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
        let chart = PreviewStatechart()!
        
        StatechartEditor(chart: chart) { state in
            Button(state.name) {
                var context = Context(selectable: state.name)
                chart.update(&context)
            }
            .buttonStyle(.stateNode)
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(chart.name)
    }
}
