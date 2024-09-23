//
//  TransitionView.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-16.
//

import SwiftUI

struct TransitionView: View {
    @Binding var transition: TransitionDescription
    let anchors: [String : Anchor<CGRect>]

    @State var isAnimating = false
    
    private var baseAnchor: Anchor<CGRect>? {
        anchors[transition.base]
    }
    
    private var targetAnchor: Anchor<CGRect>? {
        anchors[transition.target]
    }
    
    private var strokeShape: AnyShapeStyle {
        isAnimating ? AnyShapeStyle(.link) : AnyShapeStyle(.selection)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if let baseAnchor, let targetAnchor {
                let rect1 = geometry[baseAnchor]
                let rect2 = geometry[targetAnchor]

                let isVertical = rect1.mid.isDirectionVertical(to: rect2.mid)

                if isVertical {
                    let isRect1Above = rect1.mid.y <= rect2.mid.y
                    
                    let point1 = isRect1Above ? rect1.bottom : rect1.top
                    let point2 = isRect1Above ? rect2.top : rect2.bottom
                    
                    VerticalEdgeShape(point1: point1, point2: point2)
                        .stroke(strokeShape, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                        .onAppear {
                            transition.anchored(to: isRect1Above ? .top : .bottom)
                        }
                } else {
                    let isRect1Left = rect1.mid.x <= rect2.mid.x
                    
                    let point1 = isRect1Left ? rect1.right : rect1.left
                    let point2 = isRect1Left ? rect2.left : rect2.right
                    
                    HorizontalEdgeShape(point1: point1, point2: point2)
                        .stroke(strokeShape,
                                style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                        .onAppear {
                            transition.anchored(to: isRect1Left ? .left : .right)
                        }
                }
            }
        }
        .animation(.linear, value: baseAnchor)
        .animation(.linear, value: targetAnchor)
        .onReceive(
            NotificationCenter.default
                .stateTransitionPublisher()
        ) { base, target in
            let directions = Set([base, target])
            guard directions.contains(transition.base),
                  directions.contains(transition.target) else {
                return
            }

            withAnimation(.interactiveSpring) {
                isAnimating = true
            }

            withAnimation(.easeOut.delay(0.5)) {
                isAnimating = false
            }
        }
    }
}

struct VerticalEdgeShape: Shape {
    let point1: CGPoint
    let point2: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let midY = (point1.y + point2.y) / 2
            
            let control1 = CGPoint(x: point1.x, y: midY)
            let control2 = CGPoint(x: point2.x, y: midY)
            
            path.move(to: point1)
            path.addCurve(
                to: point2,
                control1: control1,
                control2: control2
            )
        }
    }
}

struct HorizontalEdgeShape: Shape {
    let point1: CGPoint
    let point2: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let midX = (point1.x + point2.x) / 2
            
            let control1 = CGPoint(x: midX, y: point1.y)
            let control2 = CGPoint(x: midX, y: point2.y)
            
            path.move(to: point1)
            path.addCurve(
                to: point2,
                control1: control1,
                control2: control2
            )
        }
    }
}

extension CGRect {
    var top: CGPoint { CGPoint(x: midX, y: minY) }
    var bottom: CGPoint { CGPoint(x: midX, y: maxY) }
    var left: CGPoint { CGPoint(x: minX, y: midY) }
    var right: CGPoint { CGPoint(x: maxX, y: midY) }
    var mid: CGPoint { CGPoint(x: midX, y: midY) }
}

extension CGPoint {
    func isDirectionVertical(to other: CGPoint) -> Bool {
        let dx = other.x - x
        let dy = other.y - y
        return abs(dy) > abs(dx)
    }
}
