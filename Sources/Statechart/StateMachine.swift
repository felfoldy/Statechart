//
//  StateMachine.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import Foundation
import LogTools

private let log = Logger(subsystem: "com.felfoldy.Statechart", category: "StateMachine")

@Observable
public class StateMachine<Context>: MachineState {
    public typealias State = AnyState<Context>
    public typealias Transition = AnyTransition<Context>

    public let name: String
    public var states: StateCollection<Context>
    public var transitions: [State.ID : [Transition]]
    
    /// Name of the first state to become active on enter.
    public var entryId: State.ID

    public var activeState: State?
        
    init(name: String,
         states: [State],
         transitions: [Transition],
         entryId: State.ID) {
        let states = states.isEmpty ? [.state("state")] : states

        self.name = name
        self.transitions = Dictionary(grouping: transitions, by: \.sourceId)
        self.entryId = entryId
        self.states = StateCollection(states)
    }
    
    public func enter(context: inout Context) {
        guard let state = states[entryId] else {
            log.fault("Missing entry state: \(entryId).")
            assertionFailure("Missing entry state.")
            return
        }
        
        log.trace("Enter statechart: [\(name)] with state: [\(state.name)]")
        
        activeState = state
        activeState?.enter(context: &context)
    }
    
    public func update(context: inout Context) {
        guard let state = activeState else { return }
        
        if let nextId = nextState(from: state.id, &context) {
            // Check if the state exists.
            guard let next = states[nextId] else {
                log.fault("Missing state: \(nextId).")
                assertionFailure("Missing state.")
                return
            }
            
            // Update activeState.
            log.trace("Update active state: [\(state.name)] -> [\(next.name)]")
            state.exit(context: &context)
            activeState = next
            activeState?.enter(context: &context)
        }

        activeState?.update(context: &context)
    }
    
    public func exit(context: inout Context) {
        log.trace("Exit statechart: [\(name)]")
        activeState?.exit(context: &context)
        activeState = nil
    }
    
    private func nextState(from activeStateID: State.ID, _ context: inout Context) -> State.ID? {
        var visited: Set<State.ID> = []
        var currentID: State.ID = activeStateID

        checkLoop: while true {
            // Check for infinite loop.
            if visited.contains(currentID) {
                log.fault("Infinite transition loop detected at [\(currentID)].")
                assertionFailure("Infinite transition loop.")
                return nil
            }

            // Check for outgoing transitions.
            guard let transitions = transitions[currentID], !transitions.isEmpty else {
                log.error("There is no outgoing state from: \(currentID).")
                return visited.isEmpty ? nil : currentID
            }
            
            // Check conditions.
            for transition in transitions where transition.condition(context: &context) {
                log.trace("Transition from [\(currentID)] to [\(transition.targetId)]")

                visited.insert(currentID)
                currentID = transition.targetId
                NotificationCenter.default.postStateTransition(transition)
                continue checkLoop
            }
            
            // If visited stays empty that means we found no transition.
            return visited.isEmpty ? nil : currentID
        }
    }
}
