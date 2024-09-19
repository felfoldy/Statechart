//
//  Notification+StateTransition.swift
//  StateGraph
//
//  Created by Tibor Felföldy on 2024-09-19.
//

import Foundation
import Combine

extension Notification.Name {
    static let stateTransition = Notification.Name("stateTransition")
}

extension NotificationCenter {
    func postStateTransition<Context>(_ transition: Transition<Context>) {
        post(name: .stateTransition, object: nil,
             userInfo: ["base": transition.base,
                        "target": transition.target])
    }
    
    func stateTransitionPublisher() -> AnyPublisher<(String, String), Never> {
        publisher(for: .stateTransition)
            .compactMap(\.userInfo)
            .compactMap { userInfo in
                guard let base = userInfo["base"] as? String,
                      let target = userInfo["target"] as? String else {
                    return nil
                }
                
                return (base ,target)
            }
            .eraseToAnyPublisher()
    }
}
