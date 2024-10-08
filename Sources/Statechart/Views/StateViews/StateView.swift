//
//  StateView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

struct BaseStateView<Content: View>: View {
    let cornerRadius: CGFloat
    let backgroundStyle: AnyShapeStyle
    @ViewBuilder let content: () -> Content
    
    @Environment(\.stateId) private var stateId
    @Environment(\.entryStateId) private var entryStateId
    @Environment(\.activeStateId) private var activeStateId
    @Environment(\.stateTranslation) private var isTranslating
    
    var body: some View {
        content()
            .fontDesign(.rounded)
            .background(alignment: .topLeading) {
                if stateId == entryStateId {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 12))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundStyle)
                    .shadow(radius: 4, y: 2)
            }
            .opacity(isTranslating ? 0.1 : 1)
            .overlay {
                ZStack(alignment: .topLeading) {
                    if activeStateId == stateId || isTranslating {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(isTranslating ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange.gradient), lineWidth: 4)
                    }
                }
            }
            .animation(.default, value: activeStateId == stateId)
    }
}

public struct StateView<Content: View, Detail: View>: View {
    private let backgroundStyle: AnyShapeStyle
    private let content: () -> Content
    private let detail: () -> Detail
    
    @Environment(\.stateId) private var stateId
    @Environment(\.entryStateId) private var entryStateId
    
    public init(backgroundStyle: AnyShapeStyle = .init(.thinMaterial),
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail: @escaping () -> Detail) {
        self.backgroundStyle = backgroundStyle
        self.content = content
        self.detail = detail
    }
    
    public var body: some View {
        let detail = detail()
        
        if detail is EmptyView {
            BaseStateView(cornerRadius: 8,
                          backgroundStyle: backgroundStyle) {
                content()
                    .padding(16)
            }
        } else {
            BaseStateView(cornerRadius: 16, backgroundStyle: backgroundStyle) {
                content()
                    .padding([.horizontal, .top], 16)
                    .safeAreaInset(edge: .bottom, spacing: 16) {
                        detail
                            .padding(16)
                            .background {
                                UnevenRoundedRectangle(
                                    bottomLeadingRadius: 8,
                                    bottomTrailingRadius: 8
                                )
                                .fill(.gray.opacity(0.8))
                            }
                    }
            }
        }
    }
}

extension StateView where Content == Text {
    init(_ title: String,
         backgroundStyle: AnyShapeStyle = .init(.thinMaterial),
         @ViewBuilder detail: @escaping () -> Detail) {
        self.init(content: { Text(title) }, detail: detail)
    }
    
    init(
        _ title: String,
        backgroundStyle: AnyShapeStyle = .init(.thinMaterial)
    ) where Detail == EmptyView {
        self.init(title, backgroundStyle: backgroundStyle,
                  detail: { EmptyView() })
    }
}
