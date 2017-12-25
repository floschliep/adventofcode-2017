//: Playground - noun: a place where people can play

import Cocoa

// MARK: - Model

enum Direction {
    case left
    case right
}

enum Value {
    case zero
    case one
}

typealias StateID = Character

struct Condition {
    let test: (Value) -> Bool
    let writeValue: Value
    let moveDirection: Direction
    let newState: StateID
}

struct State {
    let conditions: [Condition]
    
    func condition(`for` value: Value) -> Condition? {
        return self.conditions.first { $0.test(value) }
    }
}

struct Machine {
    let states: [StateID: State]
    var slots: [Int: Value]
    
    func value(at position: Int) -> Value {
        return self.slots[position] ?? .zero
    }
    
    mutating func set(_ value: Value, at position: Int) {
        self.slots[position] = value
    }
    
    var checksum: Int {
        return self.slots.filter({ $1 == .one }).count
    }
}

// MARK: - Program

var machine = Machine(states: [
    "a": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .one, moveDirection: .right, newState: "b"),
        Condition(test: { $0 == .one }, writeValue: .zero, moveDirection: .left, newState: "c")
    ]),
    "b": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .one, moveDirection: .left, newState: "a"),
        Condition(test: { $0 == .one }, writeValue: .one, moveDirection: .right, newState: "d")
    ]),
    "c": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .zero, moveDirection: .left, newState: "b"),
        Condition(test: { $0 == .one }, writeValue: .zero, moveDirection: .left, newState: "e")
    ]),
    "d": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .one, moveDirection: .right, newState: "a"),
        Condition(test: { $0 == .one }, writeValue: .zero, moveDirection: .right, newState: "b")
    ]),
    "e": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .one, moveDirection: .left, newState: "f"),
        Condition(test: { $0 == .one }, writeValue: .one, moveDirection: .left, newState: "c")
    ]),
    "f": State(conditions: [
        Condition(test: { $0 == .zero }, writeValue: .one, moveDirection: .right, newState: "d"),
        Condition(test: { $0 == .one }, writeValue: .one, moveDirection: .right, newState: "a")
    ])
], slots: [:])

// MARK: - Execution

let steps = 12481997
var currentState: StateID = "a"
var cursor = 0

for _ in 0..<steps {
    let state = machine.states[currentState]!
    guard let condition = state.condition(for: machine.value(at: cursor)) else { preconditionFailure() }
    machine.set(condition.writeValue, at: cursor)
    switch condition.moveDirection {
    case .left:
        cursor -= 1
    case .right:
        cursor += 1
    }
    currentState = condition.newState
}

assert(machine.checksum == 3362)
