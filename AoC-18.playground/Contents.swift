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
    case send(Value)
    case receive(Character)
    case jump(greaterThanZero: Value, offset: Value)
    
    case setRegister(Character, to: Value)
    case increaseRegister(Character, by: Value)
    case multiplyRegister(Character, by: Value)
    case moduloRegister(Character, by: Value)
    
    init?(_ string: Substring) {
        let components: [Substring] = string.split(separator: " ")
        guard components.count >= 2 && components.count <= 3 else { return nil }
        
        switch components[0] {
        case "snd":
            self = .send(Value(components[1]))
        case "set":
            self = .setRegister(components[1].first!, to: Value(components[2]))
        case "add":
            self = .increaseRegister(components[1].first!, by: Value(components[2]))
        case "mul":
            self = .multiplyRegister(components[1].first!, by: Value(components[2]))
        case "mod":
            self = .moduloRegister(components[1].first!, by: Value(components[2]))
        case "rcv":
            self = .receive(components[1].first!)
        case "jgz":
            self = .jump(greaterThanZero: Value(components[1]), offset: Value(components[2]))
        default:
            return nil
        }
    }
}

enum ProgramError: Error {
    case deadlock(Program, Character)
}

struct Program {
    let id: Int
    private var registers: [Character: Int]
    private var queue: [Int]
    private(set) var sendCount: Int
    
    var isQueueEmpty: Bool {
        return self.queue.isEmpty
    }
    
// MARK: - Instantiation
    
    init(id: Int) {
        self.id = id
        self.registers = ["p": id]
        self.queue = [Int]()
        self.sendCount = 0
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
    
    private mutating func enqueue(_ value: Int) {
        self.queue.append(value)
    }
    
    mutating func processRegister(_ register: Character) -> Bool {
        guard let value = self.queue.first else { return false }
        
        self[register] = value
        self.queue = Array(self.queue.dropFirst())
        
        return true
    }
    
    mutating func send(_ value: Value, to target: inout Program) {
        self.sendCount += 1
        target.enqueue(self[value])
    }
}

func process(instructions: [Instruction], position: inout Int, source: inout Program, target: inout Program) {
    while position < instructions.count {
        let instruction = instructions[position]
        
        switch instruction {
        case let .send(value):
            source.send(value, to: &target)
        case let .receive(register):
            guard source.processRegister(register) else { return }
        case let .setRegister(register, value):
            source[register] = source[value]
        case let .increaseRegister(register, value):
            source[register] += source[value]
        case let .multiplyRegister(register, value):
            source[register] *= source[value]
        case let .moduloRegister(register, value):
            source[register] = source[register]%source[value]
        case let .jump(condition, offset):
            guard source[condition] > 0 else { break }
            position += source[offset]
            continue
        }
        
        position += 1
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
let instructions = file.split(separator: "\n").map { Instruction($0)! }

var program0 = Program(id: 0)
var position0 = 0

var program1 = Program(id: 1)
var position1 = 0

var deadlock = false

while (position0 < instructions.count || position1 < instructions.count) && !deadlock {
    process(instructions: instructions, position: &position0, source: &program0, target: &program1)
    process(instructions: instructions, position: &position1, source: &program1, target: &program0)
    
    if program0.isQueueEmpty && program1.isQueueEmpty {
        deadlock = true
    }
}

assert(program1.sendCount == 7620)
