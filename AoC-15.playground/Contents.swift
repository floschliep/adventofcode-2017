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
    let bitRepA = String(valuesA[i], radix: 2)
    let bitRepB = String(valuesB[i], radix: 2)
    
    guard bitRepA.count >= 16 && bitRepB.count >= 16 else { continue }
    
    let bitsA = bitRepA[bitRepA.index(bitRepA.endIndex, offsetBy: -16)..<bitRepA.endIndex]
    let bitsB = bitRepB[bitRepB.index(bitRepB.endIndex, offsetBy: -16)..<bitRepB.endIndex]
        
    if bitsA == bitsB {
        matches += 1
    }
}

assert(matches == 320)
