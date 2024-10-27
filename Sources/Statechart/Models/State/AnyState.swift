//
//  AnyState.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-10-27.
//

public typealias StateFunction<Context> = (inout Context) -> Void

public struct AnyState<Context>: StateNode {
    public let name: String
    private let enter: StateFunction<Context>?
    private let update: StateFunction<Context>?
    private let exit: StateFunction<Context>?
    
    public init(_ name: String,
                enter: StateFunction<Context>? = nil,
                update: StateFunction<Context>? = nil,
                exit: StateFunction<Context>? = nil) {
        self.name = name
        self.enter = enter
        self.update = update
        self.exit = exit
    }
    
    public func enter(context: inout Context) {
        enter?(&context)
    }
    
    public func update(context: inout Context) {
        update?(&context)
    }
    
    public func exit(context: inout Context) {
        exit?(&context)
    }
}
