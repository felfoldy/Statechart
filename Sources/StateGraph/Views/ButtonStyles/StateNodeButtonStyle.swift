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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.thinMaterial)
                    .shadow(radius: 4, y: 2)
            }
            .background {
                if activeStateId == stateId {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.orange.gradient, lineWidth: 4)
                }
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
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
