//
//  StateNode.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-10-27.
//

public protocol StateNode<Context>: Identifiable, StateBuildable {
    associatedtype Context
    
    var id: String { get }
    var name: String { get }
    var asStateMachine: (any StateMachineProtocol)? { get }

    func enter(context: inout Context)
    func update(context: inout Context)
    func exit(context: inout Context)
}

public extension StateNode {
    var id: String { name }
    
    func asStateBuilder() -> StateBuilder<Context> {
        StateBuilder(self)
    }
    
    var asStateMachine: (any StateMachineProtocol)? {
        return nil
    }

    /// Default empty implemention.
    func enter(context: inout Context) {}

    /// Default empty implemention.
    func update(context: inout Context) {}

    /// Default empty implemention.
    func exit(context: inout Context) {}

    func enter(_ context: Context) {
        var context = context
        enter(context: &context)
    }

    func update(_ context: Context) {
        var context = context
        update(context: &context)
    }

    func exit(_ context: Context) {
        var context = context
        exit(context: &context)
    }
}
