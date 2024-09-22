//
//  StateView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

struct BaseStateView<Content: View>: View {
    let backgroundStyle: AnyShapeStyle
    @ViewBuilder let content: () -> Content
    
    @Environment(\.stateId) private var stateId
    @Environment(\.entryStateId) private var entryStateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    var body: some View {
        content()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundStyle)
                    .shadow(radius: 4, y: 2)
            }
            .opacity(isTranslating ? 0.1 : 1)
            .overlay {
                ZStack(alignment: .topLeading) {
                    if activeStateId == stateId || isTranslating {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTranslating ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange.gradient), lineWidth: 4)
                    }
                    
                    if entryStateId == stateId {
                        Image(systemName: "arrowshape.right.fill")
                            .font(.system(size: 16))
                            .scaleEffect(y: -1)
                            .offset(x: -16)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
            }
            .animation(.default, value: activeStateId == stateId)
    }
}

public struct StateView<Content: View>: View {
    private let backgroundStyle: AnyShapeStyle
    private let content: () -> Content
    
    public init(backgroundStyle: AnyShapeStyle = .init(.thinMaterial),
                @ViewBuilder content: @escaping () -> Content) {
        self.backgroundStyle = backgroundStyle
        self.content = content
    }
    
    public var body: some View {
        BaseStateView(backgroundStyle: backgroundStyle) {
            content()
                .padding()
        }
    }
}
