//: Playground - noun: a place where people can play

import Cocoa

var position = 0
let stepSize = 370
var buffer = [0]

for value in 1...2017 {
    position = (position+stepSize)%buffer.count
    position = position+1
    buffer.insert(value, at: position)
}

let idx = buffer.index(of: 2017)!+1
assert(buffer[idx] == 1244)
