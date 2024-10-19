//
//  StateCollection.swift
//  Statechart
//
//  Created by Tibor Felföldy on 2024-09-21.
//

/// Array of states designed to look up states by name with `O(1)` complexity.
public struct StateCollection<Context>: RandomAccessCollection, MutableCollection {
    public typealias State = any MachineState<Context>
    
    public let startIndex = 0

    public var endIndex: Int {
        values.endIndex
    }

    private var values: [State] {
        didSet {
            updateIndices()
        }
    }

    private var stateIndicies: [String : Int] = [:]
    
    public init(_ values: [State] = []) {
        self.values = values
        updateIndices()
    }
    
    public subscript(position: Int) -> State {
        get { values[position] }
        set { values[position] = newValue }
    }
    
    public subscript(name: String) -> State? {
        guard let index = stateIndicies[name] else {
            return nil
        }
        return values[index]
    }
    
    /// If a state exists with the same name updates it otherwise adds the state to the end of the array.
    public mutating func set(_ state: State) {
        if let index = stateIndicies[state.id] {
            values[index] = state
        } else {
            values.append(state)
        }
    }
    
    public var renderable: [AnyState<Context>] {
        values.map { state in
            if let stateMachine = state as? StateMachine<Context> {
                AnyState(stateMachine)
            } else {
                AnyState(state)
            }
        }
    }

    private mutating func updateIndices() {
        stateIndicies = Dictionary(grouping: values.enumerated(), by: \.element.id)
            .compactMapValues(\.first?.offset)
    }
}
