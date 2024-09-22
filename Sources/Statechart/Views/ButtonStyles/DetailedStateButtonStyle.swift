//
//  DetailedStateButtonStyle.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

public struct DetailedStateButtonStyle: ButtonStyle {
    let detail: () -> AnyView
    
    @Environment(\.stateId) private var stateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    @State private var isHovered = false
    
    private var backgroundStyle: AnyShapeStyle {
        isHovered ? AnyShapeStyle(.selection) : AnyShapeStyle(.thinMaterial)
    }

    public func makeBody(configuration: Configuration) -> some View {
        DetailStateView(backgroundStyle: backgroundStyle) {
            configuration.label
        } detail: {
            detail()
        }
        .opacity(configuration.isPressed ? 0.7 : 1)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
}

public extension ButtonStyle where Self == DetailedStateButtonStyle {
    static func detailedState<Detail: View>(@ViewBuilder detail: @escaping () -> Detail) -> Self {
        DetailedStateButtonStyle {
            AnyView(detail())
        }
    }
}
