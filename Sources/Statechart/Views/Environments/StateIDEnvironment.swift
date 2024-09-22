//
//  StateIDEnvironment.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

@MainActor
struct StateIDEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue: String? = nil
}

@MainActor
struct EntryStateEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue: String? = nil
}

@MainActor
struct ActiveStateEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue: String? = nil
}

@MainActor
struct StateTranslationEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var stateId: String? {
        get { self[StateIDEnvironmentKey.self] }
        set { self[StateIDEnvironmentKey.self] = newValue }
    }
    
    public var entryStateId: String? {
        get { self[EntryStateEnvironmentKey.self] }
        set { self[EntryStateEnvironmentKey.self] = newValue }
    }
    
    public var activeStateId: String? {
        get { self[ActiveStateEnvironmentKey.self] }
        set { self[ActiveStateEnvironmentKey.self] = newValue }
    }
    
    public var stateTranslation: Bool {
        get { self[StateTranslationEnvironmentKey.self] }
        set { self[StateTranslationEnvironmentKey.self] = newValue }
    }
}
