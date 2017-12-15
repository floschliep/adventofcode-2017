//: Playground - noun: a place where people can play

import Cocoa

let factorA = 16807
let factorB = 48271

var valueA = 277
var valueB = 349

let divisor = 2147483647

let rounds = 5_000_000

var valuesA = [Int]()
var valuesB = [Int]()

while valuesA.count < rounds {
    valueA = (valueA*factorA)%divisor
    if valueA%4 == 0 {
        valuesA.append(valueA)
    }
}

while valuesB.count < rounds {
    valueB = (valueB*factorB)%divisor
    if valueB%8 == 0 {
        valuesB.append(valueB)
    }
}

var matches = 0

for i in 0..<rounds {    
    let valueA = valuesA[i]
    let valueB = valuesB[i]
    
    // shift all but the last 16 bits to the left
    let shiftedA = valueA << (valueA.bitWidth-16)
    let shiftedB = valueB << (valueB.bitWidth-16)
    
    if shiftedA == shiftedB {
        matches += 1
    }
}

assert(matches == 320)
