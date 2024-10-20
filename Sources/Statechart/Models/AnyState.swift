//
//  AnyState.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import Foundation

public protocol MachineState<Context>: Identifiable, StateBuildable {
    associatedtype Context
    
    var id: String { get }
    var name: String { get }

    func enter(context: inout Context)
    func update(context: inout Context)
    func exit(context: inout Context)
}

public extension MachineState {
    var id: String { name }
    
    func asStateBuilder() -> StateBuilder<Context> {
        StateBuilder(self)
    }
    
    var asStateMachine: StateMachine<Context>? {
        if let stateMachine = self as? StateMachine<Context> {
            return stateMachine
        }
        
        if let composedState = self as? ComposedState<Context> {
            return composedState.states
                .compactMap { $0.asStateMachine }.first
        }

        return nil
    }

    /// Default empty implemention.
    func enter(context: inout Context) {}

    /// Default empty implemention.
    func update(context: inout Context) {}

    /// Default empty implemention.
    func exit(context: inout Context) {}
}

// MARK: - Default implementations

public struct EmptyState<Context>: MachineState {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}

public struct ComposedState<Context>: MachineState {
    public let name: String
    public let states: [any MachineState<Context>]
    
    public init(_ name: String, states: [any MachineState<Context>]) {
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

extension MachineState {
    func join(with states: (any MachineState<Context>)...) -> some MachineState<Context> {
        ComposedState(name, states: [self] + states)
    }
}

public struct SubContextState<SourceContext, TargetContext>: MachineState {
    public typealias Context = SourceContext
    
    let transform: (SourceContext) -> TargetContext
    let targetState: any MachineState<TargetContext>
    
    public var name: String { targetState.name }
    
    public func enter(context: inout SourceContext) {
        var target = transform(context)
        targetState.enter(context: &target)
    }
    
    public func update(context: inout SourceContext) {
        var target = transform(context)
        targetState.update(context: &target)
    }
    
    public func exit(context: inout SourceContext) {
        var target = transform(context)
        targetState.exit(context: &target)
    }
}

extension MachineState {
    public func mapContext<SourceContext>(_ transform: @escaping (SourceContext) -> Context) -> some MachineState<SourceContext> {
        SubContextState(transform: transform, targetState: self)
    }
}
