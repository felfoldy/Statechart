//
//  Statechart.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import Foundation
import LogTools

@Observable
class Statechart<Context> {
    typealias Node = State<Context>
    typealias Edge = Transition<Context>
    
    var name: String
    
    /// All states in the state chart.
    var states: [Node.ID : Node]
    
    var transitions: [Node.ID : [Edge]]
    
    /// Index of the first state to become active.
    var entryId: Node.ID
    
    var activeState: Node

    private let log: Logger
    
    init?(name: String,
          states: [Node],
          transitions: [Node.ID : [Edge]],
          entryId: Node.ID) {
        let states = Dictionary(grouping: states, by: \.id)
            .compactMapValues(\.first)

        guard let entry = states[entryId] else {
            return nil
        }

        self.name = name
        self.states = states
        self.transitions = transitions
        self.entryId = entryId
        activeState = entry
        log = Logger(subsystem: "com.felfoldy.Statechart", category: name)
    }
    
    func enter(_ context: Context) {
        guard let state = states[entryId] else {
            log.fault("Missing entry state: \(entryId).")
            assertionFailure("Missing entry state.")
            return
        }
        log.trace("Enter statechart: [\(name)] with state: [\(state.name)]")
        
        activeState = state
        activeState.enter(context)
    }
    
    func update(_ context: inout Context) {
        if let nextId = nextState(&context) {
            // Check if the state exists.
            guard let next = states[nextId] else {
                log.fault("Missing state: \(nextId).")
                assertionFailure("Missing state.")
                return
            }
            
            // Update activeState.
            log.trace("Update active state: [\(activeState.name)] -> [\(next.name)]")
            activeState.exit(context)
            activeState = next
            activeState.enter(context)
        }

        activeState.update(context)
    }
    
    func exit(_ context: Context) {
        log.trace("Exit statechart: [\(name)]")
        activeState.exit(context)
    }
    
    private func nextState(_ context: inout Context) -> Node.ID? {
        var visited: Set<Node.ID> = []
        var currentId: Node.ID = activeState.id

        checkLoop: while true {
            // Check for infinite loop.
            if visited.contains(currentId) {
                log.fault("Infinite transition loop detected at [\(currentId)].")
                assertionFailure("Infinite transition loop.")
                return nil
            }

            // Check for outgoing transitions.
            guard let transitions = transitions[currentId], !transitions.isEmpty else {
                log.error("There is no outgoing state from: \(currentId).")
                return visited.isEmpty ? nil : currentId
            }
            
            // Check conditions.
            for transition in transitions where transition.condition(&context) {
                log.trace("Transition from [\(currentId)] to [\(transition.target)]")

                visited.insert(currentId)
                currentId = transition.target
                NotificationCenter.default.postStateTransition(transition)
                continue checkLoop
            }
            
            // If visited stays empty that means we found no transition.
            return visited.isEmpty ? nil : currentId
        }
    }
}
