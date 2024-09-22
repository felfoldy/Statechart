//
//  DetailedStateView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

import SwiftUI

struct DetailStateView<Content: View, Detail: View>: View {
    private let backgroundStyle: AnyShapeStyle
    private let content: () -> Content
    private let detail: () -> Detail
    
    public init(backgroundStyle: AnyShapeStyle = .init(.thinMaterial),
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder detail: @escaping () -> Detail) {
        self.backgroundStyle = backgroundStyle
        self.content = content
        self.detail = detail
    }
    
    var body: some View {
        BaseStateView(cornerRadius: 16, backgroundStyle: backgroundStyle) {
            content()
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .top], 16)
                .safeAreaInset(edge: .bottom, spacing: 16) {
                    detail()
                        .frame(maxWidth: .infinity)
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
