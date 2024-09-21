//
//  Transition.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

public protocol TransitionCondition {
    associatedtype Context

    func evaluate(context: inout Context) -> Bool
}

public struct Transition<Context> {
    public var base: AnyState<Context>.ID
    public var target: AnyState<Context>.ID
    
    let condition: AnyTransitionCondition<Context>
    
    init(_ base: String, _ target: String,
         condition: AnyTransitionCondition<Context>) {
        self.base = base
        self.target = target
        self.condition = condition
    }
    
    public func condition(_ context: inout Context) -> Bool {
        condition.evaluate(context: &context)
    }
}

public struct AnyTransitionCondition<Context>: TransitionCondition {
    private var _condition: (inout Context) -> Bool
    
    public init(condition: @escaping (inout Context) -> Bool) {
        _condition = condition
    }
    
    public init<Condition: TransitionCondition>(_ condition: Condition)
    where Context == Condition.Context {
        _condition = condition.evaluate
    }
    
    public func evaluate(context: inout Context) -> Bool {
        _condition(&context)
    }
}

public extension AnyTransitionCondition {
    static func constant(_ value: Bool) -> AnyTransitionCondition {
        AnyTransitionCondition { _ in value }
    }
}

public extension Transition {
    init<Condition: TransitionCondition>(
        _ base: AnyState<Context>.ID,
        _ target: AnyState<Context>.ID,
        condition: Condition
    ) where Context == Condition.Context {
        self.base = base
        self.target = target
        self.condition = AnyTransitionCondition(condition)
    }
    
    init(_ base: AnyState<Context>.ID,
         _ target: AnyState<Context>.ID,
         _ condition: @escaping (inout Context) -> Bool) {
        self.base = base
        self.target = target
        self.condition = AnyTransitionCondition(condition: condition)
    }
}
