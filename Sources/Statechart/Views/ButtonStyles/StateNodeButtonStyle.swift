//
//  StateNodeButtonStyle.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//


import SwiftUI

struct StateNodeButtonStyle: ButtonStyle {
    @Environment(\.stateId) private var stateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    @SwiftUI.State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? AnyShapeStyle(.selection) : AnyShapeStyle(.thinMaterial))
                    .shadow(radius: 4, y: 2)
            }
            .opacity(isTranslating ? 0.1 : 1)
            .overlay {
                if activeStateId == stateId || isTranslating {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isTranslating ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange.gradient), lineWidth: 4)
                }
            }
            .animation(.default, value: activeStateId == stateId)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
    }
}

struct SelectableStateNodeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn = true
        } label: {
            configuration.label
        }
        .buttonStyle(.stateNode)
    }
}

extension ButtonStyle where Self == StateNodeButtonStyle {
    static var stateNode: StateNodeButtonStyle {
        StateNodeButtonStyle()
    }
}
