//
//  NavigationStatechart.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-22.
//

import SwiftUI

struct StatechartContentView: View {
    let stateMachine: any StateMachineProtocol
    let stateSelected: (any StateNode) -> Void

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            StatechartView(stateMachine: stateMachine) { state in
                stateSelected(state)
            }
            .padding(20)
        }
        .navigationTitle(stateMachine.name)
    }
}

public struct NavigationStatechart: View {
    @State var stateMachine: any StateMachineProtocol
    let stateSelected: (any StateNode) -> Void
    
    public init(stateMachine: any StateMachineProtocol, stateSelected: @escaping (any StateNode) -> Void = { _ in }) {
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
    typealias State = StateBuilder
    
    let stateMachine = StateMachine<String>("root", layout: .horizontal) {
        State("grounded", layout: .vertical) {
            State("idle")
                .transition(on: "run")
                .enter { print("enter: \($0)") }
            
            State("run")
                .update {
                    print("update: \($0)")
                }
                .transition(on: "idle")
        }
        .transition(on: "airborne")
        
        State("airborne", layout: .vertical) {
            State<Int>("jump")
                .enter { print("enters: \($0)") }
                .map(\.count)
                .transition(on: "fall")
            
            State("fall")
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
