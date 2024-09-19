//
//  State.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import Foundation

public struct State<Context> {
    public var name: String

    public var enter: (Context) -> Void
    public var update: (Context) -> Void
    public var exit: (Context) -> Void
}

extension State: Identifiable {
    public var id: String { name }
    
    public static func empty(_ name: String) -> Self {
        State(name: name, enter: { _ in }, update: { _ in }, exit: { _ in })
    }
}
