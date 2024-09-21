//
//  SubStateMachineView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

struct SubStateMachineView<Context>: View {
    let stateMachine: StateMachine<Context>
    
    var body: some View {
        VStack {
            Text(stateMachine.name)
            
            StatechartView(stateMachine: stateMachine) { state in
                StateView {
                    Text(state.name)
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.8))
            }
        }
    }
}
