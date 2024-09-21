//
//  StatechartLayoutMakerEnvironment.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

@MainActor
struct StatechartLayoutMakerEnvironmentKey: @preconcurrency EnvironmentKey {
    static let defaultValue: any StatechartLayoutMaker = .stack(.horizontal)
}

extension EnvironmentValues {
    public var statechartLayoutMaker: any StatechartLayoutMaker {
        get { self[StatechartLayoutMakerEnvironmentKey.self] }
        set { self[StatechartLayoutMakerEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func statechartLayout(_ layoutMaker: any StatechartLayoutMaker) -> some View {
        environment(\.statechartLayoutMaker, layoutMaker)
    }
}
