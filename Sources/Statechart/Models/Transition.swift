//
//  Transition.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

public protocol Transition: Identifiable {
    associatedtype Context

    var sourceId: String { get }
    var targetId: String { get }
    
    func condition(context: inout Context) -> Bool
}

extension Transition {
    public var id: String { "\(sourceId)-\(targetId)" }
}

public struct AnyTransition<Context>: Transition {
    public let sourceId: String
    public let targetId: String

    private let _condition: (inout Context) -> Bool

    public init(source: String, target: String,
                _ condition: @escaping (inout Context) -> Bool) {
        self.sourceId = source
        self.targetId = target
        _condition = condition
    }
    
    public init<T: Transition>(_ transition: T) where T.Context == Context {
        self.sourceId = transition.sourceId
        self.targetId = transition.targetId
        _condition = transition.condition
    }
    
    public func condition(context: inout Context) -> Bool {
        _condition(&context)
    }
}

public extension AnyTransition {
    enum ConditionType {
        case constant(Bool)
        
        var function: (inout Context) -> Bool {
            switch self {
            case let .constant(value): { _ in value }
            }
        }
    }
    
    static func transition(_ source: String, _ target: String, condition: @escaping (inout Context) -> Bool) -> AnyTransition {
        AnyTransition(source: source, target: target, condition)
    }
    
    static func transition(_ source: String, _ target: String, _ condition: ConditionType) -> AnyTransition {
        AnyTransition(source: source, target: target, condition.function)
    }
}
