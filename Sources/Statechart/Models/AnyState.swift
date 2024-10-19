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

    /// Default empty implemention.
    func enter(context: inout Context) {}

    /// Default empty implemention.
    func update(context: inout Context) {}

    /// Default empty implemention.
    func exit(context: inout Context) {}
}

public typealias StateFunction<Context> = (inout Context) -> Void
