//
//  StateBuilder.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-22.
//

struct TransitionBuilder<Context> {
    let target: String
    let condition: (inout Context) -> Bool
    
    init(target: String, condition: @escaping (inout Context) -> Bool) {
        self.target = target
        self.condition = condition
    }
    
    func makeTransition(source: String) -> any Transition<Context> {
        AnyTransition(source: source, target: target, condition)
    }
}

/// A builder that constructs states and transitions for a state machine declaratively.
@resultBuilder
public struct StateBuilder<Context>: StateBuildable {
    let state: any StateNode<Context>
    var transitions: [TransitionBuilder<Context>] = []
    var enters: [StateFunction<Context>] = []
    var updates: [StateFunction<Context>] = []
    var exits: [StateFunction<Context>] = []

    /// Creates a new `StateBuilder` with the given name and optional nested states.
    ///
    /// - Note: If states are provided in the builder. This state will become a sub state machine.
    /// - Parameters:
    ///   - name: The name of the state.
    ///   - builder: A closure that builds nested states. Default is empty.
    public init(
        _ name: String,
        @StateBuilder<Context> _ builder: () -> [StateBuilder<Context>] = { [] }
    ) {
        let group = builder()
        
        if group.isEmpty {
            state = AnyState(name)
        } else {
            state = StateMachine<Context>(
                name: name,
                states: group.map(\.composedState),
                transitions: group.flatMap { $0.buildTransitions() },
                entryId: group[0].state.name
            )
        }
    }
    
    /// Creates a new `StateBuilder` from an existing `MachineState`.
    ///
    /// - Parameter state: An existing state conforming to `MachineState`.
    public init(_ state: any StateNode<Context>) {
        self.state = state
    }
    
    /// Returns itself.
    public var asStateBuilder: StateBuilder<Context> {
        self
    }

    public var composedState: any StateNode<Context> {
        if enters.isEmpty, updates.isEmpty, exits.isEmpty {
            return state
        }
        
        return state.join(with: AnyState(
            state.name,
            enter: { context in
                enters.forEach { $0(&context) }
            },
            update: { context in
                updates.forEach { $0(&context) }
            },
            exit: { context in
                exits.forEach { $0(&context) }
            }
        ))
    }
    
    func buildTransitions() -> [any Transition<Context>] {
        transitions.map { transition in
            transition.makeTransition(source: state.name)
        }
    }
    
    // MARK: Result builder descriptions.
    
    public static func buildBlock(_ states: [StateBuilder<Context>]...) -> [StateBuilder<Context>] {
        states.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: StateBuilder<Context>) -> [StateBuilder<Context>] {
        [expression]
    }
    
    public static func buildExpression(_ expression: any StateNode<Context>) -> [StateBuilder<Context>] {
        [StateBuilder(expression)]
    }
}

/// A protocol that represents an entity capable of being converted to a `StateBuilder`.
public protocol StateBuildable {
    associatedtype Context

    /// Converts the conforming instance to a `StateBuilder`.
    var asStateBuilder: StateBuilder<Context> { get }
}

// MARK: - Modifiers

public extension StateBuildable {
    func modify(modifier: (inout StateBuilder<Context>) -> Void) -> StateBuilder<Context> {
        var newState = asStateBuilder
        modifier(&newState)
        return newState
    }
    
    /// Adds transition from the state to a target and transitions when the given condition returns true.
    ///
    /// - Parameters:
    ///   - target: target to transition.
    ///   - condition: condition to check for transitioning.
    func transition(
        to target: String,
        when condition: @escaping (inout Context) -> Bool = { _ in false }
    ) -> StateBuilder<Context> {
        modify { builder in
            builder.transitions.append(
                TransitionBuilder(target: target, condition: condition)
            )
        }
    }
    
    func enter(_ function: @escaping StateFunction<Context>) -> StateBuilder<Context> {
        modify { builder in
            builder.enters.append(function)
        }
    }
    
    func update(_ function: @escaping StateFunction<Context>) -> StateBuilder<Context> {
        modify { builder in
            builder.updates.append(function)
        }
    }
    
    func exit(_ function: @escaping StateFunction<Context>) -> StateBuilder<Context> {
        modify { builder in
            builder.exits.append(function)
        }
    }
    
    func map<SourceContext>(_ transform: @escaping (SourceContext) -> Context) -> StateBuilder<SourceContext> {
        StateBuilder(ContextMapState(transform: transform, targetState: asStateBuilder.composedState))
    }
}

public extension StateBuilder where Context: StringProtocol {
    /// Adds a transition that occurs when the context matches the target state's name.
    ///
    /// - Note: This helper function is useful for prototyping. In complex systems, the `Context` is likely not a string.
    /// - Parameter target: The target state's name to transition to.
    /// - Returns: A new `StateBuilder` instance with the transition added.
    func transition(on target: String) -> Self {
        transition(to: target) { $0 == target }
    }
}

public extension StateMachine {
    /// Creates a state machine declaratively with a `StateBuilder` expression.
    ///
    /// - Parameters:
    ///   - name: Name of the state machine.
    ///   - builder: `StateBuilder` expression.
    convenience init(
        _ name: String,
        @StateBuilder<Context> _ builder: () -> [StateBuilder<Context>]
    ) {
        let states = builder()
        
        self.init(
            name: name,
            states: states.map(\.composedState),
            transitions: states.flatMap { $0.buildTransitions() },
            entryId: states.first?.state.name ?? ""
        )
    }
}
