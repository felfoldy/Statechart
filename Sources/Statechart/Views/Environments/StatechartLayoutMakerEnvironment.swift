//
//  StatechartLayoutMakerEnvironment.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

@MainActor
struct StatechartLayoutMakerEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue: any StateMachineLayoutMaker = .stack(.horizontal)
}

extension EnvironmentValues {
    public var statechartLayoutMaker: any StateMachineLayoutMaker {
        get { self[StatechartLayoutMakerEnvironmentKey.self] }
        set { self[StatechartLayoutMakerEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func statechartLayout(_ layoutMaker: any StateMachineLayoutMaker) -> some View {
        environment(\.statechartLayoutMaker, layoutMaker)
    }
}
