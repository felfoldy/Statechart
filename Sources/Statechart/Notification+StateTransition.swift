//
//  Notification+StateTransition.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import Foundation
import Combine

extension Notification.Name {
    static let stateTransition = Notification.Name("stateTransition")
}

extension NotificationCenter {
    func postStateTransition(_ transition: any Transition) {
        post(name: .stateTransition, object: nil,
             userInfo: ["source": transition.sourceId,
                        "target": transition.targetId])
    }
    
    func stateTransitionPublisher() -> AnyPublisher<(String, String), Never> {
        publisher(for: .stateTransition)
            .compactMap(\.userInfo)
            .compactMap { userInfo in
                guard let base = userInfo["source"] as? String,
                      let target = userInfo["target"] as? String else {
                    return nil
                }
                
                return (base ,target)
            }
            .eraseToAnyPublisher()
    }
}
