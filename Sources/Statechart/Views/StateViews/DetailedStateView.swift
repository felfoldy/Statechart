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
        BaseStateView(backgroundStyle: backgroundStyle) {
            content()
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    // TODO: Make it setable.
                    Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                }
                .padding(.horizontal, 8)
                .safeAreaInset(edge: .bottom) {
                    detail()
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background {
                            UnevenRoundedRectangle(
                                bottomLeadingRadius: 8,
                                bottomTrailingRadius: 8
                            )
                            .fill(.gray.opacity(0.8))
                        }
                }
                .padding(.top, 8)
        }
    }
}
