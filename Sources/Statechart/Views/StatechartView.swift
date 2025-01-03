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
class StatechartViewModel {
    var stateMachine: any StateMachineProtocol
    let spacing: CGFloat
    var layout: StateMachineLayoutCache?
    var transitions: [TransitionDescription]
    
    init(stateMachine: any StateMachineProtocol, spacing: CGFloat) {
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

struct SubStatechartView: View {
    @State var model: StatechartViewModel
        
    init(stateMachine: any StateMachineProtocol) {
        model = .init(stateMachine: stateMachine, spacing: 32)
    }
    
    var body: some View {
        let activeStateId = model.stateMachine.activeState?.name

        StateMachineLayout(model: $model, layoutMaker: model.stateMachine.layout) {
            ForEach(model.stateMachine.anyStates, id: \.id) { state in
                if let stateMachine = state.asStateMachine {
                    StateView(state.name) {
                        SubStatechartView(stateMachine: stateMachine)
                    }
                    .stateViewEnvironment(model: $model, state: state)
                } else {
                    StateView(state.name)
                        .stateViewEnvironment(model: $model, state: state)
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

public struct StatechartView: View {
    @State var model: StatechartViewModel
    let selectedState: (any StateNode) -> Void
    
    @Namespace private var transition
    
    public var body: some View {
        let activeStateId = model.stateMachine.activeState?.id
        StateMachineLayout(model: $model, layoutMaker: model.stateMachine.layout) {
            ForEach(model.stateMachine.anyStates, id: \.id) { state in
                if let stateMachine = state.asStateMachine {
                    Button(state.name) {
                        selectedState(state)
                    }
                    .buttonStyle(.detailedState {
                        SubStatechartView(stateMachine: stateMachine)
                    })
                    .contextMenu {
                        NavigationLink("open") {
                            StatechartContentView(stateMachine: stateMachine,
                                                  stateSelected: selectedState)
                        }
                    }
                    .stateViewEnvironment(model: $model, state: state)
                } else {
                    Button(state.name) {
                        selectedState(state)
                    }
                    .buttonStyle(.stateNode)
                    .stateViewEnvironment(model: $model, state: state)
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
    init(stateMachine: any StateMachineProtocol,
         spacing: CGFloat = 40, selectedState: @escaping (any StateNode) -> Void) {
        self.init(
            model: .init(stateMachine: stateMachine, spacing: spacing),
            selectedState: selectedState
        )
    }
}

#Preview {

    NavigationStack {
        let machine = StateMachine<String>("root", layout: .horizontal) {
            StateBuilder("Subgraph", layout: .vertical) {
                StateBuilder("Empty")
                
                StateBuilder("Other")
            }
            .transition(to: "Other")
            
            StateBuilder("Other")
            
            StateBuilder("Other2")
        }
                
        ScrollView([.horizontal, .vertical]) {
            StatechartView(stateMachine: machine) { state in
                
            }
        }
        .background(.gray.opacity(0.8))
    }
}
