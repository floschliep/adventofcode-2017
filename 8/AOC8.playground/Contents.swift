//: Playground - noun: a place where people can play

import Cocoa

enum Action: String {
    case increase = "inc"
    case decrease = "dec"
    
    func perform(left: Int, right: Int) -> Int {
        switch self {
        case .increase:
            return left + right
        case .decrease:
            return left - right
        }
    }
}

enum Evaluation: String {
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanOrEqualTo = ">="
    case lessThanOrEqualTo = "<="
    case equalTo = "=="
    case notEqualTo = "!="
    
    func perform(left: Int, right: Int) -> Bool {
        switch self {
        case .greaterThan:
            return (left > right)
        case .lessThan:
            return (left < right)
        case .greaterThanOrEqualTo:
            return (left >= right)
        case .lessThanOrEqualTo:
            return (left <= right)
        case .equalTo:
            return (left == right)
        case .notEqualTo:
            return (left != right)
        }
    }
}

struct Condition {
    let variable: String
    let evaluation: Evaluation
    let value: Int
    
    init?(_ string: String) {
        let components = string.split(separator: " ")
        guard
            components.count == 4,
            let eval = Evaluation(rawValue: String(components[2])),
            let value = Int(components[3])
        else {
            print("invalid condition: \(string)")
            print(components)
            return nil
        }
        
        self.variable = String(components[1])
        self.evaluation = eval
        self.value = value
    }
    
    func evaluate(with otherValue: Int) -> Bool {
        return self.evaluation.perform(left: otherValue, right: self.value)
    }
}

struct Instruction {
    let variable: String
    let action: Action
    let value: Int
    let condition: Condition
    
    init?(_ string: String) {
        let components = string.split(separator: " ", maxSplits: 3)
        guard
            components.count == 4,
            let action = Action(rawValue: String(components[1])),
            let val = Int(String(components[2])),
            let condition = Condition(String(components[3]))
        else {
            print("invalid instruction: \(string)")
            print(components)
            return nil
        }
        
        self.variable = String(components[0])
        self.action = action
        self.value = val
        self.condition = condition
    }
}

let file = try! String(contentsOfFile: "/Users/florianschliep/Desktop/input.txt")
let instructions = file.split(separator: "\n").map { Instruction(String($0))! }

var variables =  [String: Int]()
var maxValue = 0

for instruction in instructions {
    let variable = variables[instruction.variable] ?? 0
    let conditionVariable = variables[instruction.condition.variable] ?? 0
    
    if instruction.condition.evaluate(with: conditionVariable) {
        let newValue = instruction.action.perform(left: variable, right: instruction.value)
        variables[instruction.variable] = newValue
        maxValue = max(maxValue, newValue)
    }
}

print(maxValue)
print(variables.max(by: { $0.1 < $1.1 }))
