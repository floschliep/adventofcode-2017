//: Playground - noun: a place where people can play

import Cocoa

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
var banks = file.split(separator: " ").map { Int($0)! }

var stateHistory = [[Int]]()
var cycles = 0
var duplicateState: [Int]? = nil

while true {
    if let duplicate = duplicateState {
        if banks == duplicate {
            break
        }
    } else if stateHistory.contains(where: { $0 == banks }) {
        duplicateState = banks
        cycles = 0
    }
    
    stateHistory.append(banks)
    cycles += 1
    
    let blocks = banks.max()!
    var index = banks.index(of: blocks)!
    banks[index] = 0
    index += 1
    
    for _ in 0..<blocks {
        if index > banks.count-1 {
            index = 0
        }
        
        banks[index] = banks[index]+1
        index += 1
    }
}

assert(cycles == 1695)
