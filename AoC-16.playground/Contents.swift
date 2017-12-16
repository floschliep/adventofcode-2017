//: Playground - noun: a place where people can play

import Cocoa

extension Substring {
    func index(with integer: Int) -> Index {
        return self.index(self.startIndex, offsetBy: integer)
    }
    
    subscript(idx: Int) -> Character {
        return self[self.index(with: idx)]
    }
}

enum Move {
    case spin(Int)
    case exchange(Int, Int)
    case partner(Character, Character)
    
    init?(_ string: Substring) {
        switch string[0] {
        case "s":
            let length = Int(string.dropFirst())!
            self = .spin(length)
        case "x":
            let posisions = string.dropFirst().split(separator: "/")
            guard posisions.count == 2 else { return nil }
            let pos1 = Int(String(posisions[0]))!
            let pos2 = Int(String(posisions[1]))!
            self = .exchange(pos1, pos2)
        case "p":
            self = .partner(string[1], string[3])
        default:
            return nil
        }
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
let moves = file.split(separator: ",").map { Move($0)! }

var programs: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]
let original = programs
let requiredNumberOfDances = 1_000_000_000
var numberOfDances = 0
var foundCycle = false

while numberOfDances < requiredNumberOfDances {
    for move in moves {
        switch move {
        case let .spin(length):
            let endChars = programs[programs.count-length..<programs.count]
            programs = endChars + Array(programs.dropLast(length))
        case let .exchange(pos1, pos2):
            programs.swapAt(pos1, pos2)
        case let .partner(char1, char2):
            let idx1 = programs.index(of: char1)!
            let idx2 = programs.index(of: char2)!
            programs.swapAt(idx1, idx2)
        }
    }
    
    numberOfDances += 1
    if !foundCycle {
        if programs == original {
            foundCycle = true
            numberOfDances = requiredNumberOfDances - (requiredNumberOfDances%numberOfDances)
        }
    }
}

let result = programs.reduce("", { $0 + String($1) })
assert(result == "ajcdefghpkblmion")
