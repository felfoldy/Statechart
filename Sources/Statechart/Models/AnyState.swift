//
//  AnyState.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import Foundation

public typealias StateFunction<Context> = (inout Context) -> Void

public protocol MachineState: Identifiable, StateBuildable {
    associatedtype Context
    
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
}

public struct AnyState<Context>: MachineState {
    public let name: String
    
    private let enterFunction: StateFunction<Context>?
    private let updateFunction: StateFunction<Context>?
    private let exitFunction: StateFunction<Context>?
    let stateMachine: StateMachine<Context>?
    
    public init<State: MachineState>(_ state: State) where State.Context == Context {
        self.name = state.name
        self.enterFunction = state.enter
        self.updateFunction = state.update
        self.exitFunction = state.exit
        stateMachine = state as? StateMachine<Context>
    }

    public init(_ name: String,
                enter: StateFunction<Context>? = nil,
                update: StateFunction<Context>? = nil,
                exit: StateFunction<Context>? = nil) {
        self.name = name
        enterFunction = enter
        updateFunction = update
        exitFunction = exit
        stateMachine = nil
    }
    
    public func enter(context: inout Context) {
        enterFunction?(&context)
    }
    
    public func update(context: inout Context) {
        updateFunction?(&context)
    }
    
    public func exit(context: inout Context) {
        exitFunction?(&context)
    }
}

extension AnyState {
    public static func state(_ name: String) -> Self {
        AnyState(name)
    }
}
