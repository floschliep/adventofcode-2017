//: Playground - noun: a place where people can play

import Cocoa

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let sequence = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
var numbers = sequence.map { Int(String($0))! }

var sum = 0

for (idx, x) in numbers.enumerated() {
    var matchingIndex = idx + numbers.count/2
    if matchingIndex > numbers.count-1 {
        matchingIndex = matchingIndex.remainderReportingOverflow(dividingBy: numbers.count).0
    }
    if x == numbers[matchingIndex] {
        sum += x
    }
}

assert(sum == 1356)
