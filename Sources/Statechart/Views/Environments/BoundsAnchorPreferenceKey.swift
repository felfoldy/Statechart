//
//  BoundsAnchorPreferenceKey.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-15.
//

import SwiftUI

struct BoundsAnchorPreferenceKey: PreferenceKey {
    static let defaultValue = [String : Anchor<CGRect>]()
    
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    func setBoundsAnchor(for key: String) -> some View {
        anchorPreference(key: BoundsAnchorPreferenceKey.self, value: .bounds) { anchor in
            [key: anchor]
        }
    }
}
