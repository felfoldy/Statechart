//
//  StateView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

public struct StateView<Content: View>: View {
    private let backgroundStyle: AnyShapeStyle
    private let content: () -> Content

    @Environment(\.stateId) private var stateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    public init(backgroundStyle: AnyShapeStyle = .init(.thinMaterial),
                @ViewBuilder content: @escaping () -> Content) {
        self.backgroundStyle = backgroundStyle
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundStyle)
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
    }
}
