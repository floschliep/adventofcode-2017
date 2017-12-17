//: Playground - noun: a place where people can play

import Cocoa

var position = 0
let stepSize = 370

// - Part 1

//var buffer = [0]
//
//for value in 1...2017 {
//    position = (position+stepSize)%buffer.count
//    position = position+1
//    buffer.insert(value, at: position)
//}
//
//let idx = buffer.index(of: 2017)!+1
//assert(buffer[idx] == 1244)

// - Part 2

var valueAfter0 = 0

for value in 0...50_000_000 {
    position = (position+stepSize)%(value+1)
    position = position+1
    if position == 1 {
        valueAfter0 = value+1
    }
}

assert(valueAfter0 == 11162912)
