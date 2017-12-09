//: Playground - noun: a place where people can play

import Cocoa

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let spreadsheet = try! String(contentsOfFile: filePath)

let lines = spreadsheet.split(separator: "\n")

let numCharSet = CharacterSet(charactersIn: "1234567890")
let rows = lines.map { line -> [Int] in
    return line.split(separator: " ").map { Int($0)! }
}

let checksums = rows.reduce(into: [Int]()) { sums, row in
    var divider = 0
    var divisor = 0
    for (idx, x) in row.enumerated().dropLast() {
        for yIdx in idx+1..<row.count {
            let y = row[yIdx]
            let tempDivider = max(x, y)
            let tempDivisor = min(x, y)
            if tempDivider.remainderReportingOverflow(dividingBy: tempDivisor).partialValue == 0 {
                divider = tempDivider
                divisor = tempDivisor
            }
        }
    }
    
    if divider != 0 && divisor != 0 {
        sums.append(divider/divisor)
    }
}

let sum = checksums.reduce(0, +)
assert(sum == 326)
