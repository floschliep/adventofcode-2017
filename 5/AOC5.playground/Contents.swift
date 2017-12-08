//: Playground - noun: a place where people can play

import Cocoa

let fileString = try! String(contentsOfFile: "/Users/florianschliep/Desktop/input.txt")
var instructions = fileString.split(separator: "\n").map { Int($0)! }

var jumpsCount = 0
var idx = 0

while idx < instructions.count {
    let currentInstruction = instructions[idx]

    let newInstruction: Int
    if currentInstruction >= 3 {
        newInstruction = currentInstruction-1
    } else {
        newInstruction = currentInstruction+1
    }
    instructions[idx] = newInstruction
    
    idx += currentInstruction
    
    jumpsCount += 1
}

print(jumpsCount)
