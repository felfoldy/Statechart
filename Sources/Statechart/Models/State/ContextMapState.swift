//
//  ContextMapState.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-10-27.
//

public struct ContextMapState<SourceContext, TargetContext>: StateNode {
    public typealias Context = SourceContext
    
    let transform: (SourceContext) -> TargetContext
    let targetState: any StateNode<TargetContext>
    
    public var name: String { targetState.name }

    public var asStateMachine: (any StateMachineProtocol)? {
        targetState.asStateMachine
    }

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

extension StateNode {
    public func mapContext<SourceContext>(_ transform: @escaping (SourceContext) -> Context) -> some StateNode<SourceContext> {
        ContextMapState(transform: transform, targetState: self)
    }
}
