//
//  StateNodeButtonStyle.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-14.
//


import SwiftUI

struct StateNodeButtonStyle: ButtonStyle {
    @Environment(\.stateId) private var stateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    @State private var isHovered = false
    
    private var backgroundStyle: AnyShapeStyle {
        isHovered ? AnyShapeStyle(.selection) : AnyShapeStyle(.thinMaterial)
    }

    func makeBody(configuration: Configuration) -> some View {
        StateView(backgroundStyle: backgroundStyle) {
            configuration.label
        }
        .opacity(configuration.isPressed ? 0.7 : 1)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
}

extension ButtonStyle where Self == StateNodeButtonStyle {
    static var stateNode: StateNodeButtonStyle {
        StateNodeButtonStyle()
    }
}
