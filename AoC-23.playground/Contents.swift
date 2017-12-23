//: Playground - noun: a place where people can play

import Cocoa

enum Value {
    case integer(Int)
    case register(Character)
    
    init(_ string: Substring) {
        if let integer = Int(string) {
            self = .integer(integer)
        } else {
            self = .register(string.first!)
        }
    }
}

enum Instruction {
    case jump(notZero: Value, offset: Value)
    
    case setRegister(Character, to: Value)
    case decreaseRegister(Character, by: Value)
    case multiplyRegister(Character, by: Value)
    
    init?(_ string: Substring) {
        let components: [Substring] = string.split(separator: " ")
        guard components.count >= 2 && components.count <= 3 else { return nil }
        
        switch components[0] {
        case "set":
            self = .setRegister(components[1].first!, to: Value(components[2]))
        case "sub":
            self = .decreaseRegister(components[1].first!, by: Value(components[2]))
        case "mul":
            self = .multiplyRegister(components[1].first!, by: Value(components[2]))
        case "jnz":
            self = .jump(notZero: Value(components[1]), offset: Value(components[2]))
        default:
            return nil
        }
    }
}

struct Program: CustomDebugStringConvertible {
    private var registers: [Character: Int]
    
    init() {
        self.registers = [:]
    }
    
// MARK: - Subscripts
    
    subscript(register: Character) -> Int {
        set {
            self.set(newValue, for: register)
        }
        get {
            return self.get(.register(register))
        }
    }
    subscript(value: Value) -> Int {
        get {
            return self.get(value)
        }
    }
    
// MARK: - Actions
    
    func get(_ value: Value) -> Int {
        switch value {
        case let .integer(val):
            return val
        case let .register(register):
            return self.registers[register] ?? 0
        }
    }
    
    mutating func set(_ val: Int, `for` register: Character) {
        self.registers[register] = val
    }
    
// MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return self.registers.debugDescription
    }
    
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
let instructions = file.split(separator: "\n").map { Instruction($0)! }

var program = Program()
var index = 0
var multiplications = 0

while index < instructions.count {
    let instruction = instructions[index]
    switch instruction {
    case let .setRegister(register, value):
        program[register] = program[value]
    case let .decreaseRegister(register, value):
        program[register] -= program[value]
    case let .multiplyRegister(register, value):
        program[register] *= program[value]
        multiplications += 1
    case let .jump(condition, offset):
        guard program[condition] != 0 else { break }
        index += program[offset]
        continue
    }
    
    index += 1
}

assert(multiplications == 3969)
