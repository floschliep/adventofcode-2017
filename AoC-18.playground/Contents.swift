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
    case playSound(Value)
    case setRegister(Character, to: Value)
    case increaseRegister(Character, by: Value)
    case multiplyRegister(Character, by: Value)
    case moduloRegister(Character, by: Value)
    case recoverFrequency(nonZero: Value)
    case jump(greaterThanZero: Value, offset: Value)
    
    init?(_ string: Substring) {
        let components: [Substring] = string.split(separator: " ")
        guard components.count >= 2 && components.count <= 3 else { return nil }
        
        switch components[0] {
        case "snd":
            self = .playSound(Value(components[1]))
        case "set":
            self = .setRegister(components[1].first!, to: Value(components[2]))
        case "add":
            self = .increaseRegister(components[1].first!, by: Value(components[2]))
        case "mul":
            self = .multiplyRegister(components[1].first!, by: Value(components[2]))
        case "mod":
            self = .moduloRegister(components[1].first!, by: Value(components[2]))
        case "rcv":
            self = .recoverFrequency(nonZero: Value(components[1]))
        case "jgz":
            self = .jump(greaterThanZero: Value(components[1]), offset: Value(components[2]))
        default:
            return nil
        }
    }
}

struct RegisterSet {
    private var registers = [Character: Int]()
    private var playedFrequencies = [Int]()

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
    
    mutating func set(_ frequency: Int, `for` register: Character) {
        self.registers[register] = frequency
    }
    
    func get(_ value: Value) -> Int {
        switch value {
        case let .integer(frequency):
            return frequency
        case let .register(register):
            return self.registers[register] ?? 0
        }
    }
    
    mutating func play(_ frequency: Int) {
        self.playedFrequencies.append(frequency)
    }
    
    var lastPlayedFrequency: Int? {
        return self.playedFrequencies.last
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)

let instructions = file.split(separator: "\n").map { Instruction($0)! }
var set = RegisterSet()
var position = 0

instructionLoop: while position < instructions.count {
    let instruction = instructions[position]
    
    switch instruction {
    case let .playSound(value):
        set.play(set[value])
    case let .setRegister(register, value):
        set[register] = set[value]
    case let .increaseRegister(register, value):
        set[register] += set[value]
    case let .multiplyRegister(register, value):
        set[register] *= set[value]
    case let .moduloRegister(register, value):
        set[register] = set[register]%set[value]
    case let .recoverFrequency(value):
        let frequency = set[value]
        guard frequency != 0 else { break }
        assert(set.lastPlayedFrequency == 9423)
        break instructionLoop
    case let .jump(condition, offset):
        guard set[condition] > 0 else { break }
        position += set[offset]
        continue
    }
    
    position += 1
}

