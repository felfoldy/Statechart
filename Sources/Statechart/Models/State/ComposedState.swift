//
//  ComposedState.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-10-27.
//

public struct ComposedState<Context>: StateNode {
    public let name: String
    public let states: [any StateNode<Context>]
    
    public var asStateMachine: (any StateMachineProtocol)? {
        states.compactMap(\.asStateMachine).first
    }
    
    public init(_ name: String, states: [any StateNode<Context>]) {
        self.name = name
        self.states = states
    }
    
    public func enter(context: inout Context) {
        states.forEach { $0.enter(context: &context) }
    }
    
    public func update(context: inout Context) {
        states.forEach { $0.update(context: &context) }
    }
    
    public func exit(context: inout Context) {
        states.forEach { $0.exit(context: &context) }
    }
}

extension StateNode {
    func join(with states: (any StateNode<Context>)...) -> some StateNode<Context> {
        ComposedState(name, states: [self] + states)
    }
}
