//
//  StateEditor.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-14.
//

import SwiftUI

struct StateGraphEditor<Context, NodeContent: View>: View {
    let graph: StateGraph<Context>
    let node: (State<Context>) -> NodeContent
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Text("Content")
        }
        .navigationTitle(graph.name)
    }
}

#Preview {
    struct Context {}
    
    class DrawableStateGraph: StateGraph<Context> {
        init?() {
            super.init(name: "Graph",
                       states: [.empty("Default")],
                       transitions: [:],
                       entryId: "Default")
        }
    }
    
    return NavigationStack {
        StateGraphEditor(graph: DrawableStateGraph()!) { stateNode in
            Text(stateNode.name)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }.padding()
    }
}
