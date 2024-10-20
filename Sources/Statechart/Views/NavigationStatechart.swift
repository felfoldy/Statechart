//
//  NavigationStatechart.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-22.
//

import SwiftUI

struct StatechartContentView<Context>: View {
    let stateMachine: StateMachine<Context>
    let stateSelected: (any StateNode<Context>) -> Void

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            StatechartView(stateMachine: stateMachine) { state in
                stateSelected(state)
            }
            .padding(20)
        }
        .background(.gray.opacity(0.8))
        .navigationTitle(stateMachine.name)
    }
}

public struct NavigationStatechart<Context>: View {
    @State var stateMachine: StateMachine<Context>
    let stateSelected: (any StateNode<Context>) -> Void
    
    public init(stateMachine: StateMachine<Context>, stateSelected: @escaping (any StateNode<Context>) -> Void = { _ in }) {
        self.stateMachine = stateMachine
        self.stateSelected = stateSelected
    }
    
    public var body: some View {
        NavigationStack {
            StatechartContentView(stateMachine: stateMachine,
                                  stateSelected: stateSelected)
        }
    }
}

#Preview {
    typealias State = StateBuilder<String>
    
    let stateMachine = StateMachine("root") {
        State("grounded") {
            State("idle")
                .transition(on: "run")
            
            State("run")
                .transition(on: "idle")
        }
        .transition(on: "airborne")
        
        State("airborne") {
            State("jump")
                .transition(on: "fall")
            
            State("fall")
            
            EmptyState("empty")
                .join(with: StateMachine("empty", { EmptyState("call") }))
        }
        .transition(on: "grounded")
    }
    
    return NavigationStatechart(stateMachine: stateMachine) { state in
        stateMachine.update(state.name)
    }
    .onAppear {
        stateMachine.enter("")
    }
}
