//: Playground - noun: a place where people can play

import Cocoa

let input = "34,88,2,222,254,93,150,0,199,255,39,32,137,136,1,167"
let ascii = input.flatMap { $0.unicodeScalars.map({ Int($0.value) }) }
let inputLengths = ascii + [17, 31, 73, 47, 23]
let numberOfRounds = 64

var list = (0..<256).map { $0 }

var position = 0
var skipSize = 0

for _ in 0..<numberOfRounds {
    for rangeLength in inputLengths {
        guard rangeLength <= list.count else { fatalError("Invalid Length \(rangeLength)") }
        
        // wrap position if needed
        if position > list.count-1 {
            position = position.remainderReportingOverflow(dividingBy: list.count).0
        }
        
        if rangeLength > 1 {
            var ranges = [ClosedRange<Int>]()
            // determine range(s) to reverse
            let endIndex = position + rangeLength - 1
            if endIndex > list.count-1 {
                var i = position
                for _ in position...endIndex {
                    if i >= list.count-1 {
                        ranges.append((position...i))
                        i = 0
                    } else {
                        i += 1
                    }
                }
                ranges.append((0...i-1))
            } else {
                ranges.append((position...endIndex))
            }
            
            // get numbers in ranges; flatten and reverse them
            let slice: [Int] = ranges.flatMap({ list[$0] }).reversed()
            // replace numbers in list with numbers in slice
            var sliceIndex = 0
            for range in ranges {
                for listIndex in CountableRange(range) {
                    list[listIndex] = slice[sliceIndex]
                    sliceIndex += 1
                }
            }
        }
        
        // move to next position and update skip size
        position += rangeLength + skipSize
        skipSize += 1
    }
}

let blocks = (0..<16).map { list[(16*$0..<16*$0+16)] }
let hashes = blocks.map { $0.reduce(0, ^) }
let hex = hashes
    .map({ String(format: "%02X", $0).trimmingCharacters(in: .whitespaces) })
    .reduce("", +)
    .lowercased()

assert(hex == "a7af2706aa9a09cf5d848c1e6605dd2a")
