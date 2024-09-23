//
//  NavigationStatechart.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-22.
//

import SwiftUI

struct StatechartContentView<Context>: View {
    let stateMachine: StateMachine<Context>
    let stateSelected: (AnyState<Context>) -> Void

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            StatechartView(stateMachine: stateMachine) { state in
                Button(state.name) {
                    stateSelected(state)
                }
                .buttonStyle(.stateNode)
            } subStateMachine: { subMachine in
                NavigationLink(subMachine.name, value: subMachine)
                    .buttonStyle(.detailedState {
                        StatechartView(stateMachine: subMachine) { state in
                            StateView { Text(state.name) }
                        }
                    })
                    .contextMenu {
                        Button("select", systemImage: "scope") {
                            stateSelected(AnyState(subMachine))
                        }
                    }
            }
            .padding(20)
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(stateMachine.name)
    }
}

public struct NavigationStatechart<Context>: View {
    @State var stateMachine: StateMachine<Context>
    let stateSelected: (AnyState<Context>) -> Void
    
    public init(stateMachine: StateMachine<Context>, stateSelected: @escaping (AnyState<Context>) -> Void = { _ in }) {
        self.stateMachine = stateMachine
        self.stateSelected = stateSelected
    }
    
    public var body: some View {
        NavigationStack {
            StatechartContentView(stateMachine: stateMachine,
                                  stateSelected: stateSelected)
                .navigationDestination(for: StateMachine<Context>.self) { stateMachine in
                    StatechartContentView(stateMachine: stateMachine,
                                          stateSelected: stateSelected)
                }
        }
    }
}

#Preview {
    typealias State = StateBuilder<String>
    
    let stateMachine = StateMachine("root") {
        State("grounded") {
            State("idle")
                .transition(to: "run")
            
            State("run")
                .transition(to: "idle")
        }
        .transition(to: "airborne")
        
        State("airborne") {
            State("jump")
                .transition(to: "fall")
            
            State("fall")
                .transition(to: "jump")
        }
        .transition(to: "grounded")
    }
    
    return NavigationStatechart(stateMachine: stateMachine)
}
